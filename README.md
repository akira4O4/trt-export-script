# TRTEXECShell Script

---

## Intro
The repository provides shell scripts for exporting engine models and testing model performance.

Export: ```export.sh```  
Infer: ```benchmark.sh```

Support OS:
- linux
- windows

---

## Install

```bash
git clone https://github.com/akira4O4/trtexec-shell.git
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
Add TensorRT to the system environment variables to run this file from anywhere.
### Linux
```bash
sudo chmod +x export.sh
./export.sh
```
### Windows

```bat
./export.bat
```
