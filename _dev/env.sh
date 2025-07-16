
#!/bin/bash
# Ardour development environment variables for macOS 26

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Ardour paths
export ARDOUR_ROOT="$PROJECT_ROOT"
export ARDOUR_DATA_PATH="$ARDOUR_ROOT/share"
export ARDOUR_BACKEND_PATH="$ARDOUR_ROOT/libs/backends"
export ARDOUR_PLUGIN_PATH="$ARDOUR_ROOT/libs/plugins"
export ARDOUR_SURFACES_PATH="$ARDOUR_ROOT/libs/surfaces"

# Build configuration
export CC=clang
export CXX=clang++
export CCACHE_DIR="$HOME/.ccache"

# macOS specific
export MACOSX_DEPLOYMENT_TARGET=10.15
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

# Python
export PYTHON=/usr/bin/python3

# PKG_CONFIG_PATH for dependencies
export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig:/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

# Add development tools to PATH
export PATH="$ARDOUR_ROOT/_dev:$PATH"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# JACK specific (if using JACK)
export JACK_DEFAULT_SERVER="default"

# Set up ccache if available
if command -v ccache &> /dev/null; then
    export PATH="/opt/homebrew/lib/ccache/bin:$PATH"
fi

echo "Ardour development environment loaded"
echo "Project root: $ARDOUR_ROOT"
echo "Build tools available:"
echo "  - ./_dev/build-macos26.sh (main build script)"
echo "  - ./_dev/test-ardour.sh (test runner)"
echo "  - ./_dev/debug-ardour.sh (debugger)"
echo "  - ./_dev/format-code.sh (code formatter)"
