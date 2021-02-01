# ClearScript.V8.Native
#
#
cmake_minimum_required (VERSION 3.8)

set(CMAKE_CXX_STANDARD 17)

if(WIN32 AND NOT ANDROID)
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MTd")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
elseif(APPLE)
    if(IOS)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fembed-bitcode -fno-rtti -faligned-new")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fembed-bitcode -fno-rtti -faligned-new")
    else()
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-rtti")
    endif()
elseif(ANDROID)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-rtti")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-rtti")
endif()


set(CLEARSCRIPT_SRC_DIR "${PROJECT_SOURCE_DIR}/../ClearScriptV8")
set(LOCAL_V8_TARGETS_DIR "${PROJECT_SOURCE_DIR}/3rdparty/targets")
set(V8_BUILD_TARGETS_DIR "${PROJECT_SOURCE_DIR}/../V8/build/targets")
set(TARGET_NAME ClearScript.V8.Native)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX ${PROJECT_SOURCE_DIR}/build/targets CACHE PATH "Install path" FORCE)
endif(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)

if(WIN32)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        # 64 bits
        set(V8_LIBS_DIR "${V8_BUILD_TARGETS_DIR}/windows_x86_64")
        set(LOCAL_V8_LIBS_DIR "${LOCAL_V8_TARGETS_DIR}/windows_x86_64")

        set(INSTALL_DIR "x86_64")
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
        # 32 bits
        set(V8_LIBS_DIR "${V8_BUILD_TARGETS_DIR}/windows_x86")
        set(LOCAL_V8_LIBS_DIR "${LOCAL_V8_TARGETS_DIR}/windows_x86")

        set(INSTALL_DIR "x86")
    endif()

    link_libraries(dbghelp winmm)
elseif(APPLE)
    if(IOS)
        set(V8_LIBS_DIR "${V8_BUILD_TARGETS_DIR}/iOS")
        set(LOCAL_V8_LIBS_DIR "${LOCAL_V8_TARGETS_DIR}/iOS")

        set(INSTALL_DIR "iOS")
    else()
        set(V8_LIBS_DIR "${V8_BUILD_TARGETS_DIR}/macOS")
        set(LOCAL_V8_LIBS_DIR "${LOCAL_V8_TARGETS_DIR}/macOS")

        set(INSTALL_DIR "macOS")
    endif()
elseif(ANDROID)
    if(ANDROID_ABI STREQUAL "armeabi-v7a")
        set(V8_LIBS_DIR "${V8_BUILD_TARGETS_DIR}/android_armeabi-v7a")
        set(LOCAL_V8_LIBS_DIR "${LOCAL_V8_TARGETS_DIR}/android_armeabi-v7a")

        set(INSTALL_DIR "Android/libs/armeabi-v7a")
    elseif(ANDROID_ABI STREQUAL "arm64-v8a")
        set(V8_LIBS_DIR "${V8_BUILD_TARGETS_DIR}/android_arm64-v8a")
        set(LOCAL_V8_LIBS_DIR "${LOCAL_V8_TARGETS_DIR}/android_arm64-v8a")

        set(INSTALL_DIR "Android/libs/arm64-v8a")
    elseif(ANDROID_ABI STREQUAL "x86")
        set(V8_LIBS_DIR "${V8_BUILD_TARGETS_DIR}/android_x86")
        set(LOCAL_V8_LIBS_DIR "${LOCAL_V8_TARGETS_DIR}/android_x86")

        set(INSTALL_DIR "Android/libs/x86")
    elseif(ANDROID_ABI STREQUAL "x86_64")
        set(V8_LIBS_DIR "${V8_BUILD_TARGETS_DIR}/android_x86_64")
        set(LOCAL_V8_LIBS_DIR "${LOCAL_V8_TARGETS_DIR}/android_x86_64")

        set(INSTALL_DIR "Android/libs/x86_64")
    endif()

    link_libraries(log)
endif()

include_directories(${V8_LIBS_DIR}/include ${LOCAL_V8_LIBS_DIR}/include)
link_directories(${V8_LIBS_DIR}/lib ${LOCAL_V8_LIBS_DIR}/lib)
link_libraries(v8_monolith)

set (CLEARSCRIPT_V8_INC 
    ${CLEARSCRIPT_SRC_DIR}/ClearScriptV8Native.h
    ${CLEARSCRIPT_SRC_DIR}/CommonPlatform.h
    ${CLEARSCRIPT_SRC_DIR}/HighResolutionClock.h
    ${CLEARSCRIPT_SRC_DIR}/HostException.h
    ${CLEARSCRIPT_SRC_DIR}/HostObjectHolder.h
    ${CLEARSCRIPT_SRC_DIR}/HostObjectHolderImpl.h
    ${CLEARSCRIPT_SRC_DIR}/HostObjectUtil.h
    ${CLEARSCRIPT_SRC_DIR}/IV8Entity.h
    ${CLEARSCRIPT_SRC_DIR}/Mutex.h
    ${CLEARSCRIPT_SRC_DIR}/NativePlatform.h
    ${CLEARSCRIPT_SRC_DIR}/RefCount.h
    ${CLEARSCRIPT_SRC_DIR}/SharedPtr.h
    ${CLEARSCRIPT_SRC_DIR}/StdString.h
    ${CLEARSCRIPT_SRC_DIR}/Timer.h
    ${CLEARSCRIPT_SRC_DIR}/V8CacheType.h
    ${CLEARSCRIPT_SRC_DIR}/V8Context.h
    ${CLEARSCRIPT_SRC_DIR}/V8ContextImpl.h
    ${CLEARSCRIPT_SRC_DIR}/V8DocumentInfo.h
    ${CLEARSCRIPT_SRC_DIR}/V8Exception.h
    ${CLEARSCRIPT_SRC_DIR}/V8Isolate.h
    ${CLEARSCRIPT_SRC_DIR}/V8IsolateImpl.h
    ${CLEARSCRIPT_SRC_DIR}/V8ObjectHelpers.h
    ${CLEARSCRIPT_SRC_DIR}/V8ObjectHolder.h
    ${CLEARSCRIPT_SRC_DIR}/V8ObjectHolderImpl.h
    ${CLEARSCRIPT_SRC_DIR}/V8Platform.h
    ${CLEARSCRIPT_SRC_DIR}/V8ScriptHolder.h
    ${CLEARSCRIPT_SRC_DIR}/V8ScriptHolderImpl.h
    ${CLEARSCRIPT_SRC_DIR}/V8SplitProxyManaged.h
    ${CLEARSCRIPT_SRC_DIR}/V8SplitProxyNative.h
    ${CLEARSCRIPT_SRC_DIR}/V8Value.h
    ${CLEARSCRIPT_SRC_DIR}/V8WeakContextBinding.h
    ${CLEARSCRIPT_SRC_DIR}/WeakRef.h
)

