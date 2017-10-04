set -e
BASEPATH=$(sh ./_getbasepath.sh)
sh _default.sh hdf5 1.8.13 "-DBUILD_SHARED_LIBS:BOOL=OFF -DHDF5_BUILD_HL_LIB:BOOL=ON"
if [ "$FABRIC_BUILD_OS" = "Windows" ]; then
  mv ../$BASEPATH/hdf5/1.8.13/lib/libhdf5.lib \
    ../$BASEPATH/hdf5/1.8.13/lib/hdf5.lib
  mv ../$BASEPATH/hdf5/1.8.13/lib/libhdf5_hl.lib \
    ../$BASEPATH/hdf5/1.8.13/lib/hdf5_hl.lib
fi

