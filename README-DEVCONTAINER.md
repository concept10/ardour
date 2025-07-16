
# Ardour Multi-Platform Development Environment

This devcontainer provides a complete development environment for building, testing, and packaging Ardour for Linux, Windows, and macOS.

## Quick Start

1. Open this repository in VS Code with the Dev Containers extension
2. When prompted, click "Reopen in Container"
3. Wait for the container to build (first time may take 10-15 minutes)
4. Run `make help` to see available build targets

## Supported Platforms

### Linux (Native)
- **Target**: x86_64 Linux
- **Backends**: JACK, ALSA, PulseAudio
- **Status**: ✅ Fully supported

### Windows (Cross-compilation)
- **Target**: Windows 10/11 x86_64
- **Backends**: PortAudio, DirectSound
- **Toolchain**: MinGW-w64
- **Status**: ✅ Supported via cross-compilation

### macOS (Cross-compilation)
- **Target**: macOS 13+ (Intel & Apple Silicon)
- **Backends**: CoreAudio
- **Toolchain**: osxcross
- **Status**: ⚠️ Requires macOS SDK (see setup below)

## Setup Instructions

### Basic Setup (Linux + Windows)
The devcontainer automatically configures Linux and Windows build environments.

### macOS Setup (Additional Steps Required)
1. Obtain macOS SDK from Xcode:
   ```bash
   # On a Mac with Xcode installed:
   cd /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/
   tar -czf MacOSX13.sdk.tar.xz MacOSX.sdk
   ```

2. Copy the SDK to the devcontainer:
   ```bash
   cp MacOSX13.sdk.tar.xz /workspace/.devcontainer/
   ```

3. Build osxcross toolchain:
   ```bash
   .devcontainer/build-osxcross.sh
   ```

## Build Commands

### Configure All Platforms
```bash
make configure-all
```

### Build for Specific Platforms
```bash
# Linux (native)
make build-linux

# Windows (cross-compiled)
make build-windows

# macOS (cross-compiled, requires SDK)
make build-macos
```

### Test Builds
```bash
# Run tests on Linux
make test-linux

# Run tests on Windows (via Wine)
make test-windows
```

### Create Packages
```bash
# Linux package
make package-linux

# Windows installer
make package-windows

# macOS .app bundle
make package-macos
```

### Run Ardour
```bash
# Run Linux build
make run-linux

# Run Windows build (via Wine)
make run-windows
```

## Development Workflow

### Debug Builds
```bash
make debug-linux
```

### Code Formatting
```bash
make format
```

### Static Analysis
```bash
make check
```

### Clean Builds
```bash
# Clean all
make clean

# Clean specific platform
make clean-linux
make clean-windows
make clean-macos
```

## Directory Structure

```
/workspace/
├── build/
│   ├── linux/          # Linux build output
│   ├── windows/        # Windows build output
│   └── macos/          # macOS build output
├── .ccache/            # Compiler cache
├── .devcontainer/      # Development container config
└── [ardour source]     # Ardour source code
```

## Troubleshooting

### Windows Build Issues
- Ensure MinGW-w64 is properly installed
- Check PKG_CONFIG_PATH settings
- Wine may show errors but builds usually succeed

### macOS Build Issues
- Verify osxcross is built: `ls /opt/osxcross/bin/`
- Check SDK is properly installed: `ls /opt/osxcross/SDK/`
- Ensure PATH includes osxcross: `echo $PATH`

### General Build Issues
- Clear compiler cache: `rm -rf .ccache`
- Update dependencies: `make setup-deps`
- Check available disk space (builds require ~10GB)

## Performance Tips

1. **Compiler Cache**: ccache is pre-configured for faster rebuilds
2. **Parallel Builds**: Builds use all available CPU cores by default
3. **Incremental Builds**: Use platform-specific targets to avoid rebuilding everything

## Advanced Configuration

### Custom Waf Options
Edit the `WAF_OPTS` variable in the Makefile:
```makefile
WAF_OPTS := --optimize --use-external-libs --your-custom-options
```

### Additional Dependencies
Add to `.devcontainer/setup.sh` and rebuild the container.

### Cross-compilation Toolchains
- MinGW-w64: Pre-installed for Windows builds
- osxcross: Manual setup required for macOS builds

## Continuous Integration

The environment supports CI workflows:
```bash
# Run all tests
make ci-test

# Build all platforms
make ci-build-all
```

## VS Code Integration

The devcontainer includes:
- C/C++ development tools
- CMake support
- Debugging capabilities
- Code formatting and linting
- Integrated terminal with build tools

### Debugging
1. Build with debug symbols: `make debug-linux`
2. Use VS Code's integrated debugger
3. Set breakpoints in source files
4. Run debug configuration

## Contributing

When contributing to Ardour:
1. Format code: `make format`
2. Run static analysis: `make check`
3. Test on all platforms: `make ci-test`
4. Create packages to verify: `make package-linux package-windows`

## License

This development environment configuration is provided under the same license as Ardour itself (GPL v2+).