if(WIN32)
    set(CLEARSCRIPT_V8_SRC  ${CLEARSCRIPT_SRC_DIR}/HighResolutionClock.Windows.cpp)
else()
    set(CLEARSCRIPT_V8_SRC  ${CLEARSCRIPT_SRC_DIR}/HighResolutionClock.Unix.cpp)
endif()

set (CLEARSCRIPT_V8_SRC
    ${CLEARSCRIPT_V8_SRC}
    ${CLEARSCRIPT_SRC_DIR}/HostObjectHolderImpl.cpp
    ${CLEARSCRIPT_SRC_DIR}/HostObjectUtil.cpp
    ${CLEARSCRIPT_SRC_DIR}/Mutex.cpp
    ${CLEARSCRIPT_SRC_DIR}/RefCount.cpp
    ${CLEARSCRIPT_SRC_DIR}/StdString.cpp
    ${CLEARSCRIPT_SRC_DIR}/V8Context.cpp
    ${CLEARSCRIPT_SRC_DIR}/V8ContextImpl.cpp
    ${CLEARSCRIPT_SRC_DIR}/V8Isolate.cpp
    ${CLEARSCRIPT_SRC_DIR}/V8IsolateImpl.cpp
    ${CLEARSCRIPT_SRC_DIR}/V8ObjectHelpers.cpp
    ${CLEARSCRIPT_SRC_DIR}/V8ObjectHolderImpl.cpp
    ${CLEARSCRIPT_SRC_DIR}/V8ScriptHolderImpl.cpp
    ${CLEARSCRIPT_SRC_DIR}/V8SplitProxyManaged.cpp
    ${CLEARSCRIPT_SRC_DIR}/V8SplitProxyNative.cpp
)

#https://cmake.org/cmake/help/latest/command/install.html#installing-targets
#
# -g -S -d --strip-debug: Remove debugging symbols only
# --strip-unneeded: Remove all symbols that are not needed for relocation processing
#

if(APPLE)
    if(IOS)        
        #set(CMAKE_OSX_ARCHITECTURES "$(ARCHS_STANDARD)")
        
        add_library (${TARGET_NAME} STATIC  ${CLEARSCRIPT_V8_SRC} ${CLEARSCRIPT_V8_INC})

        set_xcode_property (${TARGET_NAME} IPHONEOS_DEPLOYMENT_TARGET "9.0" "all")

    add_custom_command(TARGET ${TARGET_NAME} POST_BUILD 
            COMMAND ${CMAKE_STRIP} -S $<TARGET_FILE:${TARGET_NAME}>
            COMMENT "Strip debug symbols done on final binary.")

        install(TARGETS ${TARGET_NAME} DESTINATION ${INSTALL_DIR})
        install(FILES ${V8_LIBS_DIR}/lib/libv8_monolith.a DESTINATION ${INSTALL_DIR})
    else()        
        #set(CMAKE_OSX_ARCHITECTURES "$(ARCHS_STANDARD_64_BIT)")
        set(CMAKE_OSX_ARCHITECTURES "x86_64")

        add_library (${TARGET_NAME} MODULE ${CLEARSCRIPT_V8_SRC} ${CLEARSCRIPT_V8_INC})

        #set(MACOS_BUNDLE_BUNDLE_NAME ClearScript.V8.Native)  # 设置bundle名字
        set_target_properties(${TARGET_NAME} PROPERTIES BUNDLE TRUE ) # 生成bundle

        install(TARGETS ${TARGET_NAME} DESTINATION ${INSTALL_DIR})
    endif()
    
elseif(ANDROID)    
    add_library (${TARGET_NAME} SHARED  ${CLEARSCRIPT_V8_SRC} ${CLEARSCRIPT_V8_INC})

    #add_custom_command(TARGET ${TARGET_NAME} POST_BUILD 
    #    COMMAND ${ANDROID_TOOLCHAIN_PREFIX}strip -g -S -d --strip-unneeded --verbose $<TARGET_FILE:${TARGET_NAME}>
    #    COMMENT "Strip debug symbols done on final binary.")
    
    set_target_properties(${TARGET_NAME} PROPERTIES LINK_FLAGS " -s ")

    install(TARGETS ${TARGET_NAME} DESTINATION ${INSTALL_DIR})
else(WIN32)
    add_library (${TARGET_NAME} SHARED  ${CLEARSCRIPT_V8_SRC} ${CLEARSCRIPT_V8_INC})
    
    install(TARGETS ${TARGET_NAME} DESTINATION ${INSTALL_DIR})
endif()
