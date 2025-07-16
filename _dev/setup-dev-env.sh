
#!/bin/bash
set -e

# Development Environment Setup for Ardour macOS 26
# This script sets up a complete development environment

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[SETUP]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Setup Homebrew
setup_homebrew() {
    log "Setting up Homebrew..."
    
    if ! command -v brew &> /dev/null; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    brew update
    brew upgrade
}

# Install development tools
install_dev_tools() {
    log "Installing development tools..."
    
    # Essential development tools
    local dev_tools=(
        "git"
        "git-lfs"
        "python@3.11"
        "node"
        "yarn"
        "cmake"
        "ninja"
        "ccache"
        "clang-format"
        "doxygen"
        "graphviz"
        "valgrind"
        "gdb"
        "lldb"
    )
    
    for tool in "${dev_tools[@]}"; do
        if ! brew list $tool &> /dev/null; then
            log "Installing $tool..."
            brew install $tool
        fi
    done
    
    # Install Python packages
    pip3 install --user --upgrade pip
    pip3 install --user cppcheck flake8 black
}

# Setup Git configuration
setup_git() {
    log "Setting up Git configuration..."
    
    # Git LFS
    git lfs install
    
    # Set up git hooks
    if [[ -f "$PROJECT_ROOT/tools/pre-commit" ]]; then
        cp "$PROJECT_ROOT/tools/pre-commit" "$PROJECT_ROOT/.git/hooks/"
        chmod +x "$PROJECT_ROOT/.git/hooks/pre-commit"
        log "Pre-commit hook installed"
    fi
    
    # Git configuration recommendations
    cat << EOF > "$PROJECT_ROOT/.gitconfig.local"
[core]
    autocrlf = input
    safecrlf = true
    
[push]
    default = simple
    
[pull]
    rebase = true
    
[alias]
    co = checkout
    br = branch
    ci = commit
    st = status
    unstage = reset HEAD --
    last = log -1 HEAD
    visual = !gitk
    
[color]
    ui = auto
EOF
    
    log "Git configuration template created at .gitconfig.local"
}

# Setup IDE/Editor configurations
setup_editors() {
    log "Setting up editor configurations..."
    
    # VS Code settings
    local vscode_dir="$PROJECT_ROOT/.vscode"
    mkdir -p "$vscode_dir"
    
    cat << 'EOF' > "$vscode_dir/settings.json"
{
    "files.insertFinalNewline": true,
    "files.trimTrailingWhitespace": true,
    "editor.detectIndentation": false,
    "editor.insertSpaces": false,
    "editor.tabSize": 8,
    "editor.rulers": [80, 120],
    "C_Cpp.clang_format_style": "file",
    "C_Cpp.default.cppStandard": "c++11",
    "C_Cpp.default.cStandard": "c11",
    "files.associations": {
        "*.cc": "cpp",
        "*.h": "cpp"
    },
    "search.exclude": {
        "**/build/**": true,
        "**/libs/**": true
    }
}
EOF
    
    # VS Code tasks
    cat << 'EOF' > "$vscode_dir/tasks.json"
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Configure",
            "type": "shell",
            "command": "${workspaceFolder}/_dev/build-macos26.sh",
            "args": ["--configure-only"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Build",
            "type": "shell",
            "command": "${workspaceFolder}/_dev/build-macos26.sh",
            "args": ["--build-only"],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Full Build",
            "type": "shell",
            "command": "${workspaceFolder}/_dev/build-macos26.sh",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Clean",
            "type": "shell",
            "command": "${workspaceFolder}/_dev/build-macos26.sh",
            "args": ["--clean"],
            "group": "build"
        }
    ]
}
EOF
    
    # VS Code launch configuration
    cat << 'EOF' > "$vscode_dir/launch.json"
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug Ardour",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/build/gtk2_ardour/ardour",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "lldb",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
EOF
    
    log "VS Code configuration created"
}

