set -e

PKG="$1"
VERSION="$2"

THIRDPARTY="$FABRIC_SCENE_GRAPH_DIR/ThirdParty"
OS="$FABRIC_BUILD_OS"
ARCH="$FABRIC_BUILD_ARCH"
TYPE="$FABRIC_BUILD_TYPE"
BASEPATH="$(sh ./_getbasepath.sh)"

SRC="$(pwd)/src/$PKG-$VERSION"
if [ ! -d "$SRC" ]; then
  mkdir -p "$(pwd)/src"
  cd src
  if [ -f "$THIRDPARTY/SourcePackages/$PKG-$VERSION.tar.gz" ]; then
    tar -xzf $THIRDPARTY/SourcePackages/$PKG-$VERSION.tar.gz
  elif [ -f "$THIRDPARTY/SourcePackages/$PKG-$VERSION.tar.bz2" ]; then
    tar -xjf $THIRDPARTY/SourcePackages/$PKG-$VERSION.tar.bz2
  elif [ -f "$THIRDPARTY/SourcePackages/$PKG-$VERSION.zip" ]; then
    unzip -q $THIRDPARTY/SourcePackages/$PKG-$VERSION.zip
  else
    echo "error locating source package"
    exit 1
  fi
  cd ..
  if [ -f "$PKG.patch" ]; then
    cd src
    patch -p0 <"../$PKG.patch"
    cd ..
  fi
  if [ -f "$PKG.$OS.patch" ]; then
    cd src
    patch -p0 <"../$PKG.$OS.patch"
    cd ..
  fi
fi

BUILD_DIR=build/$PKG-$TYPE-$ARCH
mkdir -p $BUILD_DIR
cd $BUILD_DIR

INSTALL=$BASEPATH/$PKG/$VERSION

if [ "$OS" = "Windows" ]; then
  CXXFLAGS=" /D_SCL_SECURE_NO_WARNINGS=1 /DNOMINMAX " \
    cmake . -G "Visual Studio 12 Win64" \
    -DCMAKE_CXX_FLAGS_DEBUG:STRING=" /MTd " \
    -DCMAKE_CXX_FLAGS_RELEASE:STRING=" /MT " \
    -DCMAKE_C_FLAGS_DEBUG:STRING=" /MTd " \
    -DCMAKE_C_FLAGS_RELEASE:STRING=" /MT " \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL \
    $3 \
    $SRC

  MSBuild.exe ALL_BUILD.vcxproj //m:8 //p:Configuration=$TYPE
  MSBuild.exe INSTALL.vcxproj //m:8 //p:Configuration=$TYPE
elif [ "$OS" = "Darwin" ]; then
  CFLAGS=" -fPIC -m64 " \
  CXXFLAGS=" -fPIC -m64 " \
  MACOSX_DEPLOYMENT_TARGET=10.9 \
  cmake . \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL \
    -DCMAKE_BUILD_TYPE:STRING=$TYPE \
    -DCMAKE_C_ARCHIVE_CREATE='<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>' \
    -DCMAKE_CXX_ARCHIVE_CREATE='<CMAKE_AR> Scr <TARGET> <LINK_FLAGS> <OBJECTS>' \
    -DCMAKE_C_ARCHIVE_FINISH='<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>' \
    -DCMAKE_CXX_ARCHIVE_FINISH='<CMAKE_RANLIB> -no_warning_for_no_symbols -c <TARGET>' \
    $3 \
    $SRC

  make -j8 all VERBOSE=1
  make install
else
  CFLAGS=" -fPIC -m64 " \
  CXXFLAGS=" -fPIC -m64 " \
  MACOSX_DEPLOYMENT_TARGET=10.9 \
  cmake . \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL \
    -DCMAKE_BUILD_TYPE:STRING=$TYPE \
    $3 \
    $SRC

  make -j8 all VERBOSE=1
  make install
fi
