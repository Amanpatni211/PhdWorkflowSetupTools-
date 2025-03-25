#!/bin/bash

# PhD workflow activation script
PHD_ROOT="/mnt/c/Users/Admin/aman_projects/PhD"
SCRIPTS_DIR="$PHD_ROOT/tools/scripts"
TEMPLATES_DIR="$PHD_ROOT/tools/templates"
CONFIG_DIR="$PHD_ROOT/tools/config"

# Ensure paths exist
mkdir -p "$PHD_ROOT"
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$TEMPLATES_DIR"
mkdir -p "$CONFIG_DIR"

# Function to activate different environments
phd_activate() {
    if [ $# -eq 0 ]; then
        echo "Usage: phd_activate <environment>"
        echo "Available environments: experiment, project, aws"
        return 1
    fi

    # Source conda - fix for WSL2
    if [ -f ~/miniconda3/etc/profile.d/conda.sh ]; then
        source ~/miniconda3/etc/profile.d/conda.sh
    elif [ -f /mnt/c/Users/Admin/miniconda3/etc/profile.d/conda.sh ]; then
        source /mnt/c/Users/Admin/miniconda3/etc/profile.d/conda.sh
    else
        echo "WARNING: conda.sh not found. Trying to use conda directly."
    fi
    
    case $1 in
        "experiment")
            echo "Activating experiment environment..."
            # Check if ML_exp exists, if not just continue
            conda activate ML_exp 2>/dev/null || echo "ML_exp environment not found. Continuing without activation."
            export PHD_MODE="experiment"
            export PHD_TEMPLATE="$TEMPLATES_DIR/experiment_template"
            ;;
        "project")
            echo "Activating project environment..."
            # For project-specific environments - handled during project creation
            export PHD_MODE="project"
            export PHD_TEMPLATE="$TEMPLATES_DIR/project_template"
            ;;
        "aws")
            echo "Activating AWS environment..."
            export PHD_MODE="aws"
            export PHD_TEMPLATE="$TEMPLATES_DIR/aws_template"
            
            # Check if AWS credentials exist
            if [ -f ~/.aws/credentials ]; then
                echo "AWS credentials found."
                # Export AWS variables for Metaflow integration
                export AWS_DEFAULT_REGION=$(grep region ~/.aws/credentials | head -1 | cut -d= -f2 | tr -d ' ')
                export METAFLOW_PROFILE=aws
                export METAFLOW_DEFAULT_DATASTORE=s3
                echo "AWS environment variables set."
            else
                echo "WARNING: AWS credentials not found. Create them at ~/.aws/credentials"
                echo "See https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html"
            fi
            ;;
        *)
            echo "Unknown environment: $1"
            echo "Available environments: experiment, project, aws"
            return 1
            ;;
    esac
    
    echo "Environment activated: $PHD_MODE"
    echo "Use 'phd_new' to create a new project/experiment"
}

# Function to create new projects
phd_new() {
    if [ $# -eq 0 ]; then
        echo "Usage: phd_new <name> [--github] [--aws]"
        echo "Creates a new project or experiment based on current PHD_MODE"
        return 1
    fi
    
    NAME=$1
    USE_GITHUB=false
    USE_AWS=false
    
    # Check for flags
    if [[ "$*" == *"--github"* ]]; then
        USE_GITHUB=true
    fi
    
    if [[ "$*" == *"--aws"* ]]; then
        USE_AWS=true
    fi
    
    # Get current date for naming
    DATE=$(date +%Y%m%d)
    
    case $PHD_MODE in
        "experiment")
            TARGET_DIR="$PHD_ROOT/experiments/${DATE}_${NAME}"
            echo "Creating new experiment at $TARGET_DIR"
            mkdir -p "$TARGET_DIR"
            cp -r "$PHD_TEMPLATE"/* "$TARGET_DIR"
            
            # Run setup script
            cd "$TARGET_DIR"
            bash setup.sh
            ;;
        "project"|"aws")
            TARGET_DIR="$PHD_ROOT/projects/$NAME"
            echo "Creating new $PHD_MODE project at $TARGET_DIR"
            
            if [ "$USE_GITHUB" = true ]; then
                echo "Setting up GitHub repository..."
                
                # Check if GitHub CLI is installed
                if ! command -v gh &> /dev/null; then
                    echo "GitHub CLI not found. Install with: sudo apt install gh"
                    echo "Then authenticate with: gh auth login"
                    return 1
                fi
                
                # Create GitHub repo
                gh repo create "Amanpatni211/$NAME" --private
                
                # Clone the repo
                git clone "https://github.com/Amanpatni211/$NAME.git" "$TARGET_DIR"
                
                # Choose the template based on AWS flag
                TEMPLATE_TO_USE="$PHD_TEMPLATE"
                if [ "$USE_AWS" = true ] && [ "$PHD_MODE" = "project" ]; then
                    echo "Adding AWS integration..."
                    TEMPLATE_TO_USE="$TEMPLATES_DIR/aws_template"
                fi
                
                # Copy template files
                cp -r "$TEMPLATE_TO_USE"/* "$TARGET_DIR"
                
                # Run setup script
                cd "$TARGET_DIR"
                bash setup.sh
                
                # Commit template files
                git add .
                git commit -m "Initial project setup"
                git push
            else
                # Local only
                mkdir -p "$TARGET_DIR"
                
                # Choose the template based on AWS flag
                TEMPLATE_TO_USE="$PHD_TEMPLATE"
                if [ "$USE_AWS" = true ] && [ "$PHD_MODE" = "project" ]; then
                    echo "Adding AWS integration..."
                    TEMPLATE_TO_USE="$TEMPLATES_DIR/aws_template"
                fi
                
                cp -r "$TEMPLATE_TO_USE"/* "$TARGET_DIR"
                
                # Run setup script
                cd "$TARGET_DIR"
                bash setup.sh
            fi
            ;;
        *)
            echo "No environment activated. Run phd_activate first."
            return 1
            ;;
    esac
    
    echo "Project created successfully. You can now open it in your editor."
}

# Export functions
export -f phd_activate
export -f phd_new

# Display welcome message
echo "PhD workflow tools loaded. Available commands:"
echo "  phd_activate <environment> - Activate environment (experiment, project, aws)"
echo "  phd_new <name> [--github] [--aws] - Create a new project or experiment" 