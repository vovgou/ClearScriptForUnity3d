#!/bin/bash

CLEARSCRIPT_V8_SRC_DIR=$(pwd)/..

echo "Building ClearScript.V8.Native(macOS) ..."
echo ================================ 
CLEARSCRIPT_V8_BUILD_DIR=${CLEARSCRIPT_V8_SRC_DIR}/build/macOS
cmake -Tbuildsystem=1 -GXcode -S ${CLEARSCRIPT_V8_SRC_DIR} -B ${CLEARSCRIPT_V8_BUILD_DIR}
cmake --build ${CLEARSCRIPT_V8_BUILD_DIR} --config Release --target install

echo "Building ClearScript.V8.Native(iOS) ..."
echo ================================ 

#===========================================================================================
# https://github.com/leetal/ios-cmake
#
#Options:
#Set -DPLATFORM to "SIMULATOR" to build for iOS simulator 32 bit (i386) DEPRECATED
#Set -DPLATFORM to "SIMULATOR64" (example above) to build for iOS simulator 64 bit (x86_64)
#Set -DPLATFORM to "OS" to build for Device (armv7, armv7s, arm64)
#Set -DPLATFORM to "OS64" to build for Device (arm64)
#Set -DPLATFORM to "OS64COMBINED" to build for Device & Simulator (FAT lib) (arm64, x86_64)
#Set -DPLATFORM to "TVOS" to build for tvOS (arm64)
#Set -DPLATFORM to "TVOSCOMBINED" to build for tvOS & Simulator (arm64, x86_64)
#Set -DPLATFORM to "SIMULATOR_TVOS" to build for tvOS Simulator (x86_64)
#Set -DPLATFORM to "WATCHOS" to build for watchOS (armv7k, arm64_32)
#Set -DPLATFORM to "WATCHOSCOMBINED" to build for watchOS & Simulator (armv7k, arm64_32, i386)
#Set -DPLATFORM to "SIMULATOR_WATCHOS" to build for watchOS Simulator (i386)
#
#Additional Options
#-DENABLE_BITCODE=(BOOL) - Enabled by default, specify FALSE or 0 to disable bitcode
#-DENABLE_ARC=(BOOL) - Enabled by default, specify FALSE or 0 to disable ARC
#-DENABLE_VISIBILITY=(BOOL) - Disabled by default, specify TRUE or 1 to enable symbol visibility support
#-DIOS_ARCH=(STRING) - Valid values are: armv7, armv7s, arm64, arm64e, i386, x86_64, armv7k, arm64_32. By default it will build for all valid architectures based on -DIOS_PLATFORM (see above)
#==========================================================================================

CLEARSCRIPT_V8_BUILD_DIR=${CLEARSCRIPT_V8_SRC_DIR}/build/iOS
cmake -DCMAKE_TOOLCHAIN_FILE=${CLEARSCRIPT_V8_SRC_DIR}/cmake/ios.toolchain.cmake -DPLATFORM=OS64COMBINED -Tbuildsystem=1 -GXcode -S ${CLEARSCRIPT_V8_SRC_DIR} -B ${CLEARSCRIPT_V8_BUILD_DIR}
cmake --build ${CLEARSCRIPT_V8_BUILD_DIR} --config Release --target install
