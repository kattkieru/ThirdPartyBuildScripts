set -e

# [andrew 20140213] For Windows get the prebuilt binaries here:
# http://sourceforge.net/projects/boost/files/boost-binaries/

PKG="boost"
VERSION="1_55_0"
INSTALL_VERSION="1.55.0"

THIRDPARTY="$FABRIC_SCENE_GRAPH_DIR/ThirdParty"
OS="$FABRIC_BUILD_OS"
ARCH="$FABRIC_BUILD_ARCH"
TYPE="$FABRIC_BUILD_TYPE"
BASEPATH="$(sh ./_getbasepath.sh)"

if [ "$OS" = "Linux" ]; then
  echo "Make sure you're building this with gcc 4.1.2. Hit Enter to continue."
  read
fi

BUILD_DIR=build/$PKG-$TYPE-$ARCH
mkdir -p $BUILD_DIR
cd $BUILD_DIR
tar -xzf $THIRDPARTY/SourcePackages/boost_$VERSION.tar.bz2
if [ "$OS" = "Darwin" ]; then
  patch -p1 <$THIRDPARTY/scripts/boost.Darwin.patch
fi
cd boost_$VERSION

CFLAGS="-fPIC"
LINKFLAGS=""
if [ "$OS" = "Darwin" ]; then
  CFLAGS="$CFLAGS -mmacosx-version-min=10.9"
  LINKFLAGS="$LINKFLAGS -mmacosx-version-min=10.9"
fi

./bootstrap.sh --with-libraries=all --prefix=$BASEPATH/boost/$INSTALL_VERSION
./bjam -j8 link=static threading=multi variant=release cflags="$CFLAGS" linkflags="$LINKFLAGS" install

