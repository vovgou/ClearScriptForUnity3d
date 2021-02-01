#!/bin/bash

#v8rev=8.7.220.25
v8rev=8.8.278.14
#MODE:debug release official
MODE=release
ARCH_LIST=("macOS" "iOS")
#ARCH_LIST=("macOS")

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

echo Downloading V8 and dependencies ...
echo ================================ 
gclient config https://chromium.googlesource.com/v8/v8 >config.log
echo "target_os = ['mac','ios']" >> .gclient
gclient sync -r $v8rev >sync.log

echo "Applying patches ..."
cd v8 
git config user.name ClearScript 
git config user.email "ClearScript@microsoft.com" 
git apply --reject --ignore-whitespace ../../V8Patch.txt 2>applyV8Patch.log 
cd ..

if [[ "${ARCH_LIST[@]}"  =~ "macOS" ]]; then
    echo "Building V8(x64) for MacOS ..."
    echo ================================ 
    cd v8
    
    PLATFORM_NAME=macOS
    BUILDER_GROUP="developer_default"
    if [[ $MODE == "debug" ]]; then
        BUILDER_NAME="x64.debug"
    else
        BUILDER_NAME="x64.release"
    fi

    TARGET_CPU=x64

    BUILD_GEN_DIR=${TARGET_CPU}.${MODE}

    GN_ARGS="target_os=\"mac\" target_cpu=\"${TARGET_CPU}\" v8_target_cpu=\"${TARGET_CPU}\" use_custom_libcxx = false"
    if [[ $MODE == "debug" ]]; then
        GN_ARGS="${GN_ARGS} is_debug=true is_official_build=false"
    elif [[ $MODE == "release" ]]; then
        GN_ARGS="${GN_ARGS} is_debug=false is_official_build=false symbol_level=0 strip_debug_info=true v8_enable_debugging_features=false" 
    elif [[ $MODE == "official" ]]; then
        GN_ARGS="${GN_ARGS} is_debug=false is_official_build=true chrome_pgo_phase=0 symbol_level=0  strip_debug_info=true v8_enable_debugging_features=false"
    fi
    GN_ARGS="${GN_ARGS} v8_embedder_string=\"-ClearScript\" use_goma=false is_component_build=false v8_enable_i18n_support=false v8_enable_pointer_compression=false v8_use_external_startup_data=false v8_monolithic=true treat_warnings_as_errors=false"

    ./tools/dev/v8gen.py gen -m "${BUILDER_GROUP}" -b "${BUILDER_NAME}" ${BUILD_GEN_DIR} -vv -- ${GN_ARGS}
    gn args --list out.gn/${BUILD_GEN_DIR} > ${TARGETS_PATH}/${PLATFORM_NAME}.${TARGET_CPU}.${MODE}.txt
    ninja -C out.gn/${BUILD_GEN_DIR} v8_monolith
    #strip -S out.gn/${BUILD_GEN_DIR}/obj/libv8_monolith.a
    cd ..

    mkdir -p ${TARGETS_PATH}/${PLATFORM_NAME}/lib
    cp  v8/out.gn/${BUILD_GEN_DIR}/obj/libv8_monolith.a ${TARGETS_PATH}/${PLATFORM_NAME}/lib/ 
    cp -r v8/include ${TARGETS_PATH}/${PLATFORM_NAME}/
fi

