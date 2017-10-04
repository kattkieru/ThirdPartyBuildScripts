set -e

if [ -z "$FABRIC_SCENE_GRAPH_DIR" ]; then
  echo "run fabric-build-env.sh"
  exit 1
fi

OS="$FABRIC_BUILD_OS"
ARCH="$FABRIC_BUILD_ARCH"
TYPE="$FABRIC_BUILD_TYPE"

if [ "$OS" = "Windows" ]; then 
  echo "$FABRIC_SCENE_GRAPH_DIR/ThirdParty/PreBuilt/$OS/$ARCH/VS2013/$TYPE/"
elif [ "$OS" = "Darwin" ]; then 
  echo "$FABRIC_SCENE_GRAPH_DIR/ThirdParty/PreBuilt/$OS/$ARCH/sdk10.9-libc++/$TYPE/"
else
  echo "$FABRIC_SCENE_GRAPH_DIR/ThirdParty/PreBuilt/$OS/$ARCH/$TYPE/"
fi

