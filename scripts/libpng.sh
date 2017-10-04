set -e
BASEPATH=$(sh ./_getbasepath.sh)
if [ "$FABRIC_BUILD_OS" = "Windows" ]; then
  sh _default.sh libpng 1.6.13 "-DZLIB_LIBRARY=$BASEPATH/../Release/zlib/1.2.8/lib/zlibstatic.lib \
    -DZLIB_INCLUDE_DIR=$BASEPATH/zlib/1.2.8/include"
else
  sh _default.sh libpng 1.6.13
fi

