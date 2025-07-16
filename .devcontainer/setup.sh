
#!/bin/bash
set -e

echo "Setting up Ardour development environment..."

# Update package lists
sudo apt-get update

# Install essential build tools
sudo apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    autoconf \
    automake \
    libtool \
    nasm \
    yasm \
    git \
    wget \
    curl \
    unzip \
    tar \
    gzip \
    rsync \
    ccache \
    clang \
    clang-format \
    lldb \
    gdb \
    valgrind

# Install cross-compilation tools for Windows
sudo apt-get install -y \
    mingw-w64 \
    mingw-w64-tools \
    wine64 \
    wine32

# Install dependencies for Linux builds
sudo apt-get install -y \
    libasound2-dev \
    libpulse-dev \
    libjack-jackd2-dev \
    libsndfile1-dev \
    libsamplerate0-dev \
    libfftw3-dev \
    libflac-dev \
    libogg-dev \
    libvorbis-dev \
    libcurl4-openssl-dev \
    libarchive-dev \
    liblo-dev \
    libtag1-dev \
    libvamp-hostsdk3v5 \
    librubberband-dev \
    libusb-1.0-0-dev \
    libglibmm-2.4-dev \
    libgiomm-2.4-dev \
    libgtkmm-2.4-dev \
    libcairo2-dev \
    libpango1.0-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libx11-dev \
    libxext-dev \
    libxfixes-dev \
    libxi-dev \
    libxrandr-dev \
    libxss-dev \
    libglu1-mesa-dev \
    libgl1-mesa-dev \
    uuid-dev \
    libboost-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libboost-thread-dev \
    libcppunit-dev \
    gettext \
    intltool

# Install macOS cross-compilation tools (osxcross)
echo "Setting up macOS cross-compilation environment..."
cd /tmp
git clone https://github.com/tpoechtrager/osxcross.git
cd osxcross

# Note: Users will need to provide MacOSX SDK manually
# Instructions will be provided in README
mkdir -p tarballs
echo "To enable macOS builds, place MacOSX13.sdk.tar.xz in /tmp/osxcross/tarballs/"
echo "SDK can be extracted from Xcode or downloaded with proper Apple Developer account"

# Setup directories and permissions
sudo mkdir -p /opt/osxcross
sudo chown -R ardour:ardour /opt/osxcross

# Windows-specific setup
echo "Configuring Windows cross-compilation..."
sudo apt-get install -y \
    wine \
    winetricks

# Setup ccache for faster builds
echo "Configuring ccache..."
sudo mkdir -p /usr/lib/ccache
sudo ln -sf /usr/bin/ccache /usr/lib/ccache/gcc
sudo ln -sf /usr/bin/ccache /usr/lib/ccache/g++
sudo ln -sf /usr/bin/ccache /usr/lib/ccache/clang
sudo ln -sf /usr/bin/ccache /usr/lib/ccache/clang++
sudo ln -sf /usr/bin/ccache /usr/lib/ccache/x86_64-w64-mingw32-gcc
sudo ln -sf /usr/bin/ccache /usr/lib/ccache/x86_64-w64-mingw32-g++
sudo ln -sf /usr/bin/ccache /usr/lib/ccache/i686-w64-mingw32-gcc
sudo ln -sf /usr/bin/ccache /usr/lib/ccache/i686-w64-mingw32-g++

# Setup environment variables
echo 'export PATH="/usr/lib/ccache:$PATH"' >> ~/.bashrc
echo 'export CCACHE_DIR=/workspace/.ccache' >> ~/.bashrc
echo 'export CCACHE_MAXSIZE=2G' >> ~/.bashrc

# Create build directories
mkdir -p /workspace/build/{linux,windows,macos}
mkdir -p /workspace/.ccache

# Setup git configuration for development
git config --global user.name "Ardour Developer"
git config --global user.email "dev@ardour.org"
git config --global init.defaultBranch main
git config --global pull.rebase false

# Install additional development tools
pip3 install --user \
    cppcheck \
    cpplint \
    clang-format \
    pre-commit

echo "Development environment setup complete!"
echo ""
echo "Next steps:"
echo "1. For macOS builds: Place MacOSX13.sdk.tar.xz in /tmp/osxcross/tarballs/ and run build-osxcross.sh"
echo "2. Run 'make configure-all' to configure all platform builds"
echo "3. Run 'make build-linux' for Linux build"
echo "4. Run 'make build-windows' for Windows build"
echo "5. Run 'make build-macos' for macOS build (requires SDK)"
echo ""
