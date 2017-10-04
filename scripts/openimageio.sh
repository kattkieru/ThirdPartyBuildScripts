set -e

THIRDPARTY="$FABRIC_SCENE_GRAPH_DIR/ThirdParty"
OS="$FABRIC_BUILD_OS"
ARCH="$FABRIC_BUILD_ARCH"
TYPE="$FABRIC_BUILD_TYPE"
BASEPATH="$(sh ./_getbasepath.sh)"

VERSION=RB-1.3
SRC="$(pwd)/src/oiio"
if [ ! -d "$SRC" ]; then
  mkdir -p "$(pwd)/src"
  cd src
  git clone https://github.com/OpenImageIO/oiio.git
  cd oiio
  git checkout $VERSION
  patch -p1 <../../openimageio.patch
  cd ../..
fi

BUILD_DIR=build/openimageio-$TYPE-$ARCH
mkdir -p $BUILD_DIR
cd $BUILD_DIR

INSTALL_DIR=$BASEPATH/oiio/$VERSION
mkdir -p "$INSTALL_DIR/lib"
mkdir -p "$INSTALL_DIR/include/OpenImageIO"

if [ "$OS" = "Windows" ]; then
  CXXFLAGS=" /D_SCL_SECURE_NO_WARNINGS=1 /DNOMINMAX /MP /DPTEX_STATIC=1 /DOpenImageIO_EXPORTS "

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
    -DUSE_OPENJPEG=0 \
    -DUSE_GIF=1 \
    -DGIF_LIBRARY=$BASEPATH/../Release/giflib/5.0.6/lib/giflib.lib \
    -DGIF_INCLUDE_DIR=$BASEPATH/../Release/giflib/5.0.6/include \
    -DZLIB_LIBRARY=$BASEPATH/../Release/zlib/1.2.8/lib/zlibstatic.lib \
    -DZLIB_INCLUDE_DIR=$BASEPATH/../Release/zlib/1.2.8/include \
    -DBOOST_CUSTOM:BOOL=True \
    -DBoost_VERSION=105500 \
    -DBoost_LIBRARIES:STRING="libboost_filesystem-vc120-mt-s-1_55.lib;libboost_regex-vc120-mt-s-1_55.lib;libboost_system-vc120-mt-s-1_55.lib;libboost_thread-vc120-mt-s-1_55.lib;libboost_python-vc120-mt-s-1_55.lib" \
    -DBoost_LIBRARY_DIRS=$BASEPATH/boost/1.55.0/lib \
    -DBoost_INCLUDE_DIRS=$BASEPATH/boost/1.55.0/ \
    -DILMBASE_CUSTOM:BOOL=True \
    -DILMBASE_VERSION="2.2.2" \
    -DILMBASE_HALF_LIBRARIES=$BASEPATH/ilmbase/2.2.0/lib/Half.lib \
    -DILMBASE_IEX-2_2_LIBRARIES=$BASEPATH/ilmbase/2.2.0/lib/Iex-2_2.lib \
    -DILMBASE_IMATH-2_2_LIBRARIES=$BASEPATH/ilmbase/2.2.0/lib/Imath-2_2.lib \
    -DILMBASE_ILMTHREAD-2_2_LIBRARIES=$BASEPATH/ilmbase/2.2.0/lib/IlmThread-2_2.lib \
    -DILMBASE_CUSTOM_LIBRARIES="Half Iex-2_2 Imath-2_2 IlmThread-2_2" \
    -DILMBASE_CUSTOM_INCLUDE_DIR=$BASEPATH/ilmbase/2.2.0/include \
    -DILMBASE_INCLUDE_DIR=$BASEPATH/ilmbase/2.2.0/include \
    -DILMBASE_CUSTOM_LIB_DIR=$BASEPATH/ilmbase/2.2.0/lib \
    -DPNG_PNG_INCLUDE_DIR=$BASEPATH/libpng/1.6.13/include \
    -DPNG_LIBRARY=$BASEPATH/libpng/1.6.13/lib/lipng16.lib \
    -DJPEG_INCLUDE_DIR=$BASEPATH/../Release/libjpeg-turbo/1.3.1/include \
    -DJPEG_LIBRARY=$BASEPATH/../Release/libjpeg-turbo/1.3.1/lib/jpeg.lib \
    -DTIFF_INCLUDE_DIR=$BASEPATH/tiff/3.9.7/include \
    -DTIFF_LIBRARY=$BASEPATH/tiff/3.9.7/lib/libtiff.lib \
    -DOPENEXR_CUSTOM:BOOL=True \
    -DOPENEXR_VERSION="2.2.0" \
    -DOPENEXR_CUSTOM_LIBRARY="IlmImf-2_2" \
    -DOPENEXR_CUSTOM_INCLUDE_DIR=$BASEPATH/openexr/2.2.0/include \
    -DOPENEXR_INCLUDE_DIR=$BASEPATH/openexr/2.2.0/include \
    -DOPENEXR_CUSTOM_LIB_DIR=$BASEPATH/openexr/2.2.0/lib \
    $SRC

  MSBuild.exe OpenImageIO.sln //p:Configuration=$TYPE //t:OpenImageIO
  cp "src/libOpenImageIO/$TYPE/OpenImageIO.lib" "$INSTALL_DIR/lib"
