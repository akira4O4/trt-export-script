#!/bin/bash

# === Model Options ===
trtexec_path=trtexec
onnx_model_path=""

# === Build Options ===
fp16=true
int8=false
best=false
dynamic=false
workspace=2048 # MiB

# === Dynamic args ===
min_batch=1
opt_batch=4   # Should be between min_batch and max_batch
max_batch=8
channel=3
height=28
width=28
input_name="images"

# === Int8 Args ===
calib_data_path=""
calib_cache_file="./model_int8_calibration.cache"

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

workspace_flag="--workspace=$workspace"

# Check if ONNX model exists
if [ ! -e "$onnx_model_path" ]; then
  echo "Error: $onnx_model_path not found."
  exit 1
fi

# FP16/INT8/Best flag handling
if [ "$best" = true ]; then
  best_flag="--best"
  fp16_flag=""
  int8_flag=""
  calib_flag=""
  calib_cache_file_flag=""
else
  best_flag=""
  fp16_flag=$([ "$fp16" = true ] && echo "--fp16" || echo "")
  if [ "$int8" = true ]; then
    int8_flag="--int8"
    calib_flag="--calib=$calib_data_path"
    calib_cache_file_flag="--calibCache=$calib_cache_file"
  else
    int8_flag=""
    calib_flag=""
    calib_cache_file_flag=""
  fi
fi

# Dynamic batch sizes setup
if [ "$dynamic" = true ]; then
  c_h_w="${channel}x${height}x${width}"
  min_batch_flag="--minShapes=${input_name}:${min_batch}x${c_h_w}"
  opt_batch_flag="--optShapes=${input_name}:${opt_batch}x${c_h_w}"
  max_batch_flag="--maxShapes=${input_name}:${max_batch}x${c_h_w}"
else
  min_batch_flag=""
  opt_batch_flag=""
  max_batch_flag=""
fi

# Generate timestamped log file
timestamp=$(date +"%Y%m%d_%H%M%S")
log_file="trtexec_log_${timestamp}.txt"

# File details
file_name=$(basename "$onnx_model_path")
suffix="${file_name##*.}"
base_name="${file_name%.*}"
dir_name=$(dirname "$onnx_model_path")
engine_model_name="$dir_name/${base_name}.plan"

# Ensure file is ONNX
if [ "$suffix" != "onnx" ]; then
  echo "Error: The file is not an ONNX file. It has a .$suffix extension."
  exit 1
fi

# Run trtexec
$trtexec_path \
  --onnx="$onnx_model_path" \
  $workspace_flag \
  $min_batch_flag \
  $opt_batch_flag \
  $max_batch_flag \
  $fp16_flag \
  $best_flag \
  $int8_flag \
  $calib_flag \
  $calib_cache_file_flag \
  --saveEngine="$engine_model_name" \
  2>&1 | tee "$log_file"

# Output summary
echo "----------"
echo "FP16: ${fp16}"
echo "BEST: ${best}"
echo "INT8: ${int8}"
echo "ONNX Model: $onnx_model_path"
echo "TensorRT Model: $engine_model_name"
