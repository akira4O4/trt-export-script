# TRTEXEC Shell Script

---

## Intro
The repository provides shell scripts for exporting engine models and testing model performance.
The script contains most of the trtexec parameters.  

- Export: ```export.sh```  
- Infer: ```benchmark.sh```

Support OS:
- linux
- windows

---

## Install

```bash
git clone https://github.com/akira4O4/trtexec-shell.git
```

---

## Run
Add TensorRT to the system environment variables to run this file from anywhere.  

**Export model**
```bash
sudo chmod +x export.sh
./export.sh
```
**Test model**
```bash
sudo chmod +x benchmark.sh
./benchmark.sh
```

