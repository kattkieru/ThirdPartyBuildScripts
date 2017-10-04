set -e

THIRDPARTY="$FABRIC_SCENE_GRAPH_DIR/ThirdParty"
OS="$FABRIC_BUILD_OS"
ARCH="$FABRIC_BUILD_ARCH"
TYPE="$FABRIC_BUILD_TYPE"
BASEPATH="$(sh ./_getbasepath.sh)"

# PySide and Shiboken go together
VERSION=1.2.4
INSTALL_DIR=$BASEPATH/shiboken+pyside/$VERSION

SRC="$(pwd)/src/PySide"
if [ ! -d "$SRC" ]; then
  mkdir -p "$(pwd)/src"
  cd src
  git clone https://github.com/PySide/PySide.git
  cd PySide
  git checkout $VERSION
  cd ../..
fi

BUILD_DIR=build/pyside-$TYPE-$ARCH
mkdir -p $BUILD_DIR
cd $BUILD_DIR

QTDIR="$BASEPATH/qt/4.8.7"
export PATH=$QTDIR/bin:$PATH

if [ "$OS" = "Windows" ]; then
  echo "[Paths]" >"$QTDIR/bin/qt.conf"
  echo "Prefix = $QTDIR" | sed -e 's/\///' -e 's/\//:\//' >>"$QTDIR/bin/qt.conf"
  cmake . -G "Visual Studio 12 Win64" \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
    -DShiboken_DIR=$INSTALL_DIR \
    -DQT_QMAKE_EXECUTABLE="$QTDIR/bin/qmake.exe" \
    $SRC
  MSBuild.exe ALL_BUILD.vcxproj //m:8 //p:Configuration=$TYPE
  MSBuild.exe INSTALL.vcxproj //m:8 //p:Configuration=$TYPE
else
  echo "[Paths]" >"$QTDIR/bin/qt.conf"
  echo "Prefix = $QTDIR" >>"$QTDIR/bin/qt.conf"
  cmake . \
    -DCMAKE_BUILD_TYPE=$TYPE \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
    -DShiboken_DIR=$INSTALL_DIR \
    -DQT_QMAKE_EXECUTABLE="$QTDIR/bin/qmake" \
    -DALTERNATIVE_QT_INCLUDE_DIR="$QTDIR/include" \
    $SRC
  make -j8
  make install

  if [ "$OS" = "Linux" ]; then
    for f in $INSTALL_DIR/lib/*.so; do
      patchelf --set-rpath "\$ORIGIN/../../../lib" $f
    done
  else
    for f in $INSTALL_DIR/lib/*.dylib; do
      base=$(basename $f)
      install_name_tool -id "@rpath/lib/$base" $f
    done
    for f in $INSTALL_DIR/lib/python2.7/site-packages/PySide/*.so; do
      install_name_tool -change "libpyside-python2.7.1.2.dylib" "@rpath/lib/libpyside-python2.7.1.2.dylib" $f
      install_name_tool -change "libshiboken-python2.7.dylib" "@rpath/lib/libshiboken-python2.7.dylib" $f
      for lib in $(otool -L $f | sed -e 's/ .*//' | grep "@rpath.*Qt"); do
        base=$(basename $lib)
        install_name_tool -change "$lib" "@rpath/lib/$base" $f
      done
      install_name_tool -add_rpath "@loader_path/../../.." $f
    done
  fi
fi

echo "******************** IMPORTANT ***************************"
echo "**********************************************************"
echo "You must manually update:"
echo ""
echo "$INSTALL_DIR/include/PySide/pyside_globals.h"
echo ""
echo "and remove all hardcoded paths, replacing them with"
echo "relative ones."
echo ""
echo "**********************************************************"
echo "**********************************************************"
