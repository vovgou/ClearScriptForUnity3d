#!/bin/bash

v8rev=8.8.278.14
#v8rev=8.9.202

V8_ROOT=$(pwd)
TARGETS_PATH=${V8_ROOT}/build/targets

if [ ! -d "build" ]; then
    mkdir build
fi

if [ ! -d "${TARGETS_PATH}" ]; then
    mkdir -p ${TARGETS_PATH}
fi

cd build

echo "Downloading Depot Tools ..."
echo ================================ 
git clone -q https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=$(pwd)/depot_tools:$PATH

echo "Downloading V8 and dependencies ..."
echo ================================ 
gclient config https://chromium.googlesource.com/v8/v8 >config.log
echo "target_os = ['android']" >> .gclient
gclient sync -r $v8rev >sync.log

echo "Applying patches ..."
cd v8 
git config user.name ClearScript 
git config user.email "ClearScript@microsoft.com" 
git apply --reject --ignore-whitespace ../../V8Patch.txt 2>applyV8Patch.log 
cd ..

echo "Install build deps for android"
echo ================================ 
sudo ./v8/build/install-build-deps-android.sh >install.log

ANDROID_TOOLCHAIN_BIN_DIR=${V8_ROOT}/build/v8/third_party/android_ndk/toolchains/llvm/prebuilt/linux-x86_64/bin

#ARCHES = "ia32"  "x64"  "arm" "arm64" "mipsel", "mips64el" "ppc" "ppc64" "s390" "s390x" "android_arm" "android_arm64"
build(){
    local ANDROID_ABI=$1    
    local MODE=$2

    #Builder Groups & Builder Name:https://github.com/v8/v8/blob/master/infra/mb/mb_config.pyl
    local BUILDER_GROUP="developer_default"
    if [[ $ANDROID_ABI == "armeabi-v7a" ]]; then
        if [[ $MODE == "debug" ]]; then
            local BUILDER_NAME="arm.debug"
        else
            local BUILDER_NAME="arm.release"
        fi
        local TARGET_CPU=arm
        local ANDROID_TOOLCHAIN_NAME=arm-linux-androideabi
    elif [[ $ANDROID_ABI == "arm64-v8a" ]]; then
        if [[ $MODE == "debug" ]]; then
            local BUILDER_NAME="arm64.debug"
        else
            local BUILDER_NAME="arm64.release"
        fi
        local TARGET_CPU=arm64
        local ANDROID_TOOLCHAIN_NAME=aarch64-linux-android
    elif [[ $ANDROID_ABI == "x86" ]]; then
        if [[ $MODE == "debug" ]]; then
            local BUILDER_NAME="ia32.debug"
        else
            local BUILDER_NAME="ia32.release"
        fi
        local TARGET_CPU=x86
        local ANDROID_TOOLCHAIN_NAME=i686-linux-android
    elif [[ $ANDROID_ABI == "x86_64" ]]; then
        if [[ $MODE == "debug" ]]; then
            local BUILDER_NAME="x64.debug"
        else
            local BUILDER_NAME="x64.release"
        fi
        local TARGET_CPU=x64
        local ANDROID_TOOLCHAIN_NAME=x86_64-linux-android
    fi

    local GN_ARGS="target_os=\"android\" target_cpu=\"${TARGET_CPU}\" v8_target_cpu=\"${TARGET_CPU}\" use_custom_libcxx_for_host=false use_custom_libcxx=false v8_enable_31bit_smis_on_64bit_arch=false symbol_level=1 strip_debug_info=false v8_enable_debugging_features=false"     
    if [[ $MODE == "debug" ]]; then
        GN_ARGS="${GN_ARGS} is_debug=true is_official_build=false android_unstripped_runtime_outputs=true"  
    elif [[ $MODE == "release" ]]; then
        GN_ARGS="${GN_ARGS} is_debug=false is_official_build=false android_unstripped_runtime_outputs=false"
    elif [[ $MODE == "official" ]]; then
        GN_ARGS="${GN_ARGS} is_debug=false is_official_build=true chrome_pgo_phase=0 android_unstripped_runtime_outputs=false"
    fi
    GN_ARGS="${GN_ARGS} v8_embedder_string=\"-ClearScript\" use_goma=false v8_enable_i18n_support=false v8_enable_pointer_compression=false v8_use_external_startup_data=false v8_monolithic=true v8_static_library=true "   
 
    local PLATFORM_NAME=android
    local BUILD_GEN_DIR=${TARGET_CPU}.${MODE}

    echo "Building V8(${ANDROID_ABI}) for Android ..."
    echo ================================  
    cd v8
    ./tools/dev/v8gen.py gen -m "${BUILDER_GROUP}" -b "${BUILDER_NAME}" "${BUILD_GEN_DIR}" -vv -- ${GN_ARGS}
    gn args --list out.gn/${BUILD_GEN_DIR} > ${TARGETS_PATH}/${PLATFORM_NAME}.${TARGET_CPU}.${MODE}.txt
    ninja -C out.gn/${BUILD_GEN_DIR} v8_monolith
    if [[ $MODE != "debug" ]]; then
        # -g -S -d --strip-debug: Remove debugging symbols only
        # --strip-unneeded: Remove all symbols that are not needed for relocation processing
        ${ANDROID_TOOLCHAIN_BIN_DIR}/${ANDROID_TOOLCHAIN_NAME}-strip -g -S -d --strip-debug --verbose out.gn/${BUILD_GEN_DIR}/obj/libv8_monolith.a
    fi
    cd ..

    mkdir -p ${TARGETS_PATH}/${PLATFORM_NAME}_${ANDROID_ABI}/lib
    cp  v8/out.gn/${BUILD_GEN_DIR}/obj/libv8_monolith.a ${TARGETS_PATH}/${PLATFORM_NAME}_${ANDROID_ABI}/lib/
    cp -r v8/include ${TARGETS_PATH}/${PLATFORM_NAME}_${ANDROID_ABI}/
}


#MODE:debug release official
build armeabi-v7a release
build arm64-v8a release
build x86 release
build x86_64 release


cp ../build_v8_android.sh ${TARGETS_PATH}/

cd ..


