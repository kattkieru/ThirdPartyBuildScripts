set -e

###############################
# freeType and GLWF (windows) #
# need to be build first      #
###############################

THIRDPARTY="$FABRIC_SCENE_GRAPH_DIR/ThirdParty"
OS="$FABRIC_BUILD_OS"
ARCH="$FABRIC_BUILD_ARCH"
TYPE="$FABRIC_BUILD_TYPE"
BASEPATH="$(sh ./_getbasepath.sh)"

echo $BASEPATH

VERSION=3.0
SRC="$(pwd)/src/freetype-gl"
if [ ! -d "$SRC" ]; then
  mkdir -p "$(pwd)/src"
  cd src
  git clone https://github.com/rougier/freetype-gl.git
  cd $SRC
  patch -p1 <$THIRDPARTY/scripts/freetype-gl_FE-8020.patch
  if [ "$OS" = "Windows" ]; then
    patch -p1 <$THIRDPARTY/scripts/freetype-gl.patch
  cd ../..
  fi
fi

BUILD_DIR=build/freetype-gl-$TYPE-$ARCH
 
mkdir -p $BUILD_DIR
cd $BUILD_DIR

INSTALL_DIR=$BASEPATH/freetype-gl/$VERSION
 
mkdir -p "$INSTALL_DIR/lib"
mkdir -p "$INSTALL_DIR/include/freetype-gl"

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
    -Dglfw3_DIR="..\build\glfw-$TYPE-x86_64\src" \
    -DGLEW_INCLUDE_PATH="$FABRIC_SCENE_GRAPH_DIR/Core/ThirdParty/glew-1.13.0/" \
    -DFREETYPE_INCLUDE_DIR_freetype2="$BASEPATH/freetype2/2.7/include/freetype2/" \
    -DFREETYPE_INCLUDE_DIR_ft2build="$BASEPATH/freetype2/2.7/include/freetype2/" \
    -Dfreetype-gl_BUILD_APIDOC=0 \
    -Dfreetype-gl_BUILD_DEMOS=0 \
    -Dfreetype-gl_BUILD_HARFBUZZ=0 \
    -freetype-gl_BUILD_MAKEFONT=0 \
    -Dfreetype-gl_USE_VAO=0 \
    -Dfreetype-gl_WITH_GLEW=0 \
    -Dfreetype-gl_BUILD_TESTS=0 \
    $SRC

   MSBuild.exe freetype-gl.sln //p:Configuration=$TYPE //t:freetype-gl
   cp "$TYPE/freetype-gl.lib" "$INSTALL_DIR/lib"
else
  CFLAGS=" -fPIC -m64 " \
  CXXFLAGS=" -fPIC -m64 " \
  MACOSX_DEPLOYMENT_TARGET=10.9 \
  cmake . \
    -DVERBOSE=1 \
    -DLINKSTATIC=1 \
    -DBUILDSTATIC=1 \
    -DGLEW_INCLUDE_PATH="$FABRIC_SCENE_GRAPH_DIR/Core/ThirdParty/glew-1.13.0/" \
    -DFREETYPE_INCLUDE_DIR_freetype2="$BASEPATH/freetype2/2.7/include/freetype2/" \
    -DFREETYPE_INCLUDE_DIR_ft2build="$BASEPATH/freetype2/2.7/include/freetype2/" \
    -DFREETYPE_LIBRARY="$BASEPATH/freetype2/2.7/lib/libfreetype.a" \
    -Dfreetype-gl_BUILD_APIDOC=0 \
    -Dfreetype-gl_BUILD_DEMOS=0 \
    -Dfreetype-gl_BUILD_HARFBUZZ=0 \
    -freetype-gl_BUILD_MAKEFONT=0 \
    -Dfreetype-gl_USE_VAO=0 \
    -Dfreetype-gl_WITH_GLEW=0 \
    -Dfreetype-gl_BUILD_TESTS=0 \
    $SRC

  make -j8 freetype-gl
  cp "libfreetype-gl.a" "$INSTALL_DIR/lib"
fi

cp -r $SRC/*.h "$INSTALL_DIR/include/freetype-gl"
