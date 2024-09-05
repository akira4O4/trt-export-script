# TensorRT Export Shell Script

---

## Intro

This shell script is designed to automate the conversion of `ONNX` models to `TensorRT` engines using trtexec, with support for different precision levels and dynamic/static shape optimizations. The script supports:

- **Precision Handling**: Converts models into `fp32`, `fp16`, `int8`, or `best` precision, with optional calibration for int8 mode.
- **Dynamic or Static Models**: Provides an option to convert models with `dynamic` shapes or `static` shapes, depending on user preference.
- **Workspace and Calibration Management**: Allows configuration of workspace size and provides support for INT8 `calibration data` and `calibration cache` files.
- **Batch Size Customization**: Supports dynamic models with customizable input shapes (`batch size`, `height`, `width`, and `channels`).

---

## Install

```bash
git clone https://github.com/akira4O4/trt-export-script.git
```

---

## Args

| Args              |  Type  | Info                                       |
|:------------------|:------:|--------------------------------------------|
| `TRTEXEC_PATH`    | `str`  | `trtexec` tool path                        |
| `DYNAMIC`         | `bool` | Convert to static model or dynamic         |
| `PRECISION`       | `str`  | `fp32` `fp16`,`int8` `best`                |
| `WORKSPACE_SIZE`  | `int`  | Workspace memory size (MB)                 |
| `ONNX_MODEL_PATH` | `str`  | ONNX model path                            |
| `CALIB_DATA_PATH` | `str`  | Calib data path  **(int8 mode)**                          |
| `CALIB_CACHE_FILE`| `str`  | Calib cache data path **(int8 mode)**                            |
| `MIN_BATCH`       | `int`  | Min input batch **(dynamic mode)** |
| `MAX_BATCH`       | `int`  | Max input batch **(only in dynamic mode)** |
| `CHANNEL`         | `int`  | Image channel **(dynamic mode)**   |
| `HEIGHT`          | `int`  | Image height **(dynamic mode)**    |
| `WIDTH`           | `int`  | Image width **(dynamic mode)**     |
| `INPUT_NAME`           | `str`  | Model input name **(dynamic mode)**     |

---

## Run

```bash
sudo chmod +x export.sh
./export.sh
```
