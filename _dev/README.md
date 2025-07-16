
# Ardour macOS 26 Development Scripts

This directory contains build and development scripts for Ardour on macOS 26 (Sequoia).

## Quick Start

1. **Setup Development Environment**
   ```bash
   ./_dev/setup-dev-env.sh
   ```

2. **Source Environment Variables**
   ```bash
   source _dev/env.sh
   ```

3. **Build Ardour**
   ```bash
   ./_dev/build-macos26.sh
   ```

4. **Test Ardour**
   ```bash
   ./_dev/test-ardour.sh
   ```

## Scripts Overview

### `setup-dev-env.sh`
Sets up the complete development environment including:
- Homebrew and dependencies
- Development tools (git, python, node, etc.)
- IDE configurations (VS Code)
- Git hooks and configuration
- Development helper scripts

### `build-macos26.sh`
Main build script with options:
- `--deps-only`: Install dependencies only
- `--configure-only`: Configure build only
- `--build-only`: Build only (assumes configured)
- `--clean`: Clean build directory
- `--help`: Show help

### `test-ardour.sh`
Quick test script to run Ardour from the build directory.

### `debug-ardour.sh`
Launch Ardour in lldb debugger.

### `format-code.sh`
Format C++ code using clang-format.

### `env.sh`
Environment variables for development. Source this file:
```bash
source _dev/env.sh
```

## System Requirements

- macOS 15 (Sequoia) or later
- Xcode 15.0 or later
- Command Line Tools for Xcode
- Homebrew (will be installed automatically)

## Build Configuration

The build is configured for:
- **Target**: macOS 10.15+ (for compatibility)
- **Architectures**: arm64, x86_64 (Universal Binary)
- **Backends**: CoreAudio, JACK
- **Plugin Formats**: LV2, VST3, Audio Units
- **Optimization**: Enabled for release builds

## Development Workflow

1. **Initial Setup**
   ```bash
   ./_dev/setup-dev-env.sh
   source _dev/env.sh
   ```

2. **Regular Development**
   ```bash
   # Configure and build
   ./_dev/build-macos26.sh
   
   # Test changes
   ./_dev/test-ardour.sh
   
   # Debug issues
   ./_dev/debug-ardour.sh
   ```

3. **Code Formatting**
   ```bash
   ./_dev/format-code.sh
   ```

## VS Code Integration

The setup script creates VS Code configurations for:
- **Build Tasks**: Configure, Build, Clean
- **Debug Configuration**: Launch Ardour in debugger
- **Code Formatting**: C++ formatting rules
- **File Associations**: Proper syntax highlighting

Press `Cmd+Shift+P` and run "Tasks: Run Task" to access build tasks.

## Troubleshooting

### Common Issues

1. **Xcode not found**
   ```bash
   xcode-select --install
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   ```

2. **Homebrew issues**
   ```bash
   brew doctor
   brew update
   brew upgrade
   ```

3. **Build failures**
   ```bash
   ./_dev/build-macos26.sh --clean
   ./_dev/build-macos26.sh --deps-only
   ./_dev/build-macos26.sh
   ```

4. **Permission issues**
   ```bash
   sudo chown -R $(whoami) /opt/homebrew
   ```

### Environment Variables

If you encounter issues, ensure these variables are set:
```bash
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
export MACOSX_DEPLOYMENT_TARGET=10.15
export PATH="/opt/homebrew/bin:$PATH"
```

## Code Signing

For distribution, set the code signing identity:
```bash
export CODESIGN_IDENTITY="Developer ID Application: Your Name"
./_dev/build-macos26.sh
```

## Testing

Enable tests during build:
```bash
export RUN_TESTS=true
./_dev/build-macos26.sh
```

## Contributing

1. Format code before committing:
   ```bash
   ./_dev/format-code.sh
   ```

2. Test your changes:
   ```bash
   ./_dev/test-ardour.sh
   ```

3. The pre-commit hook will run automatically to check code style.

## Support

For issues specific to these build scripts, check:
1. System requirements are met
2. All dependencies are installed
3. Environment variables are set correctly
4. Build output for specific error messages

For Ardour-specific issues, refer to the main Ardour documentation and community resources.
