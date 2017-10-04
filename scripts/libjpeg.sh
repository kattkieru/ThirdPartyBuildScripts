set -e

THIRDPARTY="$FABRIC_SCENE_GRAPH_DIR/ThirdParty"
OS="$FABRIC_BUILD_OS"
ARCH="$FABRIC_BUILD_ARCH"
TYPE="$FABRIC_BUILD_TYPE"
BASEPATH="$(sh ./_getbasepath.sh)"

PKG="libjpeg-turbo"
VERSION="1.3.1"

if [ "$OS" = "Windows" ]; then
  sh _default.sh $PKG $VERSION
elif [ "$OS" = "Darwin" ]; then
  BUILD_DIR=build/$PKG-$TYPE-$ARCH
  mkdir -p $BUILD_DIR
  cd $BUILD_DIR
  tar -xzf $THIRDPARTY/SourcePackages/$PKG-$VERSION.tar.gz
  cd $PKG-$VERSION
  ./configure \
    --host x86_64-apple-darwin \
    CFLAGS="-fPIC -mmacosx-version-min=10.9" \
    CXXFLAGS="-fPIC -mmacosx-version-min=10.9" \
    LDFLAGS="-mmacosx-version-min=10.9"
  make -j8

  INSTALL=$BASEPATH/$PKG/$VERSION
  mkdir -p $INSTALL
  mkdir -p $INSTALL/include
  mkdir -p $INSTALL/lib

  cp -a *.h $INSTALL/include/
  cp -a .libs/*.a $INSTALL/lib/
else
  BUILD_DIR=build/$PKG-$TYPE-$ARCH
  mkdir -p $BUILD_DIR
  cd $BUILD_DIR
  tar -xzf $THIRDPARTY/SourcePackages/$PKG-$VERSION.tar.gz
  cd $PKG-$VERSION
  CFLAGS="-fPIC -m64 " CXXFLAGS="-fPIC -m64" ./configure
  make -j8

  INSTALL=$BASEPATH/$PKG/$VERSION
  mkdir -p $INSTALL
  mkdir -p $INSTALL/include
  mkdir -p $INSTALL/lib

  cp -a *.h $INSTALL/include/
  cp -a .libs/*.a $INSTALL/lib/
fi

