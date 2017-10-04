set -e

THIRDPARTY="$FABRIC_SCENE_GRAPH_DIR/ThirdParty"
OS="$FABRIC_BUILD_OS"
ARCH="$FABRIC_BUILD_ARCH"
TYPE="$FABRIC_BUILD_TYPE"
BASEPATH="$(sh ./_getbasepath.sh)"

VERSION=4.8.7
INSTALL_DIR=$BASEPATH/qt/$VERSION

SRC="$(pwd)/src/qt"
if [ ! -d "$SRC" ]; then
  mkdir -p "$(pwd)/src"
  cd src
  git clone https://github.com/qtproject/qt
  cd qt
  git checkout v$VERSION
  patch -p1 <../../qt.patch
  cd ../..
fi

if [ "$OS" = "Windows" ]; then
  cd src/qt
  # nmake confclean
  configure.exe -opensource -prefix "$INSTALL_DIR" -platform win32-msvc2013
  CL="//MP" nmake
  nmake install
else
  cd src/qt
  # make confclean
  if [ "$OS" = "Linux" ]; then
    ./configure -opensource -prefix "$INSTALL_DIR"
  else
    ./configure -no-rpath -opensource -prefix "$INSTALL_DIR"
  fi
  make -j4
  make install

  if [ "$OS" = "Darwin" ]; then
    cd $INSTALL_DIR/lib
    for f in *.framework; do
      base=$(echo $f | sed -e 's/\..*//')
      file="$f/$base"
      for lib in $(otool -L $file | grep -v ':' | sed -e 's/ .*//' | grep "Qt.*framework"); do
        libbase=$(basename $lib)
        install_name_tool -change "$lib" "@rpath/lib/$libbase" $file
      done
      install_name_tool -id "@rpath/lib/$base" $file
      install_name_tool -add_rpath "@loader_path/.." $file
    done
  fi
fi

