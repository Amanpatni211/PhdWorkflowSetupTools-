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

# Expand tilde (~) to home directory if present
if [[ "$parent_dir" == "~"* ]]; then
    parent_dir="${parent_dir/#\~/$HOME_DIR}"
fi

# Ensure we're using an absolute path
if [[ "$parent_dir" != /* && "$parent_dir" != [A-Za-z]:* ]]; then
    # If it's not an absolute path, make it absolute based on current directory
    parent_dir="$(pwd)/$parent_dir"
fi

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
echo ""
echo "Setting up shell integration..."

# Determine the correct shell config file
if [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
    SHELL_CONFIG="$HOME/.bashrc"
    echo "Bash shell detected"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
    SHELL_CONFIG="$HOME/.zshrc"
    echo "Zsh shell detected"
else
    # Default to bashrc if we can't detect, but try zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        SHELL_TYPE="zsh"
        SHELL_CONFIG="$HOME/.zshrc"
        echo "Found .zshrc (shell type not detected)"
    else
        SHELL_TYPE="bash"
        SHELL_CONFIG="$HOME/.bashrc"
        echo "Defaulting to .bashrc (shell type not detected)"
    fi
fi

echo "Using shell config file: $SHELL_CONFIG"

# Check if the config file exists
if [ ! -f "$SHELL_CONFIG" ]; then
    echo "WARNING: Shell config file $SHELL_CONFIG does not exist"
    echo "Creating it now..."
    touch "$SHELL_CONFIG"
    if [ ! -f "$SHELL_CONFIG" ]; then
        echo "ERROR: Failed to create $SHELL_CONFIG"
        echo "You will need to manually add the activation line to your shell config."
    fi
fi

# Check if already in shell config
# Convert PHD_ROOT to use ~ if it's in the home directory
if [[ "$PHD_ROOT" == "$HOME"* ]]; then
    # Replace the home directory with ~
    DISPLAY_PHD_ROOT="${PHD_ROOT/$HOME/\~}"
    echo "Using ~ notation for home directory in shell config"
else
    DISPLAY_PHD_ROOT="$PHD_ROOT"
fi

ACTIVATION_LINE="source $DISPLAY_PHD_ROOT/tools/scripts/phd_activate.sh"

# More reliable check that handles different path formats
if grep -F "phd_activate.sh" "$SHELL_CONFIG" >/dev/null 2>&1; then
    echo "PhD workflow activation already found in $SHELL_CONFIG"
    echo "Current line in $SHELL_CONFIG:"
    grep -F "phd_activate.sh" "$SHELL_CONFIG"
    
    # Ask if they want to update it
    read -p "Update to the new path? (y/n): " update_path
    if [[ "$update_path" == "y" || "$update_path" == "Y" ]]; then
        # Try to replace existing line
        sed -i'.bak' -e "s|source .*phd_activate.sh.*|$ACTIVATION_LINE|g" "$SHELL_CONFIG"
        echo "Updated activation path in $SHELL_CONFIG"
    fi
else
    echo ""
    echo "Adding activation script to $SHELL_CONFIG..."
    echo "The following line will be added:"
    echo "  $ACTIVATION_LINE"
    echo ""
    
    # Ask for confirmation before modifying shell config
    read -p "Proceed with adding to $SHELL_CONFIG? (y/n): " confirm_shell
    if [[ "$confirm_shell" == "y" || "$confirm_shell" == "Y" ]]; then
        # Directly append to file
        echo "" >> "$SHELL_CONFIG"
        echo "# PhD Workflow" >> "$SHELL_CONFIG"
        echo "$ACTIVATION_LINE" >> "$SHELL_CONFIG"
        
        # Verify it was added
        if grep -F "$ACTIVATION_LINE" "$SHELL_CONFIG" >/dev/null 2>&1; then
            echo "Successfully added activation script to $SHELL_CONFIG"
        else
            echo "WARNING: Failed to add activation script to $SHELL_CONFIG"
            echo "Try adding it manually:"
            echo ""
            echo "echo \"$ACTIVATION_LINE\" >> $SHELL_CONFIG"
        fi
    else
        echo ""
        echo "Shell configuration not modified."
        echo "To manually activate the PhD workflow tools, add this line to your shell config file:"
        echo ""
        echo "  $ACTIVATION_LINE"
        echo ""
        echo "Or run this line directly in your terminal:"
        echo ""
        echo "  $ACTIVATION_LINE"
    fi
fi

# For immediate use without restarting the shell
echo ""
echo "To activate the PhD workflow tools in your current terminal, run:"
echo "  $ACTIVATION_LINE"

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