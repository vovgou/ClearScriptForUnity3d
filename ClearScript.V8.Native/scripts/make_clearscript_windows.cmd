@echo off
setlocal

set CLEARSCRIPT_V8_SRC_DIR=%~dp0\..
set INSTALL_ROOT_DIR=%CLEARSCRIPT_V8_SRC_DIR%\build\targets

echo "Building ClearScript.V8.Native(x86) ..."
echo ================================ 
setlocal
set CLEARSCRIPT_V8_BUILD_DIR=%CLEARSCRIPT_V8_SRC_DIR%\build\x86
cmake -G "Visual Studio 16 2019" -A Win32 -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT_DIR} -S %CLEARSCRIPT_V8_SRC_DIR% -B %CLEARSCRIPT_V8_BUILD_DIR%
cmake --build %CLEARSCRIPT_V8_BUILD_DIR% --config Release --target install 

endlocal

echo "Building ClearScript.V8.Native(x64) ..."
echo ================================ 
setlocal
set CLEARSCRIPT_V8_BUILD_DIR=%CLEARSCRIPT_V8_SRC_DIR%\build\x64
cmake -G "Visual Studio 16 2019" -A x64 -DCMAKE_INSTALL_PREFIX=${INSTALL_ROOT_DIR} -S %CLEARSCRIPT_V8_SRC_DIR% -B %CLEARSCRIPT_V8_BUILD_DIR%
cmake --build %CLEARSCRIPT_V8_BUILD_DIR% --config Release --target install 

endlocal

endlocal