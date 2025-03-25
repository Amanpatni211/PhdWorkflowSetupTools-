#!/bin/bash

# Script to copy all PhD workflow tools to the GitHub repository structure
echo "Copying PhD workflow tools to repository structure..."

# Ensure directories exist
mkdir -p tools/scripts
mkdir -p tools/templates/experiment_template
mkdir -p tools/templates/project_template
mkdir -p tools/templates/aws_template
mkdir -p tools/config
mkdir -p docs

# Copy scripts
cp /mnt/c/Users/Admin/aman_projects/PhD/tools/scripts/phd_activate.sh tools/scripts/

# Copy templates
cp /mnt/c/Users/Admin/aman_projects/PhD/tools/templates/experiment_template/setup.sh tools/templates/experiment_template/
cp /mnt/c/Users/Admin/aman_projects/PhD/tools/templates/project_template/setup.sh tools/templates/project_template/
cp /mnt/c/Users/Admin/aman_projects/PhD/tools/templates/aws_template/setup.sh tools/templates/aws_template/

# Copy config
cp /mnt/c/Users/Admin/aman_projects/PhD/tools/config/phd_config.yml tools/config/

# Make scripts executable
chmod +x tools/scripts/*.sh
chmod +x tools/templates/*/*.sh
chmod +x *.sh

echo "Files copied successfully."
echo ""
echo "Next steps:"
echo "1. Push these files to your GitHub repository:"
echo "   git add ."
echo "   git commit -m \"Initial release of PhD workflow tools\""
echo "   git push origin main"
echo ""
echo "2. Share the repository URL with your lab members" 