rm -rf v8/out.gn/*

#if [[ "${ARCH_LIST[@]}"  =~ "iOS" ]]; then
    #echo "Building V8(arm64) for IOS ..."  
    #echo ================================  
    #PLATFORM_NAME=iOS
    #is_debug=$isdebug is_official_build=$isofficial target_os=\"ios\" target_cpu=\"arm64\" v8_target_cpu=\"arm64\" is_component_build=false v8_embedder_string=\"-ClearScript\" v8_enable_i18n_support=false v8_enable_pointer_compression=false ios_enable_code_signing=false v8_use_external_startup_data=false v8_monolithic=true strip_debug_info=true symbol_level=0 v8_enable_debugging_features=false treat_warnings_as_errors=false 
#fi

if [[ "${ARCH_LIST[@]}"  =~ "iOS" ]]; then
    echo "Building V8(x64 bitcode) for IOS ..." 
    echo ================================  
    cd v8

    PLATFORM_NAME=iOS
    BUILDER_GROUP="developer_default"
    if [[ $MODE == "debug" ]]; then
        BUILDER_NAME="x64.debug"
    else
        BUILDER_NAME="x64.release"
    fi

    TARGET_CPU=x64

    BUILD_GEN_DIR=${TARGET_CPU}.${MODE}

    GN_ARGS="target_os=\"ios\" target_cpu=\"${TARGET_CPU}\" v8_target_cpu=\"${TARGET_CPU}\" use_custom_libcxx = false use_xcode_clang=true enable_ios_bitcode=true ios_enable_code_signing=false ios_deployment_target=9"    
    if [[ $MODE == "debug" ]]; then
        GN_ARGS="${GN_ARGS} is_debug=true is_official_build=false"
    elif [[ $MODE == "release" ]]; then
        GN_ARGS="${GN_ARGS} is_debug=false is_official_build=false symbol_level=0  strip_debug_info=true v8_enable_debugging_features=false"
    elif [[ $MODE == "official" ]]; then
        GN_ARGS="${GN_ARGS} is_debug=false is_official_build=true chrome_pgo_phase=0 symbol_level=0  strip_debug_info=true v8_enable_debugging_features=false"
    fi
    GN_ARGS="${GN_ARGS} v8_embedder_string=\"-ClearScript\" use_goma=false is_component_build=false v8_enable_i18n_support=false v8_enable_pointer_compression=false v8_use_external_startup_data=false v8_monolithic=true treat_warnings_as_errors=false"
    
    ./tools/dev/v8gen.py gen -m "${BUILDER_GROUP}" -b "${BUILDER_NAME}" "${BUILD_GEN_DIR}" -vv -- ${GN_ARGS}
    gn args --list out.gn/${BUILD_GEN_DIR} > ${TARGETS_PATH}/${PLATFORM_NAME}.${TARGET_CPU}.${MODE}.txt
    ninja -C out.gn/${BUILD_GEN_DIR} v8_monolith
    #if [[ $MODE != "debug" ]]; then
    #    strip -S out.gn/${BUILD_GEN_DIR}/obj/libv8_monolith.a
    #fi
    cd ..

    LIBS="v8/out.gn/${BUILD_GEN_DIR}/obj/libv8_monolith.a"

    echo "Building V8(arm64 bitcode) for IOS ..." 
    echo ================================  
    cd v8

    PLATFORM_NAME=iOS
    BUILDER_GROUP="developer_default"
    if [[ $MODE == "debug" ]]; then
        BUILDER_NAME="arm64.debug"
    else
        BUILDER_NAME="arm64.release"
    fi

    TARGET_CPU=arm64

    BUILD_GEN_DIR=${TARGET_CPU}.${MODE}

    GN_ARGS="target_os=\"ios\" target_cpu=\"${TARGET_CPU}\" v8_target_cpu=\"${TARGET_CPU}\" use_custom_libcxx = false use_xcode_clang=true enable_ios_bitcode=true ios_enable_code_signing=false ios_deployment_target=9"    
    if [[ $MODE == "debug" ]]; then
        GN_ARGS="${GN_ARGS} is_debug=true is_official_build=false"
    elif [[ $MODE == "release" ]]; then
        GN_ARGS="${GN_ARGS} is_debug=false is_official_build=false symbol_level=0  strip_debug_info=true v8_enable_debugging_features=false"
    elif [[ $MODE == "official" ]]; then
        GN_ARGS="${GN_ARGS} is_debug=false is_official_build=true chrome_pgo_phase=0 symbol_level=0  strip_debug_info=true v8_enable_debugging_features=false"
    fi
    GN_ARGS="${GN_ARGS} v8_embedder_string=\"-ClearScript\" use_goma=false is_component_build=false v8_enable_i18n_support=false v8_enable_pointer_compression=false v8_use_external_startup_data=false v8_monolithic=true treat_warnings_as_errors=false"
   
    ./tools/dev/v8gen.py gen -m "${BUILDER_GROUP}" -b "${BUILDER_NAME}" ${BUILD_GEN_DIR} -vv -- ${GN_ARGS}
    gn args --list out.gn/${BUILD_GEN_DIR} > ${TARGETS_PATH}/${PLATFORM_NAME}.${TARGET_CPU}.${MODE}.txt
    ninja -C out.gn/${BUILD_GEN_DIR} v8_monolith
    #if [[ $MODE != "debug" ]]; then
    #    strip -S out.gn/${BUILD_GEN_DIR}/obj/libv8_monolith.a
    #fi
    cd ..

    LIBS="${LIBS} v8/out.gn/${BUILD_GEN_DIR}/obj/libv8_monolith.a"

    mkdir -p ${TARGETS_PATH}/${PLATFORM_NAME}/lib
    lipo -create ${LIBS} -output ${TARGETS_PATH}/${PLATFORM_NAME}/lib/libv8_monolith.a

    cp -r v8/include ${TARGETS_PATH}/${PLATFORM_NAME}/

fi

cp ../build_v8_apple.sh ${TARGETS_PATH}/

cd ..
