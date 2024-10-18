#!/bin/bash

# Norm args -----------------------------------------------------------------------------------------------------------
TRTEXEC_PATH=trtexec
DYNAMIC=false
PRECISION="fp32" # "fp32", "fp16", "int8", "best"
WORKSPACE_SIZE=2048 # MB
ONNX_MODEL_PATH="model.onnx"

# Int8 Args --------------------------------------------------------------------------------------------------------------
# Only use in int8 mode
CALIB_DATA_PATH=""  
CALIB_CACHE_FILE="model_int8_calibration.cache"  

# Dynamic args ----------------------------------------------------------------------------------------------------------
# Only use in dynamic mode
MIN_BATCH=1
MAX_BATCH=8
CHANNEL=3
HEIGHT=256
WIDTH=256
INPUT_NAME="images" 

# Check ----------------------------------------------------------------------------------------------------------------
PRECISION_FLAG=""
CALIB_FLAG=""
CALIB_CACHE_FILE_FLAG=""

if [ "$PRECISION" = "fp16" ]; then
  PRECISION_FLAG="--fp16"

elif [ "$PRECISION" = "int8" ]; then
  if [ -z "$CALIB_DATA_PATH" ]; then
    echo "Error: CALIB_DATA_PATH is required for INT8 precision."
    exit 1
  elif [ ! -d "$CALIB_DATA_PATH" ]; then
    echo "Error: CALIB_DATA_PATH directory does not exist."
    exit 1
  fi

  if [ ! -e "$CALIB_CACHE_FILE" ]; then
    echo "Warning: Calibration cache file is not found. It will be generated."
  fi
  
  PRECISION_FLAG="--int8"
  CALIB_FLAG="--calib=$CALIB_DATA_PATH"
  CALIB_CACHE_FILE_FLAG="--calibCache=$CALIB_CACHE_FILE"

elif [ "$PRECISION" = "best" ]; then
  PRECISION_FLAG="--best"

elif [ "$PRECISION" = "fp32" ]; then
  PRECISION_FLAG=""

else
  echo "Error: Invalid PRECISION value. Choose from 'fp32', 'fp16', 'int8', 'best'."
  exit 1

fi

# Run -------------------------------------------------------------------------------------------------------------------
if [ -e "$ONNX_MODEL_PATH" ]; then
  FILE_NAME=$(basename "$ONNX_MODEL_PATH")
  SUFFIX="${FILE_NAME##*.}"
  BASE_NAME=${FILE_NAME%.*}
  DIR_NAME=$(dirname "$ONNX_MODEL_PATH")
  ENGINE_MODEL_NAME="$DIR_NAME/${BASE_NAME}.${PRECISION}"

  if [ "$SUFFIX" != "onnx" ]; then
    echo "Error: The file is not an ONNX file. It has a .$SUFFIX extension."
    exit 1
  fi

  if [ "$DYNAMIC" = true ]; then
    CxHxW="${CHANNEL}x${HEIGHT}x${WIDTH}"
    ENGINE_MODEL_PATH="${ENGINE_MODEL_NAME}.dynamic.engine"
  
    MIN_BATCH_FLAG="--minShapes=${INPUT_NAME}:${MIN_BATCH}x${CxHxW}"
    OPT_BATCH_FLAG="--optShapes=${INPUT_NAME}:${MAX_BATCH}x${CxHxW}"
    MAX_BATCH_FLAG="--maxShapes=${INPUT_NAME}:${MAX_BATCH}x${CxHxW}"
  else
    MIN_BATCH_FLAG=""
    OPT_BATCH_FLAG=""
    MAX_BATCH_FLAG=""
    ENGINE_MODEL_PATH="${ENGINE_MODEL_NAME}.static.engine"
  fi

  $TRTEXEC_PATH \
    --onnx="$ONNX_MODEL_PATH" \
    --workspace="$WORKSPACE_SIZE" \
    $MIN_BATCH_FLAG \
    $OPT_BATCH_FLAG \
    $MAX_BATCH_FLAG \
    $PRECISION_FLAG \
    $CALIB_FLAG \
    $CALIB_CACHE_FILE_FLAG \
    --saveEngine="$ENGINE_MODEL_PATH"

  echo "----------"
  echo "ONNX Model: $ONNX_MODEL_PATH"
  echo "TensorRT Model: $ENGINE_MODEL_PATH"

else
  echo "$ONNX_MODEL_PATH not found."
fi
