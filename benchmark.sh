#!/bin/bash

#===Model Options=== 
trtexec_path=trtexec
model_path="" #model.onnx or model.engine
workspace=2048          # 工作区大小（MiB）

# === Inference Options ===
batch=1
shapes=""       #e.g.shapes=input_tensor:1x3x224x224
iterations=10    # 指定推理执行的次数 
duration=0      # 指定测试持续的时间(秒)
warm_up=100
streams=1       # 指定并行执行的流的数量
threads=false
fp16=false
int8=false
best=false
calib=""
verbose=false

# === Reporting Options ===
export_times="./times.json"
export_output="./output.json"
export_profile=""
export_layer_info="./layer_info.json"

#===System Options===
device=0
use_dla_core="" #0,1 (DLA 通常配合 FP16 模式使用)

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
batch_flag="--batch=${batch}"
warm_up_flag="--warmUp=${warm_up}"
device_flag="--device=${device}"
duration_flag="--duration=${duration}"
iterations_flag="--iterations=${iterations}"
streams_flag="--streams=${streams}"
workspace_flag="--workspace=${workspace}"
export_times_flag="--exportTimes=${export_times}"
export_output_flag="--exportOutput=${export_output}"
export_profile_flag="--exportProfile=${export_profile}"
export_layer_info_flag="--exportLayerInfo=${export_layer_info}"
# -----------------------------------------------------------------------------
if [ -z "$shapes" ]; then
    shapes_flag=""
else
    shapes_flag="--shapes=${shapes}"
fi
# -----------------------------------------------------------------------------
file_extension="${model_path##*.}"
if [ "$file_extension" = "onnx" ]; then
    model_flag="--onnx=$model_path"
elif [ "$file_extension" = "engine" ]; then
    model_flag="--loadEngine=$model_path"
elif [ "$file_extension" = "plan" ]; then
    model_flag="--loadEngine=$model_path"
elif [ "$file_extension" = "trt" ]; then
    model_flag="--loadEngine=$model_path"
else
    echo "Unknown model type: $file_extension"
    echo "Please provide a valid ONNX or TensorRT engine file."
    exit 1
fi
# -----------------------------------------------------------------------------
if [ "$verbose" = true ]; then
    verbose_flag="--verbose"
else
    verbose_flag=""
fi
# -----------------------------------------------------------------------------
if [ "$best" = true ]; then
    best_flag="--best"
else
    best_flag=""
fi
# -----------------------------------------------------------------------------
if [ "$fp16" = true ]; then
    fp16_flag="--fp16"
else
    fp16_flag=""
fi
# -----------------------------------------------------------------------------
if [ "$int8" = true ]; then
    if [ -z "$calib" ]; then
        echo "Error: INT8 mode enabled but no calibration file specified."
        exit 1
    fi
    int8_flag="--int8"
    calib_path="--calib=${calib}"
else
    int8_flag=""
    calib_path=""
fi
# -----------------------------------------------------------------------------
if [ "$threads" = true ]; then
    threads_flag="--threads"
else
    threads_flag=""
fi
# -----------------------------------------------------------------------------
if [ ! -z "$use_dla_core" ]; then
    dla_flag="--useDLACore=$use_dla_core"
else
    dla_flag=""
fi

# -----------------------------------------------------------------------------
# Generate timestamped log file
timestamp=$(date +"%Y%m%d_%H%M%S")
log_file="trtexec_log_${timestamp}.txt"

# 执行 trtexec 命令
$trtexec_path \
    $model_flag \
    $batch_flag \
    $shapes_flag \
    $warm_up_flag \
    $device_flag \
    $duration_flag \
    $iterations_flag \
    $streams_flag \
    $workspace_flag \
    $best_flag \
    $fp16_flag \
    $int8_flag \
    $calib_path \
    $verbose_flag \
    $export_times_flag \
    $export_output_flag \
    $export_profile_flag \
    $export_layer_info_flag \
    $dla_flag \
    2>&1 | tee "$log_file"
