set -e

THIRDPARTY="$FABRIC_SCENE_GRAPH_DIR/ThirdParty"
OS="$FABRIC_BUILD_OS"
ARCH="$FABRIC_BUILD_ARCH"
TYPE="$FABRIC_BUILD_TYPE"
BASEPATH="$(sh ./_getbasepath.sh)"

ALEMBIC_VERSION=1.5.3_2013121700
ALEMBIC_SRC="$(pwd)/src/alembic-$ALEMBIC_VERSION"
if [ ! -d "$ALEMBIC_SRC" ]; then
  mkdir -p "$(pwd)/src"
  cd src
  tar -xjf $THIRDPARTY/SourcePackages/alembic-$ALEMBIC_VERSION.tar.bz2
  cd $ALEMBIC_SRC
  patch -p1 <$THIRDPARTY/scripts/alembic.patch
  cd ../..
fi

BUILD_DIR=build/alembic-$TYPE-$ARCH
mkdir -p $BUILD_DIR
cd $BUILD_DIR

INSTALL=$BASEPATH/alembic/$ALEMBIC_VERSION
mkdir -p "$INSTALL"
mkdir -p "$INSTALL/lib"
mkdir -p "$INSTALL/include"

if [ "$OS" = "Windows" ]; then
  CXXFLAGS=" /D_SCL_SECURE_NO_WARNINGS=1 /DNOMINMAX " \
  cmake . -G "Visual Studio 12 Win64" \
    -DCMAKE_CXX_FLAGS_DEBUG:STRING=" /MTd " \
    -DCMAKE_CXX_FLAGS_RELEASE:STRING=" /MT " \
    -DCMAKE_C_FLAGS_DEBUG:STRING=" /MTd " \
    -DCMAKE_C_FLAGS_RELEASE:STRING=" /MT " \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL \
    -DBUILD_STATIC_LIBS=1 \
    -DUSE_PYALEMBIC=0 \
    -DZLIB_LIBRARY=$BASEPATH/../Release/zlib/1.2.8/lib/zlibstatic.lib \
    -DZLIB_INCLUDE_DIR=$BASEPATH/../Release/zlib/1.2.8/include \
    -DBOOST_ROOT=$BASEPATH/../Release/boost/1.55.0 \
    -DALEMBIC_ILMBASE_INCLUDE_DIRECTORY=$BASEPATH/ilmbase/2.2.0/include/OpenEXR \
    -DILMBASE_LIBRARY_DIR=$BASEPATH/ilmbase/2.2.0/lib \
    -DALEMBIC_ILMBASE_ILMTHREAD_LIB=$BASEPATH/ilmbase/2.2.0/lib/IlmThread-2_2.lib \
    -DALEMBIC_ILMBASE_IEXMATH_LIB=$BASEPATH/ilmbase/2.2.0/lib/IexMath-2_2.lib \
    -DALEMBIC_ILMBASE_IEX_LIB=$BASEPATH/ilmbase/2.2.0/lib/Iex-2_2.lib \
    -DALEMBIC_ILMBASE_IMATH_LIB=$BASEPATH/ilmbase/2.2.0/lib/Imath-2_2.lib \
    -DALEMBIC_ILMBASE_HALF_LIB=$BASEPATH/ilmbase/2.2.0/lib/Half.lib \
    -DHDF5_ROOT=$BASEPATH/hdf5/1.8.13 \
    -DGLUT_INCLUDE_DIR=$THIRDPARTY/PreBuilt/Windows/$ARCH/$TYPE/include/glut \
    $ALEMBIC_SRC

  SUBS="Abc AbcCollection AbcCoreAbstract AbcCoreOgawa AbcCoreFactory AbcCoreHDF5 AbcGeom AbcMaterial Ogawa Util"
  for PROJ in $(echo $SUBS); do
    echo Building $PROJ...
    MSBuild.exe ALEMBIC.sln //m:8 //p:Configuration=$TYPE //t:Alembic$PROJ
    cp "lib/Alembic/$PROJ/$TYPE/Alembic$PROJ.lib" "$INSTALL/lib"
    mkdir -p "$INSTALL/include/Alembic/$PROJ"
    cp $ALEMBIC_SRC/lib/Alembic/$PROJ/*.h "$INSTALL/include/Alembic/$PROJ"
  done
else
  if [ "$OS" = "Darwin" ]; then
    MOREFLAGS="-Wno-reserved-user-defined-literal -std=c++11 -stdlib=libc++"
  fi
  CXXFLAGS=" -fPIC $MOREFLAGS " \
  MACOSX_DEPLOYMENT_TARGET=10.9 \
  cmake . \
    -DCMAKE_INSTALL_PREFIX:PATH=$INSTALL \
    -DBUILD_STATIC_LIBS=1 \
    -DUSE_PYALEMBIC=0 \
    -DBOOST_ROOT=$BASEPATH/boost/1.55.0 \
    -DALEMBIC_ILMBASE_INCLUDE_DIRECTORY=$BASEPATH/ilmbase/2.2.0/include/OpenEXR \
    -DILMBASE_LIBRARY_DIR=$BASEPATH/ilmbase/2.2.0/lib \
    -DALEMBIC_ILMBASE_ILMTHREAD_LIB=$BASEPATH/ilmbase/2.2.0/lib/IlmThread-2_2.a \
    -DALEMBIC_ILMBASE_IEXMATH_LIB=$BASEPATH/ilmbase/2.2.0/lib/IexMath-2_2.a \
    -DALEMBIC_ILMBASE_IEX_LIB=$BASEPATH/ilmbase/2.2.0/lib/Iex-2_2.a \
    -DALEMBIC_ILMBASE_IMATH_LIB=$BASEPATH/ilmbase/2.2.0/lib/Imath-2_2.a \
    -DALEMBIC_ILMBASE_HALF_LIB=$BASEPATH/ilmbase/2.2.0/lib/Half.a \
    -DHDF5_ROOT=$BASEPATH/hdf5/1.8.13 \
    -DGLUT_INCLUDE_DIR=$THIRDPARTY/PreBuilt/Linux/$ARCH/$TYPE/include/glut \
    $ALEMBIC_SRC

  SUBS="Abc AbcCollection AbcCoreAbstract AbcCoreOgawa AbcCoreFactory AbcCoreHDF5 AbcGeom AbcMaterial Ogawa Util"
  for PROJ in $(echo $SUBS); do
    echo Building $PROJ...
    make -j8 Alembic$PROJ
    cp "lib/Alembic/$PROJ/libAlembic$PROJ.a" "$INSTALL/lib"
    mkdir -p "$INSTALL/include/Alembic/$PROJ"
    cp $ALEMBIC_SRC/lib/Alembic/$PROJ/*.h "$INSTALL/include/Alembic/$PROJ"
  done
fi

