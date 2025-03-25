#!/bin/bash

# PhD Workflow Tools Installer
echo "PhD Workflow Tools Installer"
echo "==========================="
echo ""

# Detect OS and set paths accordingly
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    HOME_DIR="$HOME"
    IS_WSL=$(uname -r | grep -i "microsoft" || true)
    if [[ -n "$IS_WSL" ]]; then
        echo "WSL detected. Using Windows paths."
        WIN_USER=$(cmd.exe /c echo %USERNAME% 2>/dev/null | tr -d '\r')
        PHD_ROOT="/mnt/c/Users/$WIN_USER/aman_projects/PhD"
    else
        PHD_ROOT="$HOME/aman_projects/PhD"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    HOME_DIR="$HOME"
    PHD_ROOT="$HOME/aman_projects/PhD"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Windows with Git Bash or similar
    HOME_DIR=$(cygpath -u "$USERPROFILE")
    PHD_ROOT="$HOME_DIR/aman_projects/PhD"
else
    echo "Unsupported OS: $OSTYPE"
    echo "Please manually install the tools."
    exit 1
fi

# Allow custom installation path
read -p "Installation path [$PHD_ROOT]: " custom_path
if [ -n "$custom_path" ]; then
    PHD_ROOT=$custom_path
fi

echo "Installing PhD Workflow Tools to: $PHD_ROOT"

# Create directory structure
echo "Creating directory structure..."
mkdir -p "$PHD_ROOT"
mkdir -p "$PHD_ROOT/projects"
mkdir -p "$PHD_ROOT/experiments"
mkdir -p "$PHD_ROOT/papers"
mkdir -p "$PHD_ROOT/data"
mkdir -p "$PHD_ROOT/learning"
mkdir -p "$PHD_ROOT/tools/scripts"
mkdir -p "$PHD_ROOT/tools/templates"
mkdir -p "$PHD_ROOT/tools/config"

# Copy tool files
echo "Copying workflow tools..."
cp -r tools/scripts/* "$PHD_ROOT/tools/scripts/"
cp -r tools/templates/* "$PHD_ROOT/tools/templates/"
cp -r tools/config/* "$PHD_ROOT/tools/config/"

# Make scripts executable
chmod +x "$PHD_ROOT/tools/scripts/"*.sh
chmod +x "$PHD_ROOT/tools/templates/"*/*.sh

# Update paths in activation script
echo "Configuring scripts..."
SCRIPT_PATH="$PHD_ROOT/tools/scripts/phd_activate.sh"
sed -i "s|PHD_ROOT=.*|PHD_ROOT=\"$PHD_ROOT\"|g" "$SCRIPT_PATH"

# Add to shell config
SHELL_CONFIG="$HOME_DIR/.bashrc"
if [ -f "$HOME_DIR/.zshrc" ]; then
    SHELL_CONFIG="$HOME_DIR/.zshrc"
    echo "Zsh detected, using .zshrc"
fi

# Check if already in shell config
if grep -q "phd_activate.sh" "$SHELL_CONFIG"; then
    echo "PhD workflow already in $SHELL_CONFIG"
else
    echo "Adding to $SHELL_CONFIG..."
    echo "" >> "$SHELL_CONFIG"
    echo "# PhD Workflow" >> "$SHELL_CONFIG"
    echo "source $PHD_ROOT/tools/scripts/phd_activate.sh" >> "$SHELL_CONFIG"
fi

# Check for prerequisites
echo "Checking prerequisites..."

# Check for Git
if ! command -v git &> /dev/null; then
    echo "Warning: Git not found. Install Git for full functionality."
fi

# Check for Conda
if ! command -v conda &> /dev/null; then
    echo "Warning: Conda not found. Install Miniconda/Anaconda for environment management."
fi

# Check for GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "Note: GitHub CLI not found. Install for GitHub integration:"
    echo "  Linux: sudo apt install gh"
    echo "  macOS: brew install gh"
    echo "  Windows: scoop install gh"
    echo "Then authenticate with: gh auth login"
fi

# Check for AWS CLI
if ! command -v aws &> /dev/null; then
    echo "Note: AWS CLI not found. Install for AWS integration:"
    echo "  pip install awscli"
    echo "  aws configure"
fi

echo ""
echo "Installation complete! 🎉"
echo ""
echo "To get started:"
echo "1. Open a new terminal or run: source $SHELL_CONFIG"
echo "2. Run: phd_activate experiment"
echo "3. Run: phd_new my_first_experiment"
echo ""
echo "For detailed documentation, visit:"
echo "https://github.com/Amanpatni211/PhdWorkflowSetupTools-" 