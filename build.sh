#!/bin/bash
# Self-contained build: MNN native runtime (libMNN.so) then the Android app.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

# Gradle 8.9 requires JDK 17+; the Android Studio bundled JBR (JDK 21) satisfies it.
if [ -f "C:/Program Files/Android/Android Studio2/jbr/bin/java.exe" ]; then
    export JAVA_HOME="C:/Program Files/Android/Android Studio2/jbr"
    export PATH="$JAVA_HOME/bin:$PATH"
fi

# 1. Build libMNN.so into build_64/lib (idempotent once built).
if [ ! -f "$ROOT/build_64/lib/libMNN.so" ]; then
    "$ROOT/build_mnn.sh"
fi

# 2. Package the Hexagon FastRPC stub + DSP skel into the APK when available.
#    These are built separately with the Qualcomm Hexagon SDK and are not tracked
#    in git; when absent we skip and the hexagon backend stays disabled at runtime.
HEXAGON_OPS_DIR="${HEXAGON_OPS_DIR:-$ROOT/source/backend/hexagon/htp-ops-lib/outputs}"
JNI_DIR="$ROOT/app/src/main/jniLibs/arm64-v8a"
if ls "$HEXAGON_OPS_DIR"/libMNN_htpops*.so >/dev/null 2>&1; then
    mkdir -p "$JNI_DIR"
    cp -f "$HEXAGON_OPS_DIR"/libMNN_htpops*.so "$JNI_DIR"/
    echo "Hexagon libs packaged from $HEXAGON_OPS_DIR:"
    ls -1 "$JNI_DIR"/libMNN_htpops*.so
else
    echo "Hexagon libs not found; skipping (hexagon backend disabled at runtime)."
fi

# 3. Build the Android app.
cd "$ROOT"
./gradlew assembleStandardDebug