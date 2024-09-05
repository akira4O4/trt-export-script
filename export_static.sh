#!/bin/bash
#Global ags -----------------------------------------------------------------------------------------------------------
TRTEXEC_PATH=trtexec
DYNAMIC=false
PRECISION="none" # "fp16", "int8", "best" 或 "none"
WORKSPACE_SIZE=1024
ONNX_MODEL_PATH="/path/model.onnx" # 在这里填写你的 ONNX 模型路径

#Dynamic args ----------------------------------------------------------------------------------------------------------
MIN_BATCH=1
MAX_BATCH=8
CHANNEL=3
HEIGHT=288
WIDTH=288

# Precision args -------------------------------------------------------------------------------------------------------
PRECISION_FLAG=""
if [ "$PRECISION" = "fp16" ]; then
  PRECISION_FLAG="--fp16"
elif [ "$PRECISION" = "int8" ]; then
  PRECISION_FLAG="--int8"
elif [ "$PRECISION" = "best" ]; then
  PRECISION_FLAG="--best"
fi

#Run -------------------------------------------------------------------------------------------------------------------
if [ -e "$ONNX_MODEL_PATH" ]; then

  FILE_NAME=$(basename "$ONNX_MODEL_PATH")
  BASE_NAME=${FILE_NAME%.*}
  DIR_NAME=$(dirname "$ONNX_MODEL_PATH")

  if [ "$DYNAMIC" = true ]; then
    ENGINE_MODEL_PATH="$DIR_NAME/${BASE_NAME}.dynamic.engine"
    CHW=${CHANNEL}x${HEIGHT}x${WIDTH}
    $TRTEXEC_PATH \
      --onnx=$ONNX_MODEL_PATH \
      --minShapes=images:${MIN_BATCH}x${CHW} \
      --maxShapes=images:${MAX_BATCH}x${CHW} \
      --optShapes=images:${MAX_BATCH}x${CHW} \
      --workspace=$WORKSPACE_SIZE \
      $PRECISION_FLAG \
      --saveEngine="$ENGINE_MODEL_PATH"
  else
    ENGINE_MODEL_PATH="$DIR_NAME/${BASE_NAME}.static.engine"
    $TRTEXEC_PATH \
      --onnx=$ONNX_MODEL_PATH \
      --workspace=$WORKSPACE_SIZE \
      $PRECISION_FLAG \
      --saveEngine="$ENGINE_MODEL_PATH"
  fi

  echo "----------"
  echo "ONNX Model: $ONNX_MODEL_PATH"
  echo "TensorRT Model: $ENGINE_MODEL_PATH"

else
  echo "文件: $ONNX_MODEL_PATH 不存在"
fi
