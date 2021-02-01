#!/bin/bash

if [ ! -d "$ANDROID_NDK" ]; then
    echo "Not found The environment variable ANDROID_NDK."
    exit 1
fi

CLEARSCRIPT_V8_SRC_DIR=$(pwd)/..

build(){
    ANDROID_SDK_API_LEVEL=$1
    ANDROID_ABI=$2

    echo "Building ClearScript.V8.Native(Android ${ANDROID_ABI}) ..."
    echo ================================     
    CLEARSCRIPT_V8_BUILD_DIR=${CLEARSCRIPT_V8_SRC_DIR}/build/Android.${ANDROID_ABI}
    cmake -DANDROID_ABI=${ANDROID_ABI} -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON -H. -DCMAKE_TOOLCHAIN_FILE=${ANDROID_NDK}/build/cmake/android.toolchain.cmake -DANDROID_NATIVE_API_LEVEL=${ANDROID_SDK_API_LEVEL} -DANDROID_TOOLCHAIN=clang -S ${CLEARSCRIPT_V8_SRC_DIR} -B ${CLEARSCRIPT_V8_BUILD_DIR}
    cmake --build ${CLEARSCRIPT_V8_BUILD_DIR} --config Release --target install
}

build 16 armeabi-v7a
build 21 arm64-v8a
build 16 x86
build 21 x86_64




