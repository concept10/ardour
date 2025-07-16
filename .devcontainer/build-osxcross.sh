
#!/bin/bash
set -e

echo "Building osxcross toolchain for macOS compilation..."

if [ ! -f "/tmp/osxcross/tarballs/MacOSX13.sdk.tar.xz" ]; then
    echo "Error: MacOSX13.sdk.tar.xz not found in /tmp/osxcross/tarballs/"
    echo "Please obtain the macOS SDK from Xcode and place it there."
    echo "You can extract it from Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/"
    exit 1
fi

cd /tmp/osxcross

# Build osxcross
UNATTENDED=1 OSX_VERSION_MIN=10.13 ./build.sh

# Install to /opt/osxcross
sudo cp -r target/* /opt/osxcross/
sudo chown -R ardour:ardour /opt/osxcross

# Add to PATH
echo 'export PATH="/opt/osxcross/bin:$PATH"' >> ~/.bashrc
echo 'export OSXCROSS_ROOT="/opt/osxcross"' >> ~/.bashrc

echo "osxcross toolchain built successfully!"
echo "macOS cross-compilation is now available."
