set -e

PKG="tiff"
VERSION="3.9.7"

THIRDPARTY="$FABRIC_SCENE_GRAPH_DIR/ThirdParty"
OS="$FABRIC_BUILD_OS"
ARCH="$FABRIC_BUILD_ARCH"
TYPE="$FABRIC_BUILD_TYPE"
BASEPATH="$(sh ./_getbasepath.sh)"

BUILD_DIR=build/$PKG-$TYPE-$ARCH
mkdir -p $BUILD_DIR
cd $BUILD_DIR
tar -xzf $THIRDPARTY/SourcePackages/$PKG-$VERSION.tar.gz
if [ "$OS" = "Windows" ]; then
  patch -p0 <../../tiff.patch
fi
cd $PKG-$VERSION

INSTALL=$BASEPATH/$PKG/$VERSION
mkdir -p $INSTALL
mkdir -p $INSTALL/lib
mkdir -p $INSTALL/include

if [ "$OS" = "Windows" ]; then
  cd libtiff
  nmake //f Makefile.vc
  cd -
  cd port
  nmake //f Makefile.vc
  cd -
  cp libtiff/*.lib port/*.lib $INSTALL/lib
elif [ "$OS" = "Darwin" ]; then
  CFLAGS="-fPIC -m64 -mmacosx-version-min=10.9" \
  CXXFLAGS="-fPIC -m64 -mmacosx-version-min=10.9" \
  LDFALGS="-mmacosx-version-min=10.9" \
  ./configure
  cd port
  make -j8
  cd -
  cd libtiff
  make -j8
  cd -
  cp libtiff/.libs/*.a port/.libs/*.a $INSTALL/lib
else
  CFLAGS="-fPIC -m64 " CXXFLAGS="-fPIC -m64" ./configure
  cd port
  make -j8
  cd -
  cd libtiff
  make -j8
  cd -
  cp libtiff/.libs/*.a port/.libs/*.a $INSTALL/lib
fi

cp libtiff/*.h $INSTALL/include

