#!/bin/bash

# Norm args -------------------------------------------------------------------
TRTEXEC_PATH=trtexec
FP16=false
INT8=false
BEST=false
DYNAMIC=false
WORKSPACE=2048 # MB
ONNX_MODEL_PATH="model.onnx"

# Dynamic args ----------------------------------------------------------------
MIN_BATCH=1
OPT_BATCH=4   # Should be between MIN_BATCH and MAX_BATCH
MAX_BATCH=8
CHANNEL=3
HEIGHT=256
WIDTH=256
INPUT_NAME="images"

# Int8 Args -------------------------------------------------------------------
CALIB_DATA_PATH=""
CALIB_CACHE_FILE="model_int8_calibration.cache"

# ----------------------------------------------------------------------------- 
WORKSPACE_FLAG="--workspace=$WORKSPACE"
# ----------------------------------------------------------------------------- 
if [ "$BEST" = true ]; then
    BEST_FLAG="--best"
    FP16_FLAG=""
    INT8_FLAG=""
    CALIB_FLAG=""
    CALIB_CACHE_FILE_FLAG=""
else
    BEST_FLAG=""
    if [ "$FP16" = true ]; then
        FP16_FLAG="--fp16"
    else
        FP16_FLAG=""
    fi
    if [ "$INT8" = true ]; then
        INT8_FLAG="--int8"
        CALIB_FLAG="--calib=$CALIB_DATA_PATH"
        CALIB_CACHE_FILE_FLAG="--calibCache=$CALIB_CACHE_FILE"
    else
        INT8_FLAG=""
        CALIB_FLAG=""
        CALIB_CACHE_FILE_FLAG=""
    fi
fi
# ----------------------------------------------------------------------------- 
if [ "$DYNAMIC" = true ]; then
    CxHxW="${CHANNEL}x${HEIGHT}x${WIDTH}"
    MIN_BATCH_FLAG="--minShapes=${INPUT_NAME}:${MIN_BATCH}x${CxHxW}"
    OPT_BATCH_FLAG="--optShapes=${INPUT_NAME}:${OPT_BATCH}x${CxHxW}"
    MAX_BATCH_FLAG="--maxShapes=${INPUT_NAME}:${MAX_BATCH}x${CxHxW}"
else
    MIN_BATCH_FLAG=""
    OPT_BATCH_FLAG=""
    MAX_BATCH_FLAG=""
fi
# Run -------------------------------------------------------------------------
if [ -e "$ONNX_MODEL_PATH" ]; then
  FILE_NAME=$(basename "$ONNX_MODEL_PATH")
  SUFFIX="${FILE_NAME##*.}"
  BASE_NAME=${FILE_NAME%.*}
  DIR_NAME=$(dirname "$ONNX_MODEL_PATH")
  ENGINE_MODEL_NAME="$DIR_NAME/${BASE_NAME}.engine"

  if [ "$SUFFIX" != "onnx" ]; then
    echo "Error: The file is not an ONNX file. It has a .$SUFFIX extension."
    exit 1
  fi
  
  $TRTEXEC_PATH \
    --onnx="$ONNX_MODEL_PATH" \
    $WORKSPACE_FLAG \
    $MIN_BATCH_FLAG \
    $OPT_BATCH_FLAG \
    $MAX_BATCH_FLAG \
    $FP16_FLAG \
    $BEST_FLAG \
    $INT8_FLAG \
    $CALIB_FLAG \
    $CALIB_CACHE_FILE_FLAG \
    --saveEngine="$ENGINE_MODEL_NAME"

  echo "----------"
  echo "FP16: ${FP16}"
  echo "BEST: ${BEST}"
  echo "INT8: ${INT8}"
  echo "ONNX Model: $ONNX_MODEL_PATH"
  echo "TensorRT Model: $ENGINE_MODEL_NAME"

else
  echo "$ONNX_MODEL_PATH not found."
fi
