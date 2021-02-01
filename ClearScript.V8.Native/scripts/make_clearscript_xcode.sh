#!/bin/bash

BUILD_ROOT=$(pwd)
CLEARSCRIPT_V8_ROOT=${BUILD_ROOT}/../ClearScriptV8/ClearScript.V8.Native

BIN_PATH=${BUILD_ROOT}/bin/ClearScript.V8.Native

echo "Building ClearScript.V8.Native(macOS) ..."
echo ================================ 
CMAKE_PRJ_GEN=${BUILD_ROOT}/build/ClearScriptV8/macOS

mkdir -p ${CMAKE_PRJ_GEN}
cd ${CMAKE_PRJ_GEN}
cmake -GXcode $CLEARSCRIPT_V8_ROOT
cd $BUILD_ROOT
#cmake --build ${CMAKE_PRJ_GEN} --config Release

#mkdir -p ${BIN_PATH}/macOs
#cp -r ${CMAKE_PRJ_GEN}/ClearScriptV8/Release/ClearScript.V8.Native.bundle ${BIN_PATH}/macOs/


echo "Building ClearScript.V8.Native(iOS) ..."
echo ================================ 

#===========================================================================================
#Options:
#Set -DIOS_PLATFORM to "SIMULATOR" to build for iOS simulator 32 bit (i386) DEPRECATED
#Set -DIOS_PLATFORM to "SIMULATOR64" (example above) to build for iOS simulator 64 bit (x86_64)
#Set -DIOS_PLATFORM to "OS" to build for Device (armv7, armv7s, arm64, arm64e)
#Set -DIOS_PLATFORM to "OS64" to build for Device (arm64, arm64e)
#Set -DIOS_PLATFORM to "TVOS" to build for tvOS (arm64)
#Set -DIOS_PLATFORM to "SIMULATOR_TVOS" to build for tvOS Simulator (x86_64)
#Set -DIOS_PLATFORM to "WATCHOS" to build for watchOS (armv7k, arm64_32)
#Set -DIOS_PLATFORM to "SIMULATOR_WATCHOS" to build for watchOS Simulator (x86_64)
#
#Additional Options
#-DENABLE_BITCODE=(BOOL) - Enabled by default, specify FALSE or 0 to disable bitcode
#-DENABLE_ARC=(BOOL) - Enabled by default, specify FALSE or 0 to disable ARC
#-DENABLE_VISIBILITY=(BOOL) - Disabled by default, specify TRUE or 1 to enable symbol visibility support
#-DIOS_ARCH=(STRING) - Valid values are: armv7, armv7s, arm64, arm64e, i386, x86_64, armv7k, arm64_32. By default it will build for all valid architectures based on -DIOS_PLATFORM (see above)
#==========================================================================================

CMAKE_PRJ_GEN=$BUILD_ROOT/build/ClearScriptV8/iOS
PLATFORM=OS64

mkdir -p ${CMAKE_PRJ_GEN}
cd ${CMAKE_PRJ_GEN}
cmake -DCMAKE_TOOLCHAIN_FILE=$BUILD_ROOT/cmake/ios.toolchain.cmake -DPLATFORM=$PLATFORM -GXcode $CLEARSCRIPT_V8_ROOT
cd $BUILD_ROOT
#cmake --build ${CMAKE_PRJ_GEN} --config Release


#mkdir -p ${BIN_PATH}/iOS
#cp -r ${CMAKE_PRJ_GEN}/ClearScriptV8/Release-iphoneos/libClearScript.V8.Native.a ${BIN_PATH}/iOS/
#cp -r ${BUILD_ROOT}/out/v8/iOS/*.a ${BIN_PATH}/iOS/