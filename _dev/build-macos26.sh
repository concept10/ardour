
#!/bin/bash
set -e

# Ardour macOS 26 Build Script
# This script builds Ardour for macOS 26 (Sequoia)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
INSTALL_PREFIX="/Applications/Ardour.app/Contents"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[BUILD]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check macOS version
check_macos_version() {
    local version=$(sw_vers -productVersion)
    local major_version=$(echo $version | cut -d. -f1)
    
    if [[ $major_version -lt 15 ]]; then
        error "macOS 15 (Sequoia) or later required. Current version: $version"
    fi
    
    log "macOS version: $version ✓"
}

# Check Xcode and command line tools
check_xcode() {
    if ! command -v xcodebuild &> /dev/null; then
        error "Xcode command line tools not found. Install with: xcode-select --install"
    fi
    
    local xcode_version=$(xcodebuild -version | head -1 | cut -d' ' -f2)
    log "Xcode version: $xcode_version ✓"
    
    # Check for required tools
    local required_tools=("gcc" "g++" "make" "python3" "git")
    for tool in "${required_tools[@]}"; do
        if ! command -v $tool &> /dev/null; then
            error "Required tool not found: $tool"
        fi
    done
}

# Install Homebrew dependencies
install_dependencies() {
    log "Installing dependencies via Homebrew..."
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Update Homebrew
    brew update
    
    # Install build dependencies
    local deps=(
        "pkg-config"
        "autoconf"
        "automake"
        "libtool"
        "cmake"
        "ninja"
        "boost"
        "jack"
        "libsamplerate"
        "libsndfile"
        "fftw"
        "flac"
        "ogg"
        "vorbis"
        "opus"
        "lv2"
        "lilv"
        "suil"
        "serd"
        "sord"
        "sratom"
        "cairo"
        "pango"
        "gtk+3"
        "gtkmm3"
        "cairomm"
        "pangomm"
        "glibmm"
        "libxml2"
        "libxslt"
        "curl"
        "taglib"
        "rubberband"
        "aubio"
        "liblo"
        "readline"
        "libuv"
        "hidapi"
        "libusb"
    )
    
    for dep in "${deps[@]}"; do
        if ! brew list $dep &> /dev/null; then
            log "Installing $dep..."
            brew install $dep
        else
            log "$dep already installed ✓"
        fi
    done
}

# Configure build
configure_build() {
    log "Configuring build..."
    
    cd "$PROJECT_ROOT"
    
    # Clean previous build
    if [[ -d "$BUILD_DIR" ]]; then
        rm -rf "$BUILD_DIR"
    fi
    
    # Configure with waf
    local waf_opts=(
        "--optimize"
        "--dist-target=10.15"
        "--prefix=$INSTALL_PREFIX"
        "--with-backends=coreaudio,jack"
        "--libjack=weak"
        "--program-name=Ardour"
        "--arch=arm64,x86_64"
        "--single-package"
        "--test"
        "--lv2"
        "--vst3"
        "--au"
        "--no-carbon"
        "--boost-sp-debug"
        "--cxx11"
        "--cxx-stdlib=libc++"
        "--macos-version-min=10.15"
    )
    
    python3 waf configure "${waf_opts[@]}"
}

# Build Ardour
build_ardour() {
    log "Building Ardour..."
    
    cd "$PROJECT_ROOT"
    
    # Build with parallel jobs
    local jobs=$(sysctl -n hw.ncpu)
    python3 waf build -j$jobs
    
    log "Build completed successfully!"
}

# Create application bundle
create_bundle() {
    log "Creating application bundle..."
    
    cd "$PROJECT_ROOT"
    
    # Use the existing packaging script
    if [[ -f "tools/osx_packaging/osx_build" ]]; then
        chmod +x tools/osx_packaging/osx_build
        tools/osx_packaging/osx_build --public
    else
        # Manual bundle creation
        python3 waf install
        
        # Copy resources
        local bundle_dir="$BUILD_DIR/Ardour.app"
        if [[ -d "$bundle_dir" ]]; then
            log "Application bundle created at: $bundle_dir"
        else
            error "Failed to create application bundle"
        fi
    fi
}

# Code signing (optional)
sign_bundle() {
    if [[ -n "$CODESIGN_IDENTITY" ]]; then
        log "Code signing application bundle..."
        local bundle_dir="$BUILD_DIR/Ardour.app"
        
        if [[ -d "$bundle_dir" ]]; then
            codesign --force --sign "$CODESIGN_IDENTITY" \
                --options runtime \
                --timestamp \
                --deep \
                "$bundle_dir"
            log "Code signing completed"
        fi
    else
        warn "CODESIGN_IDENTITY not set, skipping code signing"
    fi
}

# Run tests
run_tests() {
    if [[ "$RUN_TESTS" == "true" ]]; then
        log "Running tests..."
        cd "$PROJECT_ROOT"
        python3 waf test
        log "Tests completed"
    else
        log "Skipping tests (set RUN_TESTS=true to enable)"
    fi
}

# Main build function
main() {
    log "Starting Ardour macOS 26 build..."
    
    check_macos_version
    check_xcode
    install_dependencies
    configure_build
    build_ardour
    create_bundle
    sign_bundle
    run_tests
    
    log "Build process completed successfully!"
    log "Application bundle available at: $BUILD_DIR/Ardour.app"
}

# Handle command line arguments
case "${1:-}" in
    --deps-only)
        install_dependencies
        ;;
    --configure-only)
        configure_build
        ;;
    --build-only)
        build_ardour
        ;;
    --clean)
        rm -rf "$BUILD_DIR"
        log "Build directory cleaned"
        ;;
    --help|-h)
        echo "Usage: $0 [option]"
        echo "Options:"
        echo "  --deps-only      Install dependencies only"
        echo "  --configure-only Configure build only"
        echo "  --build-only     Build only (assumes configured)"
        echo "  --clean          Clean build directory"
        echo "  --help           Show this help"
        ;;
    *)
        main
        ;;
esac
