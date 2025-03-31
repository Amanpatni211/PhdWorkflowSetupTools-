#!/bin/bash

# PhD Workflow Tools Installer
echo "PhD Workflow Tools Installer"
echo "==========================="
echo ""

# Ask user for the directory where they want to create the PhD folder
echo "Please enter the full path where you want to create your PhD workflow directory."
echo "For example:"
echo "  - On Windows: C:/Users/YourName/Documents"
echo "  - On Linux/WSL: /home/username or ~/Documents"
echo "  - On macOS: /Users/username or ~/Documents"
echo ""
echo "We will create a 'PhD' folder in your specified location with the required structure."
echo ""

# Determine the user's home directory regardless of OS
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    HOME_DIR=$(cygpath -u "$USERPROFILE")
else
    HOME_DIR="$HOME"
fi

# Default suggestion
DEFAULT_DIR="$HOME_DIR/Documents"

# Get the parent directory from the user
read -p "Parent directory for PhD folder [$DEFAULT_DIR]: " parent_dir
parent_dir=${parent_dir:-$DEFAULT_DIR}

# Set PHD_ROOT as the parent directory + /PhD
PHD_ROOT="${parent_dir}/PhD"

# Remove any double slashes
PHD_ROOT=$(echo "$PHD_ROOT" | sed 's|//|/|g')

echo ""
echo "Will create PhD workflow structure at: $PHD_ROOT"
read -p "Continue? (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Installation cancelled."
    exit 0
fi

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
ACTIVATION_LINE="source $PHD_ROOT/tools/scripts/phd_activate.sh"
if grep -q "phd_activate.sh" "$SHELL_CONFIG"; then
    echo "PhD workflow already in $SHELL_CONFIG"
else
    echo ""
    echo "Adding activation script to $SHELL_CONFIG..."
    echo "The following line will be added:"
    echo "  $ACTIVATION_LINE"
    echo ""
    
    # Ask for confirmation before modifying shell config
    read -p "Proceed with adding to $SHELL_CONFIG? (y/n): " confirm_shell
    if [[ "$confirm_shell" == "y" || "$confirm_shell" == "Y" ]]; then
        echo "" >> "$SHELL_CONFIG"
        echo "# PhD Workflow" >> "$SHELL_CONFIG"
        echo "$ACTIVATION_LINE" >> "$SHELL_CONFIG"
        echo "Successfully added activation script to $SHELL_CONFIG"
    else
        echo ""
        echo "Shell configuration not modified."
        echo "To manually activate the PhD workflow tools, add this line to your shell config file:"
        echo ""
        echo "  $ACTIVATION_LINE"
        echo ""
        echo "Or you can run this line in your terminal whenever you need to use the tools."
    fi
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
echo "   (This loads the PhD workflow tools into your current session)"
echo ""
echo "2. Activate the environment you want to work with:"
echo "   phd_activate experiment   (For quick experiments)"
echo "   phd_activate project      (For long-term research projects)"
echo "   phd_activate aws          (For AWS-integrated ML projects)"
echo ""
echo "3. Create a new project/experiment:"
echo "   phd_new my_first_experiment"
echo "   phd_new my_research_project --github  (Requires GitHub CLI setup)"
echo ""
echo "Your PhD workflow structure is ready at:"
echo "  $PHD_ROOT"
echo ""
echo "For detailed documentation, visit:"
echo "https://github.com/Amanpatni211/PhdWorkflowSetupTools-" 