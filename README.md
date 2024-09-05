# TensorRT Export Shell Script

---

## Intro

`ONNX` model to `TensorRT` model shell script.

---

## Args

| Args              |  Type  | Info                                       |
|:------------------|:------:|--------------------------------------------|
| `TRTEXEC_PATH`    | `str`  | `trtexec` tool path                        |
| `DYNAMIC`         | `bool` | Convert to static model or dynamic         |
| `ONNX_MODEL_PATH` | `str`  | ONNX model path                            |
| `PRECISION` | `str`  | `none` `fp16`,`int8` `best`                |
| `WORKSPACE_SIZE`  | `int`  | Workspace memory size (MB)                 |
| `MIN_BATCH`       | `int`  | Min input batch **(only in dynamic mode)** |
| `MAX_BATCH`       | `int`  | Max input batch **(only in dynamic mode)** |
| `CHANNEL`         | `int`  | Image channel **(only in dynamic mode)**   |
| `HEIGHT`          | `int`  | Image height **(only in dynamic mode)**    |
| `WIDTH`           | `int`  | Image width **(only in dynamic mode)**     |

---

## Run

```bash
sudo chmod +x export.sh
./export.sh
```
