set -e
BASEPATH=$(sh ./_getbasepath.sh)
if [ "$FABRIC_BUILD_OS" = "Windows" ]; then
  sh _default.sh openexr 2.2.0 "-DBUILD_SHARED_LIBS:BOOL=OFF \
    -DZLIB_LIBRARY=$BASEPATH/../Release/zlib/1.2.8/lib/zlibstatic.lib \
    -DZLIB_INCLUDE_DIR=$BASEPATH/../Release/zlib/1.2.8/include \
    -DILMBASE_PACKAGE_PREFIX=$BASEPATH/ilmbase/2.2.0"
else
  sh _default.sh openexr 2.2.0 "-DBUILD_SHARED_LIBS:BOOL=OFF \
    -DILMBASE_PACKAGE_PREFIX=$BASEPATH/ilmbase/2.2.0"
fi
