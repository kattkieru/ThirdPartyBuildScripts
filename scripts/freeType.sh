set -e

THIRDPARTY="$FABRIC_SCENE_GRAPH_DIR/ThirdParty"
OS="$FABRIC_BUILD_OS"
ARCH="$FABRIC_BUILD_ARCH"
TYPE="$FABRIC_BUILD_TYPE"
BASEPATH="$(sh ./_getbasepath.sh)"

VERSION=2.7
SRC="$(pwd)/src/freetype2"
if [ ! -d "$SRC" ]; then
  mkdir -p "$(pwd)/src"
  cd src
  git clone http://git.sv.nongnu.org/r/freetype/freetype2.git
  cd ..
fi

BUILD_DIR=build/freetype2-$TYPE-$ARCH
mkdir -p $BUILD_DIR
cd $BUILD_DIR


INSTALL_DIR=$BASEPATH/freetype2/$VERSION

mkdir -p "$INSTALL_DIR/lib"
mkdir -p "$INSTALL_DIR/include/freetype2"
mkdir -p "$INSTALL_DIR/include/freetype2/freetype"

if [ "$OS" = "Windows" ]; then
  CXXFLAGS=" /D_SCL_SECURE_NO_WARNINGS=1 /MP "

  CXXFLAGS="$CXXFLAGS" \
  cmake . -G "Visual Studio 12 Win64" \
    -DCMAKE_CXX_FLAGS_DEBUG:STRING=" /D_DEBUG /MTd /Zi /Ob0 /Od /RTC1 " \
    -DCMAKE_CXX_FLAGS_RELEASE:STRING=" /MT /O2 /Ob2 /D NDEBUG " \
    -DCMAKE_C_FLAGS_DEBUG:STRING=" /D_DEBUG /MTd /Zi /Ob0 /Od /RTC1 " \
    -DCMAKE_C_FLAGS_RELEASE:STRING=" /MT /O2 /Ob2 /D NDEBUG " \
    -DVERBOSE=1 \
    -DSTOP_ON_WARNING=0 \
    -DLINKSTATIC=1 \
    -DBUILDSTATIC=1 \
    $SRC

   MSBuild.exe freetype.sln //p:Configuration=$TYPE //t:freetype
   cp -a $TYPE/*.lib $INSTALL_DIR/lib
elif [ "$OS" = "Darwin" ]; then 
  CFLAGS=" -fPIC -m64 " \
  CXXFLAGS=" -fPIC -m64 " \
  MACOSX_DEPLOYMENT_TARGET=10.9 \
  cmake . \
    -DVERBOSE=1 \
    -DSTOP_ON_WARNING=0 \
    -DLINKSTATIC=1 \
    -DBUILDSTATIC=1 \
    -DZLIB_INCLUDE_DIR="" \
    -DZLIB_LIBRARY_DEBUG="" \
    -DZLIB_LIBRARY_RELEASE="" \
    -DBZIP2_INCLUDE_DIR="" \
    -DBZIP2_LIBRARY_DEBUG="" \
    -DBZIP2_LIBRARY_RELEASE="" \
    -DHARFBUZZ_INCLUDE_DIRS="" \
    -DHARFBUZZ_LIBRARIES="" \
    $SRC

  make -j8 freetype VERBOSE=1
  cp -a *.a $INSTALL_DIR/lib
else  
  CFLAGS=" -fPIC -m64 " \
  CXXFLAGS=" -fPIC -m64 " \
  cmake . \
    -DVERBOSE=1 \
    -DSTOP_ON_WARNING=0 \
    -DLINKSTATIC=1 \
    -DBUILDSTATIC=1 \
    -DZLIB_INCLUDE_DIR="" \
    -DZLIB_LIBRARY_DEBUG="" \
    -DZLIB_LIBRARY_RELEASE="" \
    -DBZIP2_INCLUDE_DIR="" \
    -DBZIP2_LIBRARY_DEBUG="" \
    -DBZIP2_LIBRARY_RELEASE="" \
    $SRC

  make -j8 freetype VERBOSE=1
  cp -a *.a $INSTALL_DIR/lib
fi

cp -r $SRC/include/freetype/* "$INSTALL_DIR/include/freetype2/freetype"
cp -r $SRC/include/*.h "$INSTALL_DIR/include/freetype2"
