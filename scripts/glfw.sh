set -e

THIRDPARTY="$FABRIC_SCENE_GRAPH_DIR/ThirdParty"
OS="$FABRIC_BUILD_OS"
ARCH="$FABRIC_BUILD_ARCH"
TYPE="$FABRIC_BUILD_TYPE"
BASEPATH="$(sh ./_getbasepath.sh)"

VERSION=3.2.1
SRC="$(pwd)/src/glfw"
if [ ! -d "$SRC" ]; then
  mkdir -p "$(pwd)/src"
  cd src
  git clone https://github.com/glfw/glfw.git
  cd ..
fi

BUILD_DIR=build/glfw-$TYPE-$ARCH
mkdir -p $BUILD_DIR
cd $BUILD_DIR

INSTALL_DIR=$BASEPATH/glfw/$VERSION
 
mkdir -p "$INSTALL_DIR/lib"
mkdir -p "$INSTALL_DIR/include/glfw"

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
    -DGLFW_BUILD_DOCS=0 \
  	-DGLFW_BUILD_EXAMPLES=0 \
  	-DGLFW_BUILD_TESTS=0 \
  	-DGLFW_DOCUMENT_INTERNALS=0 \
  	-DGLFW_INSTALL=1 \
  	-DGLFW_USE_HYBRID_HPG=0 \
  	-DGLFW_VULKAN_STATIC=0 \
    $SRC

   MSBuild.exe GLFW.sln //p:Configuration=$TYPE 
   cp "src/$TYPE/glfw3.lib" "$INSTALL_DIR/lib"
else
  CFLAGS=" -fPIC -m64 " CXXFLAGS=" -fPIC -m64 " \
  MACOSX_DEPLOYMENT_TARGET=10.9 \
  cmake . \
    -DVERBOSE=1 \
    -DLINKSTATIC=1 \
    -DBUILDSTATIC=1 \
    -DGLFW_BUILD_DOCS=0 \
    -DGLFW_BUILD_EXAMPLES=0 \
    -DGLFW_BUILD_TESTS=0 \
    -DGLFW_DOCUMENT_INTERNALS=0 \
    -DGLFW_INSTALL=1 \
    -DGLFW_USE_HYBRID_HPG=0 \
    -DGLFW_VULKAN_STATIC=0 \
    $SRC

  make -j8 glfw
  cp "src/libglfw3.a" "$INSTALL_DIR/lib"
fi

cp -r $SRC/src/*.h "$INSTALL_DIR/include/glfw"
