set -e

THIRDPARTY="$FABRIC_SCENE_GRAPH_DIR/ThirdParty"
OS="$FABRIC_BUILD_OS"
ARCH="$FABRIC_BUILD_ARCH"
TYPE="$FABRIC_BUILD_TYPE"
BASEPATH="$(sh ./_getbasepath.sh)"

GIFLIB_VERSION=5.0.6
GIFLIB_SRC="$(pwd)/src/giflib-$GIFLIB_VERSION"
if [ ! -d "$GIFLIB_SRC" ]; then
  mkdir -p "$(pwd)/src"
  cd src
  tar -xjf $THIRDPARTY/SourcePackages/giflib-$GIFLIB_VERSION.tar.bz2
  if [ "$OS" == "Windows" ]; then
    cd "$GIFLIB_SRC"
    patch -p1 <../../giflib.patch
  fi
fi

cd $GIFLIB_SRC

if [ "$OS" = "Windows" ]; then
  MSBuild.exe giflib.sln //p:Configuration=Release //t:giflib
else
  CFLAGS="-fPIC -mmacosx-version-min=10.9" \
  LDFLAGS="-mmacosx-version-min=10.9" \
  ./configure && make -j8
fi

GIFLIB_INSTALL=$BASEPATH/giflib/$GIFLIB_VERSION
mkdir -p "$GIFLIB_INSTALL"
mkdir -p "$GIFLIB_INSTALL/lib"
mkdir -p "$GIFLIB_INSTALL/include"

if [ "$OS" = "Windows" ]; then
  cp x64/Release/giflib.lib "$GIFLIB_INSTALL/lib"
  sed -i 's/#include <stdbool.h>/\/\/#include <stdbool.h>/' lib/gif_lib.h
else
  cp lib/.libs/libgif.a "$GIFLIB_INSTALL/lib"
fi
cp lib/*.h "$GIFLIB_INSTALL/include"