elif [ "$OS" = "Darwin" ]; then
  CXXFLAGS=" -DPTEX_STATIC=1 -DOpenImageIO_EXPORTS " \
  MACOSX_DEPLOYMENT_TARGET=10.9 \
  cmake . \
    -DVERBOSE=1 \
    -DLINKSTATIC=1 \
    -DBUILDSTATIC=1 \
    -DUSE_OPENJPEG=0 \
    -DUSE_GIF=1 \
    -DUSE_FREETYPE=0 \
    -DGIF_LIBRARY=$BASEPATH/giflib/5.0.6/lib/libgif.a \
    -DGIF_INCLUDE_DIR=$BASEPATH/giflib/5.0.6/include \
    -DBOOST_CUSTOM:BOOL=True \
    -DBoost_VERSION=105500 \
    -DBoost_LIBRARIES:STRING="libboost_filesystem.a;libboost_regex.a;libboost_system.a;libboost_thread.a;libboost_python.a" \
    -DBoost_LIBRARY_DIRS=$BASEPATH/boost/1.55.0/lib \
    -DBoost_INCLUDE_DIRS=$BASEPATH/boost/1.55.0/include \
    -DILMBASE_CUSTOM:BOOL=True \
    -DILMBASE_VERSION="2.2.2" \
    -DILMBASE_HALF_LIBRARIES=$BASEPATH/ilmbase/2.2.0/lib/libHalf.a \
    -DILMBASE_IEX-2_2_LIBRARIES=$BASEPATH/ilmbase/2.2.0/lib/libIex-2_2.a \
    -DILMBASE_IMATH-2_2_LIBRARIES=$BASEPATH/ilmbase/2.2.0/lib/libImath-2_2.a \
    -DILMBASE_ILMTHREAD-2_2_LIBRARIES=$BASEPATH/ilmbase/2.2.0/lib/libIlmThread-2_2.a \
    -DILMBASE_CUSTOM_LIBRARIES="Half Iex-2_2 Imath-2_2 IlmThread-2_2" \
    -DILMBASE_CUSTOM_INCLUDE_DIR=$BASEPATH/ilmbase/2.2.0/include \
    -DILMBASE_INCLUDE_DIR=$BASEPATH/ilmbase/2.2.0/include \
    -DILMBASE_CUSTOM_LIB_DIR=$BASEPATH/ilmbase/2.2.0/lib \
    -DPNG_PNG_INCLUDE_DIR=$BASEPATH/libpng/1.6.13/include \
    -DPNG_LIBRARY=$BASEPATH/libpng/1.6.13/lib/lipng16.a \
    -DJPEG_INCLUDE_DIR=$BASEPATH/jpeg/6/include \
    -DJPEG_LIBRARY=$BASEPATH/jpeg/6/lib/libjpeg.a \
    -DTIFF_INCLUDE_DIR=$BASEPATH/tiff/3.9.7/include \
    -DTIFF_LIBRARY=$BASEPATH/tiff/3.9.7/lib/libtiff.a \
    -DOPENEXR_CUSTOM:BOOL=True \
    -DOPENEXR_VERSION="2.2.0" \
    -DOPENEXR_CUSTOM_LIBRARY="IlmImf-2_2" \
    -DOPENEXR_CUSTOM_INCLUDE_DIR=$BASEPATH/openexr/2.2.0/include \
    -DOPENEXR_INCLUDE_DIR=$BASEPATH/openexr/2.2.0/include \
    -DOPENEXR_CUSTOM_LIB_DIR=$BASEPATH/openexr/2.2.0/lib \
    -DUSE_WEBP=0 \
    -DWEBP_INCLUDE_DIR= \
    -DWEBP_LIB_DIR= \
    $SRC

  make -j8 OpenImageIO VERBOSE=1
  cp "src/libOpenImageIO/libOpenImageIO.a" "$INSTALL_DIR/lib"
