# Darknet External Project
#
# Required symbols are:
#   VIAME_BUILD_PREFIX - where packages are built
#   VIAME_BUILD_INSTALL_PREFIX - directory install target
#   VIAME_PACKAGES_DIR - location of git submodule packages
#   VIAME_ARGS_COMMON -
##

set( VIAME_PROJECT_LIST ${VIAME_PROJECT_LIST} darknet )

if( VIAME_ENABLE_CUDA )
  string( REPLACE "." "" DARKNET_ARCHITECTURES "${CUDA_ARCHITECTURES}" )
  FormatPassdowns( "CUDA" VIAME_DARKNET_CUDA_FLAGS )
  set( VIAME_DARKNET_CUDA_FLAGS
       ${VIAME_DARKNET_CUDA_FLAGS}
       -DCUDAToolkit_ROOT:PATH=${CUDA_TOOLKIT_ROOT_DIR}
       -DCMAKE_CUDA_COMPILER:PATH=${CUDA_NVCC_EXECUTABLE}
       -DCMAKE_CUDA_ARCHITECTURES:STRING:${DARKNET_ARCHITECTURES} )
endif()

if( VIAME_ENABLE_CUDNN )
  FormatPassdowns( "CUDNN" VIAME_DARKNET_CUDNN_FLAGS )
endif()

if( VIAME_FORCE_CUDA_CSTD98 )
  set( DARKNET_CXXFLAGS_OVERRIDE
    -DCMAKE_CXX_FLAGS=-std=c++98 )
else()
  set( DARKNET_CXXFLAGS_OVERRIDE )
endif()

ExternalProject_Add(darknet
  DEPENDS fletch
  PREFIX ${VIAME_BUILD_PREFIX}
  SOURCE_DIR ${VIAME_PACKAGES_DIR}/darknet
  USES_TERMINAL_BUILD 1
  CMAKE_GENERATOR ${gen}
  CMAKE_CACHE_ARGS
    ${VIAME_ARGS_COMMON}
    ${VIAME_ARGS_fletch}
    ${VIAME_DARKNET_CUDA_FLAGS}
    ${VIAME_DARKNET_CUDNN_FLAGS}
    ${DARKNET_CXXFLAGS_OVERRIDE}
    -DBUILD_SHARED_LIBS:BOOL=ON
    -DBUILD_AS_CPP:BOOL=ON
    -DBUILD_USELIB_TRACK:BOOL=OFF
    -DENABLE_CUDA:BOOL=${VIAME_ENABLE_CUDA}
    -DENABLE_CUDNN:BOOL=${VIAME_ENABLE_CUDNN}
    -DENABLE_OPENCV:BOOL=${VIAME_ENABLE_OPENCV}
    -DCMAKE_INSTALL_PREFIX:PATH=${VIAME_BUILD_INSTALL_PREFIX}
    -DINSTALL_BIN_DIR:PATH=${VIAME_BUILD_INSTALL_PREFIX}/bin
    -DINSTALL_LIB_DIR:PATH=${VIAME_BUILD_INSTALL_PREFIX}/lib
  INSTALL_DIR ${VIAME_BUILD_INSTALL_PREFIX}
  )

if( VIAME_FORCEBUILD )
ExternalProject_Add_Step(darknet forcebuild
  COMMAND ${CMAKE_COMMAND}
    -E remove ${VIAME_BUILD_PREFIX}/src/darknet-stamp/darknet-build
  COMMENT "Removing build stamp file for build update (forcebuild)."
  DEPENDEES configure
  DEPENDERS build
  ALWAYS 1
  )
endif()

set( VIAME_ARGS_darknet
  -Ddarknet_DIR:PATH=${VIAME_BUILD_PREFIX}/src/darknet-build
  )
