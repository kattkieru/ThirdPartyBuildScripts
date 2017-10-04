set -e

THIRDPARTY="$FABRIC_SCENE_GRAPH_DIR/ThirdParty"
OS="$FABRIC_BUILD_OS"
ARCH="$FABRIC_BUILD_ARCH"
TYPE="$FABRIC_BUILD_TYPE"
BASEPATH="$(sh ./_getbasepath.sh)"

# PySide and Shiboken go together
VERSION=1.2.4
INSTALL_DIR=$BASEPATH/shiboken+pyside/$VERSION

SRC="$(pwd)/src/Shiboken"
if [ ! -d "$SRC" ]; then
  mkdir -p "$(pwd)/src"
  cd src
  git clone https://github.com/PySide/Shiboken.git
  cd Shiboken
  git checkout $VERSION
  patch -p1 <../../shiboken.patch
  cd ../..
fi

BUILD_DIR=build/shiboken-$TYPE-$ARCH
mkdir -p $BUILD_DIR
cd $BUILD_DIR

QTDIR="$BASEPATH/qt/4.8.7"
export PATH=$QTDIR/bin:$PATH

if [ "$OS" = "Windows" ]; then
  echo "[Paths]" >"$QTDIR/bin/qt.conf"
  echo "Prefix = $QTDIR" | sed -e 's/\///' -e 's/\//:\//' >>"$QTDIR/bin/qt.conf"
  cmake . -G "Visual Studio 12 Win64" \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
    -DQT_QMAKE_EXECUTABLE="$QTDIR/bin/qmake.exe" \
    $SRC
  # [andrew 20160317] this build will fail but the manual copy below
  # fixes the problem so that the install can succeed
  set +e
  MSBuild.exe ALL_BUILD.vcxproj //m:8 //p:Configuration=$TYPE
  set -e
  cp generator/$TYPE/shiboken.exe generator/
  MSBuild.exe INSTALL.vcxproj //m:8 //p:Configuration=$TYPE
else
  cmake . \
    -DCMAKE_BUILD_TYPE=$TYPE \
    -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
    $SRC
  make -j8
  make install
fi

