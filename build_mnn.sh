#!/bin/bash
# Build the MNN ARM64 native runtime (libMNN.so) self-contained in this project.
# Produces: build_64/lib/libMNN.so  (+ installed public headers under build_64/include)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

CMAKE="C:/Users/jiangzhengquan/AppData/Local/Android/Sdk/cmake/3.22.1/bin/cmake.exe"
NINJA="C:/Users/jiangzhengquan/AppData/Local/Android/Sdk/cmake/3.22.1/bin/ninja.exe"
NDK="C:/Users/jiangzhengquan/AppData/Local/Android/Sdk/ndk/27.2.12479018"

BUILD_DIR="$ROOT/build_native"
INSTALL_ROOT="$ROOT/build_64"

"$CMAKE" -G Ninja \
  "-DCMAKE_MAKE_PROGRAM=$NINJA" \
  -DCMAKE_TOOLCHAIN_FILE="$NDK/build/cmake/android.toolchain.cmake" \
  -DCMAKE_BUILD_TYPE=Release \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-21 \
  -DANDROID_STL=c++_static \
  -DMNN_BUILD_FOR_ANDROID_COMMAND=ON \
  -DMNN_BUILD_SHARED_LIBS=ON \
  -DMNN_LOW_MEMORY=ON \
  -DMNN_BUILD_LLM=ON \
  -DMNN_SUPPORT_TRANSFORMER_FUSE=ON \
  -DMNN_ARM82=ON \
  -DMNN_USE_LOGCAT=ON \
  -DMNN_OPENCL=ON \
  -DMNN_BUILD_OPENCV=ON \
  -DMNN_IMGCODECS=ON \
  -DMNN_BUILD_AUDIO=ON \
  -DMNN_BUILD_DIFFUSION=ON \
  -DMNN_SEP_BUILD=OFF \
  -DMNN_HEXAGON=OFF \
  "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-z,max-page-size=16384" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_ROOT" \
  -S "$ROOT" -B "$BUILD_DIR"

"$NINJA" -C "$BUILD_DIR" -j4
"$NINJA" -C "$BUILD_DIR" install

echo "Native runtime built: $INSTALL_ROOT/lib/libMNN.so"