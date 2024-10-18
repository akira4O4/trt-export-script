@echo off

REM Norm args -----------------------------------------------------------------------------------------------------------
set TRTEXEC_PATH=trtexec
set DYNAMIC=false
set PRECISION=fp32 REM Choices: "fp32", "fp16", "int8", "best"
set WORKSPACE_SIZE=2048 REM MB
set ONNX_MODEL_PATH=model.onnx

REM Int8 Args -----------------------------------------------------------------------------------------------------------
REM Only use in int8 mode
set CALIB_DATA_PATH=
set CALIB_CACHE_FILE=model_int8_calibration.cache

REM Dynamic args --------------------------------------------------------------------------------------------------------
REM Only use in dynamic mode
set MIN_BATCH=1
set MAX_BATCH=8
set CHANNEL=3
set HEIGHT=256
set WIDTH=256
set INPUT_NAME=images

REM Check ---------------------------------------------------------------------------------------------------------------
set PRECISION_FLAG=
set CALIB_FLAG=
set CALIB_CACHE_FILE_FLAG=

if "%PRECISION%" == "fp16" (
    set PRECISION_FLAG=--fp16
) else if "%PRECISION%" == "int8" (
    if "%CALIB_DATA_PATH%" == "" (
        echo Error: CALIB_DATA_PATH is required for INT8 precision.
        exit /b 1
    ) else if not exist "%CALIB_DATA_PATH%" (
        echo Error: CALIB_DATA_PATH directory does not exist.
        exit /b 1
    )

    if not exist "%CALIB_CACHE_FILE%" (
        echo Warning: Calibration cache file is not found. It will be generated.
    )

    set PRECISION_FLAG=--int8
    set CALIB_FLAG=--calib=%CALIB_DATA_PATH%
    set CALIB_CACHE_FILE_FLAG=--calibCache=%CALIB_CACHE_FILE%
) else if "%PRECISION%" == "best" (
    set PRECISION_FLAG=--best
) else if "%PRECISION%" == "fp32" (
    set PRECISION_FLAG=
) else (
    echo Error: Invalid PRECISION value. Choose from 'fp32', 'fp16', 'int8', 'best'.
    exit /b 1
)

REM Run ----------------------------------------------------------------------------------------------------------------
if exist "%ONNX_MODEL_PATH%" (
    for %%F in ("%ONNX_MODEL_PATH%") do (
        set FILE_NAME=%%~nxF
        set SUFFIX=%%~xF
        set BASE_NAME=%%~nF
        set DIR_NAME=%%~dpF
        set ENGINE_MODEL_NAME=%DIR_NAME%%BASE_NAME%.%PRECISION%
    )

    if /I "%SUFFIX%" neq ".onnx" (
        echo Error: The file is not an ONNX file. It has a %SUFFIX% extension.
        exit /b 1
    )

    if "%DYNAMIC%" == "true" (
        set CxHxW=%CHANNEL%x%HEIGHT%x%WIDTH%
        set ENGINE_MODEL_PATH=%ENGINE_MODEL_NAME%.dynamic.engine

        set MIN_BATCH_FLAG=--minShapes=%INPUT_NAME%:%MIN_BATCH%x%CxHxW%
        set OPT_BATCH_FLAG=--optShapes=%INPUT_NAME%:%MAX_BATCH%x%CxHxW%
        set MAX_BATCH_FLAG=--maxShapes=%INPUT_NAME%:%MAX_BATCH%x%CxHxW%
    ) else (
        set MIN_BATCH_FLAG=
        set OPT_BATCH_FLAG=
        set MAX_BATCH_FLAG=
        set ENGINE_MODEL_PATH=%ENGINE_MODEL_NAME%.static.engine
    )

    %TRTEXEC_PATH% ^
        --onnx="%ONNX_MODEL_PATH%" ^
        --workspace=%WORKSPACE_SIZE% ^
        %MIN_BATCH_FLAG% ^
        %OPT_BATCH_FLAG% ^
        %MAX_BATCH_FLAG% ^
        %PRECISION_FLAG% ^
        %CALIB_FLAG% ^
        %CALIB_CACHE_FILE_FLAG% ^
        --saveEngine="%ENGINE_MODEL_PATH%"

    echo ----------
    echo ONNX Model: %ONNX_MODEL_PATH%
    echo TensorRT Model: %ENGINE_MODEL_PATH%
) else (
    echo %ONNX_MODEL_PATH% not found.
)
