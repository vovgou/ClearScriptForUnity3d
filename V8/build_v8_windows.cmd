@echo off
setlocal

::Check the version from here: https://omahaproxy.appspot.com/
set v8rev=8.8.278.14
::set v8rev=8.9.202
::MODE:debug release official
set MODE=release
set DEPOT_TOOLS_WIN_TOOLCHAIN=0

set V8_ROOT=%~dp0
set TARGETS_PATH=%V8_ROOT%\build\targets
set PLATFORM_NAME=windows

md build
md %TARGETS_PATH%
cd build

echo "Downloading Depot Tools ..."
echo ================================ 
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://storage.googleapis.com/chrome-infra/depot_tools.zip', 'DepotTools.zip')"
if errorlevel 1 goto Error

:ExpandDepotTools
echo "Expanding Depot Tools ..."
echo ================================ 
powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; [IO.Compression.ZipFile]::ExtractToDirectory('DepotTools.zip', 'DepotTools')"
if errorlevel 1 goto Error
path %cd%\DepotTools;%path%

echo "Downloading V8 and dependencies ..."
echo ================================ 
call gclient config https://chromium.googlesource.com/v8/v8 >config.log
if errorlevel 1 goto Error
call gclient sync -r %v8rev% >sync.log
if errorlevel 1 goto Error

:ApplyPatches
echo "Applying patches ..."
echo ================================ 
cd v8
call git config user.name ClearScript
if errorlevel 1 goto Error
call git config user.email "ClearScript@microsoft.com"
if errorlevel 1 goto Error
call git apply --reject --ignore-whitespace ..\..\V8Patch.txt 2>applyV8Patch.log
if errorlevel 1 goto Error
cd ..
:ApplyPatchesDone


::-----------------------------------------------------------------------------
:: build
::-----------------------------------------------------------------------------

:Build

:CreatePatches
echo "Creating/updating patches ..."
echo ================================ 
cd v8
call git diff --ignore-space-change --ignore-space-at-eol >V8Patch.txt 2>createV8Patch.log
if errorlevel 1 goto Error
cd ..
:CreatePatchesDone

:Build32Bit
cd v8
echo "Building V8(x86) ..."
echo ================================ 

set PLATFORM_NAME=windows
::set BUILDER_GROUP=developer_default
::if %MODE% == debug (set BUILDER_NAME=ia32.debug) else (set BUILDER_NAME=ia32.release)

set TARGET_CPU=x86

set BUILD_GEN_DIR=%TARGET_CPU%.%MODE%


set GN_ARGS=target_os=\"win\" target_cpu=\"%TARGET_CPU%\" v8_target_cpu=\"%TARGET_CPU%\" 
if %MODE% == debug (set GN_ARGS=%GN_ARGS% is_debug=true is_official_build=false)
if %MODE% == release (set GN_ARGS=%GN_ARGS% is_debug=false is_official_build=false symbol_level=0  strip_debug_info=true v8_enable_debugging_features=false)
if %MODE% == official (set GN_ARGS=%GN_ARGS% is_debug=false is_official_build=true chrome_pgo_phase=0 symbol_level=0  strip_debug_info=true v8_enable_debugging_features=false)
set GN_ARGS=%GN_ARGS% v8_embedder_string=\"-ClearScript\" use_goma=false is_component_build=false use_custom_libcxx=false v8_enable_i18n_support=false v8_enable_pointer_compression=false v8_enable_31bit_smis_on_64bit_arch=false v8_use_external_startup_data=false v8_monolithic=true 

::call python .\tools\dev\v8gen.py gen -m "%BUILDER_GROUP%" -b "%BUILDER_NAME%" %BUILD_GEN_DIR% -vv -- %GN_ARGS%
call gn gen out.gn\%BUILD_GEN_DIR% --args="%GN_ARGS%" 
call gn args --list out.gn\%BUILD_GEN_DIR% > %TARGETS_PATH%\%PLATFORM_NAME%.%TARGET_CPU%.%MODE%.txt
call ninja -C out.gn\%BUILD_GEN_DIR% v8_monolith

cd ..

md %TARGETS_PATH%\%PLATFORM_NAME%_x86\lib
copy /Y v8\out.gn\%BUILD_GEN_DIR%\obj\v8_monolith.lib %TARGETS_PATH%\%PLATFORM_NAME%_x86\lib\
md %TARGETS_PATH%\%PLATFORM_NAME%_x86\include
xcopy v8\include %TARGETS_PATH%\%PLATFORM_NAME%_x86\include  /s/h/e/k/f/c

:Build64Bit
cd v8
echo "Building V8(x86_64) ..."
echo ================================ 

set PLATFORM_NAME=windows
::set BUILDER_GROUP=developer_default
::if %MODE% == debug (set BUILDER_NAME=x64.debug) else (set BUILDER_NAME=x64.release)

set TARGET_CPU=x64

set BUILD_GEN_DIR=%TARGET_CPU%.%MODE%

set GN_ARGS=target_os=\"win\" target_cpu=\"%TARGET_CPU%\" v8_target_cpu=\"%TARGET_CPU%\" 
if %MODE% == debug (set GN_ARGS=%GN_ARGS% is_debug=true is_official_build=false)
if %MODE% == release (set GN_ARGS=%GN_ARGS% is_debug=false is_official_build=false symbol_level=0  strip_debug_info=true v8_enable_debugging_features=false)
if %MODE% == official (set GN_ARGS=%GN_ARGS% is_debug=false is_official_build=true chrome_pgo_phase=0 symbol_level=0  strip_debug_info=true v8_enable_debugging_features=false)
set GN_ARGS=%GN_ARGS% v8_embedder_string=\"-ClearScript\" use_goma=false is_component_build=false use_custom_libcxx=false v8_enable_i18n_support=false v8_enable_pointer_compression=false v8_enable_31bit_smis_on_64bit_arch=false v8_use_external_startup_data=false v8_monolithic=true 

::call python .\tools\dev\v8gen.py gen -m "%BUILDER_GROUP%" -b "%BUILDER_NAME%" %BUILD_GEN_DIR% -vv -- %GN_ARGS% 
call gn gen out.gn\%BUILD_GEN_DIR% --args="%GN_ARGS%" 
call gn args --list out.gn\%BUILD_GEN_DIR% > %TARGETS_PATH%\%PLATFORM_NAME%.%TARGET_CPU%.%MODE%.txt
call ninja -C out.gn\%BUILD_GEN_DIR% v8_monolith

cd ..

md %TARGETS_PATH%\%PLATFORM_NAME%_x86_64\lib
copy  /Y v8\out.gn\%BUILD_GEN_DIR%\obj\v8_monolith.lib %TARGETS_PATH%\%PLATFORM_NAME%_x86_64\lib\
md %TARGETS_PATH%\%PLATFORM_NAME%_x86_64\include
xcopy v8\include %TARGETS_PATH%\%PLATFORM_NAME%_x86_64\include  /s/h/e/k/f/c

:BuildDone

cp ..\build_v8_windows.cmd %TARGETS_PATH%\

::-----------------------------------------------------------------------------
:: import
::-----------------------------------------------------------------------------

:Import

cd ..

:ImportPatches
echo Importing patches ...
copy build\v8\V8Patch.txt .\ >nul
if errorlevel 1 goto Error
:ImportPatchesDone

copy /Y V8Patch.txt %TARGETS_PATH%\

:ImportDone

::-----------------------------------------------------------------------------
:: exit
::-----------------------------------------------------------------------------

echo Succeeded!
goto Exit

:Error
echo *** THE PREVIOUS STEP FAILED ***

:Exit
endlocal