else
  CXXFLAGS=" -DPTEX_STATIC=1 -DOpenImageIO_EXPORTS -fPIC "
  JPEG_INCLUDE_DIR=$BASEPATH/libjpeg-turbo/1.3.1/include
  JPEG_LIBRARY=$BASEPATH/libjpeg-turbo/1.3.1/lib/libjpeg.a

  CXXFLAGS="$CXXFLAGS" \
  cmake . \
    -DVERBOSE=1 \
    -DLINKSTATIC=1 \
    -DBUILDSTATIC=1 \
    -DUSE_OPENJPEG=0 \
    -DUSE_GIF=1 \
    -DGIF_LIBRARY=$BASEPATH/giflib/5.0.6/lib/libgif.a \
    -DGIF_INCLUDE_DIR=$BASEPATH/giflib/5.0.6/include \
    -DBOOST_CUSTOM:BOOL=True \
    -DBoost_VERSION=105500 \
    -DBoost_LIBRARIES:STRING="libboost_filesystem.a;libboost_regex.a;libboost_system.a;libboost_thread.a;libboost_python.a" \
    -DBoost_LIBRARY_DIRS=$BASEPATH/boost/1.55.0/lib \
    -DBoost_INCLUDE_DIRS=$BASEPATH/boost/1.55.0/include \
    -DILMBASE_CUSTOM:BOOL=True \
    -DILMBASE_VERSION="2.2.2" \
    -DILMBASE_HALF_LIBRARIES=$BASEPATH/ilmbase/2.2.0/lib/libHalf.a \
    -DILMBASE_IEX-2_2_LIBRARIES=$BASEPATH/ilmbase/2.2.0/lib/libIex-2_2.a \
    -DILMBASE_IMATH-2_2_LIBRARIES=$BASEPATH/ilmbase/2.2.0/lib/libImath-2_2.a \
    -DILMBASE_ILMTHREAD-2_2_LIBRARIES=$BASEPATH/ilmbase/2.2.0/lib/libIlmThread-2_2.a \
    -DILMBASE_CUSTOM_LIBRARIES="Half Iex-2_2 Imath-2_2 IlmThread-2_2" \
    -DILMBASE_CUSTOM_INCLUDE_DIR=$BASEPATH/ilmbase/2.2.0/include \
    -DILMBASE_INCLUDE_DIR=$BASEPATH/ilmbase/2.2.0/include \
    -DILMBASE_CUSTOM_LIB_DIR=$BASEPATH/ilmbase/2.2.0/lib \
    -DPNG_PNG_INCLUDE_DIR=$BASEPATH/libpng/1.6.13/include \
    -DPNG_LIBRARY=$BASEPATH/libpng/1.6.13/lib/lipng16.a \
    -DJPEG_INCLUDE_DIR=$JPEG_INCLUDE_DIR \
    -DJPEG_LIBRARY=$JPEG_LIBRARY \
    -DTIFF_INCLUDE_DIR=$BASEPATH/tiff/3.9.7/include \
    -DTIFF_LIBRARY=$BASEPATH/tiff/3.9.7/lib/libtiff.a \
    -DOPENEXR_CUSTOM:BOOL=True \
    -DOPENEXR_VERSION="2.2.0" \
    -DOPENEXR_CUSTOM_LIBRARY="IlmImf-2_2" \
    -DOPENEXR_CUSTOM_INCLUDE_DIR=$BASEPATH/openexr/2.2.0/include \
    -DOPENEXR_INCLUDE_DIR=$BASEPATH/openexr/2.2.0/include \
    -DOPENEXR_CUSTOM_LIB_DIR=$BASEPATH/openexr/2.2.0/lib \
    $SRC

  make -j8 OpenImageIO
  cp "src/libOpenImageIO/libOpenImageIO.a" "$INSTALL_DIR/lib"
fi

cp "include/version.h" "$INSTALL_DIR/include/OpenImageIO"
cp $SRC/src/include/*.h "$INSTALL_DIR/include/OpenImageIO"