# Create useful development scripts
create_dev_scripts() {
    log "Creating development scripts..."
    
    # Quick test script
    cat << 'EOF' > "$SCRIPT_DIR/test-ardour.sh"
#!/bin/bash
# Quick test script for Ardour
cd "$(dirname "$0")/.."
export ARDOUR_DATA_PATH="$PWD/share"
export ARDOUR_BACKEND_PATH="$PWD/libs/backends"
export ARDOUR_PLUGIN_PATH="$PWD/libs/plugins"

if [[ -f "gtk2_ardour/ardev" ]]; then
    ./gtk2_ardour/ardev "$@"
else
    echo "Ardour not built. Run: ./_dev/build-macos26.sh"
    exit 1
fi
EOF
    chmod +x "$SCRIPT_DIR/test-ardour.sh"
    
    # Debug script
    cat << 'EOF' > "$SCRIPT_DIR/debug-ardour.sh"
#!/bin/bash
# Debug Ardour with lldb
cd "$(dirname "$0")/.."
export ARDOUR_DATA_PATH="$PWD/share"
export ARDOUR_BACKEND_PATH="$PWD/libs/backends"
export ARDOUR_PLUGIN_PATH="$PWD/libs/plugins"

if [[ -f "gtk2_ardour/ardev" ]]; then
    lldb ./gtk2_ardour/ardev -- "$@"
else
    echo "Ardour not built. Run: ./_dev/build-macos26.sh"
    exit 1
fi
EOF
    chmod +x "$SCRIPT_DIR/debug-ardour.sh"
    
    # Format code script
    cat << 'EOF' > "$SCRIPT_DIR/format-code.sh"
#!/bin/bash
# Format C++ code using clang-format
cd "$(dirname "$0")/.."

if [[ -f "tools/clang-format" ]]; then
    find gtk2_ardour libs/ardour -name "*.cc" -o -name "*.h" | \
        xargs clang-format -i -style=file
    echo "Code formatted"
else
    echo "clang-format configuration not found"
fi
EOF
    chmod +x "$SCRIPT_DIR/format-code.sh"
    
    log "Development scripts created"
}

# Setup environment variables
setup_environment() {
    log "Setting up environment variables..."
    
    local env_file="$SCRIPT_DIR/env.sh"
    cat << EOF > "$env_file"
#!/bin/bash
# Ardour development environment variables

export ARDOUR_ROOT="$PROJECT_ROOT"
export ARDOUR_DATA_PATH="\$ARDOUR_ROOT/share"
export ARDOUR_BACKEND_PATH="\$ARDOUR_ROOT/libs/backends"
export ARDOUR_PLUGIN_PATH="\$ARDOUR_ROOT/libs/plugins"
export ARDOUR_SURFACES_PATH="\$ARDOUR_ROOT/libs/surfaces"

# Build configuration
export CC=clang
export CXX=clang++
export CCACHE_DIR="\$HOME/.ccache"

# macOS specific
export MACOSX_DEPLOYMENT_TARGET=10.15
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

# Add to PATH
export PATH="\$ARDOUR_ROOT/_dev:\$PATH"
export PATH="/opt/homebrew/bin:\$PATH"

echo "Ardour development environment loaded"
EOF
    
    log "Environment script created at $env_file"
    log "Source it with: source $env_file"
}

# Main setup function
main() {
    log "Setting up Ardour development environment for macOS 26..."
    
    setup_homebrew
    install_dev_tools
    setup_git
    setup_editors
    create_dev_scripts
    setup_environment
    
    log "Development environment setup completed!"
    log ""
    log "Next steps:"
    log "1. Source the environment: source _dev/env.sh"
    log "2. Run the build: ./_dev/build-macos26.sh"
    log "3. Test Ardour: ./_dev/test-ardour.sh"
    log ""
    log "VS Code users: Open this folder in VS Code for build tasks and debugging"
}

main "$@"
