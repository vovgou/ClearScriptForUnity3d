@echo off
setlocal

set CLEARSCRIPT_V8_SRC_DIR=%~dp0\..

echo "Building ClearScript.V8.Native(x86) ..."
echo ================================ 
setlocal
set CLEARSCRIPT_V8_BUILD_DIR=%CLEARSCRIPT_V8_SRC_DIR%\build\x86
cmake -G "Visual Studio 16 2019" -A Win32 -S %CLEARSCRIPT_V8_SRC_DIR% -B %CLEARSCRIPT_V8_BUILD_DIR%
cmake --build %CLEARSCRIPT_V8_BUILD_DIR% --config Release --target install 

endlocal

echo "Building ClearScript.V8.Native(x64) ..."
echo ================================ 
setlocal
set CLEARSCRIPT_V8_BUILD_DIR=%CLEARSCRIPT_V8_SRC_DIR%\build\x64
cmake -G "Visual Studio 16 2019" -A x64 -S %CLEARSCRIPT_V8_SRC_DIR% -B %CLEARSCRIPT_V8_BUILD_DIR%
cmake --build %CLEARSCRIPT_V8_BUILD_DIR% --config Release --target install 

endlocal

endlocal