# PhD Workflow Setup Tools

A structured workflow system for organizing and managing PhD research in machine learning, climate modeling, and data analysis.

![PhD Workflow](https://img.shields.io/badge/PhD-Workflow-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

## Overview

This toolset provides a standardized workflow for PhD research projects, helping you organize experiments, manage projects, and integrate with cloud computing resources.

### Key Features

- **Experiment Management**: Quickly create dated experiment directories with proper structure
- **Project Organization**: Set up research projects with proper Python packaging
- **GitHub Integration**: Automatic GitHub repository creation and management (using GitHub CLI)
- **AWS Integration**: Optional AWS setup with Metaflow for ML workflows
- **Environment Management**: Conda environment handling for reproducible research (flexible detection)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/Amanpatni211/PhdWorkflowSetupTools-.git
cd PhdWorkflowSetupTools-
```

2. Run the installation script:
```bash
chmod +x install.sh
./install.sh
```

During installation, you'll be prompted to:
1. Choose your preferred root directory for the PhD workflow (e.g., `~/aman/PhD` or any other location)
2. The installer will create the directory structure, set up the tools, and add the activation script to your shell configuration (`.bashrc` or `.zshrc`).

## Quick Start

After installation, open a new terminal or run:
```bash
source ~/.bashrc  # For bash
# OR
source ~/.zshrc   # For zsh
```

Then you can use the following commands:

```bash
# For quick experiments
phd_activate experiment
phd_new my_experiment

# For serious projects with GitHub integration
# (Requires GitHub CLI installed and authenticated: gh auth login)
phd_activate project
phd_new my_project --github

# For AWS-integrated ML projects
# (Requires AWS CLI installed and configured: aws configure)
phd_activate aws
phd_new ml_project --github --aws
```

### Environment Notes

- **Experiment Mode**: When you use `phd_activate experiment`, the system will attempt to activate a Conda environment named `ML_exp` if it exists on your system. If this environment doesn't exist, it will continue with your current environment. You can create this environment manually with your preferred packages:
  ```bash
  conda create -n ML_exp python=3.9 numpy pandas matplotlib jupyter
  ```

- **Project Mode**: When creating a project with `phd_new`, you'll be prompted whether to create a dedicated Conda environment for that specific project.

## Folder Structure

```
<Your Chosen PhD Root Directory>/
├── experiments/      # Quick experiment and learning
├── projects/         # Serious research projects
├── data/             # Shared datasets (create manually if needed)
├── papers/           # Research papers and writing (create manually if needed)
├── learning/         # Learning materials and courses (create manually if needed)
└── tools/            # Workflow tools and scripts (installed)
    ├── config/       # Configuration files
    ├── scripts/      # Workflow scripts
    └── templates/    # Project templates
```

## Prerequisites

- Bash or Zsh shell
- Git
- Conda (for environment management - the scripts attempt to auto-detect your Conda installation)
- GitHub CLI (`gh`) (Required for GitHub integration. Install and run `gh auth login`)
- AWS CLI (`aws`) (Required for AWS integration. Install and run `aws configure`)

## Configuration

- Main configuration for the tools is handled by the scripts based on the chosen root directory.
- Project-specific configuration can be found within each generated project (e.g., `configs/default.yml`).
- Templates used for new projects/experiments are in `<Your Chosen PhD Root Directory>/tools/templates/`.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. 
