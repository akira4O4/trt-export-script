#!/bin/bash

# Norm args -------------------------------------------------------------------
TRTEXEC_PATH=trtexec
DYNAMIC=false
MODE="onnx"             # onnx 或 engine
MODEL_PATH="model.onnx" #model.onnx or model.engine
WORKSPACE=2048          # 工作区大小（MB）
INPUT_NAME="images"
BATCH=1
FP16=false
INT8=false
CALIB=""
THREADS=false
VERBOSE=false
DLA_CORE_ID=""

ITERATIONS=1    # 指定推理执行的次数
DURATION=0      # 指定测试持续的时间(秒)
STREAMS=1       # 指定并行执行的流的数量

# Dynamic args ----------------------------------------------------------------
MIN_BATCH=1
OPT_BATCH=1
MAX_BATCH=8
CHANNEL=3
HEIGHT=256
WIDTH=256

# -----------------------------------------------------------------------------
DURATION_FLAG="--duration=${DURATION}"
# -----------------------------------------------------------------------------
ITERATIONS_FLAG="--iterations=${ITERATIONS}"
# -----------------------------------------------------------------------------
STREAMS_FLAG="--streams=${STREAMS}"
# -----------------------------------------------------------------------------
WORKSPACE_FLAG="--workspace=$WORKSPACE"
# -----------------------------------------------------------------------------
if [ "$MODE" = "onnx" ]; then
    MODEL_FLAG="--onnx=$MODEL_PATH"
else
    MODEL_FLAG="--loadEngine=$MODEL_PATH"
fi
# -----------------------------------------------------------------------------
if [ "$VERBOSE" = true ]; then
    VERBOSE_FLAG="--verbose"
else
    VERBOSE_FLAG=""
fi
# -----------------------------------------------------------------------------
if [ "$FP16" = true ]; then
    FP16_FLAG="--fp16"
else
    FP16_FLAG=""
fi
# -----------------------------------------------------------------------------
if [ "$INT8" = true ]; then
    if [ -z "$CALIB" ]; then
        echo "Error: INT8 mode enabled but no calibration file specified."
        exit 1
    fi
    INT8_FLAG="--int8"
    CALIB_PATH="--calib=${CALIB}"
else
    INT8_FLAG=""
    CALIB_PATH=""
fi
# -----------------------------------------------------------------------------
if [ "$THREADS" = true ]; then
    THREADS_FLAG="--threads"
else
    THREADS_FLAG=""
fi
# -----------------------------------------------------------------------------
if [ "$DYNAMIC" = true ]; then
    CxHxW="${CHANNEL}x${HEIGHT}x${WIDTH}"
    MIN_BATCH_FLAG="--minShapes=${INPUT_NAME}:${MIN_BATCH}x${CxHxW}"
    OPT_BATCH_FLAG="--optShapes=${INPUT_NAME}:${OPT_BATCH}x${CxHxW}"
    MAX_BATCH_FLAG="--maxShapes=${INPUT_NAME}:${MAX_BATCH}x${CxHxW}"
    BATCH_FLAG=""  # 动态模型下不设置固定 batch
else
    MIN_BATCH_FLAG=""
    OPT_BATCH_FLAG=""
    MAX_BATCH_FLAG=""
    BATCH_FLAG="--batch=${BATCH}"
fi
# -----------------------------------------------------------------------------
if [ -z "$DLA_CORE_ID" ]; then
    DLA_FLAG=""
else
    DLA_FLAG="--useDLACore=$DLA_CORE_ID"
fi
# -----------------------------------------------------------------------------

# 执行 trtexec 命令
$TRTEXEC_PATH \
    $MODEL_FLAG \
    $WORKSPACE_FLAG \
    $DLA_FLAG \
    $FP16_FLAG \
    $INT8_FLAG \
    $CALIB_PATH \
    $BATCH_FLAG \
    $MIN_BATCH_FLAG \
    $OPT_BATCH_FLAG \
    $MAX_BATCH_FLAG \
    $VERBOSE_FLAG \
    $THREADS_FLAG \
    $DURATION_FLAG \
    $ITERATIONS_FLAG \
    $STREAMS_FLAG
