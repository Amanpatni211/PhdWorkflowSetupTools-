# PhD Workflow Setup Tools

A structured workflow system for organizing and managing PhD research in machine learning, climate modeling, and data analysis.

![PhD Workflow](https://img.shields.io/badge/PhD-Workflow-blue)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

## Overview

This toolset provides a standardized workflow for PhD research projects, helping you organize experiments, manage projects, and integrate with cloud computing resources.

### Key Features

- **Experiment Management**: Quickly create dated experiment directories with proper structure
- **Project Organization**: Set up research projects with proper Python packaging
- **GitHub Integration**: Automatic GitHub repository creation and management
- **AWS Integration**: Optional AWS setup with Metaflow for ML workflows
- **Environment Management**: Conda environment handling for reproducible research

## Installation

```bash
# Clone the repository
git clone https://github.com/Amanpatni211/PhdWorkflowSetupTools-.git
cd PhdWorkflowSetupTools-

# Run the installation script
./install.sh
```

The installer will:
1. Create the PhD directory structure in your home directory
2. Copy the workflow tools to the appropriate locations
3. Add the activation script to your shell configuration

## Quick Start

After installation, open a new terminal or run `source ~/.bashrc` to load the tools. Then:

```bash
# For quick experiments
phd_activate experiment
phd_new my_experiment

# For serious projects with GitHub integration
phd_activate project
phd_new my_project --github

# For AWS-integrated ML projects
phd_activate aws
phd_new ml_project --github --aws
```

## Folder Structure

```
PhD/
├── experiments/      # Quick experiments and learning
├── projects/         # Serious research projects
├── data/             # Shared datasets
├── papers/           # Research papers and writing
├── learning/         # Learning materials and courses
└── tools/            # Workflow tools and scripts
    ├── config/       # Configuration files
    ├── scripts/      # Workflow scripts
    └── templates/    # Project templates
```

## Usage Details

### Experiment Workflow

Experiments are quick, exploratory work:

```bash
phd_activate experiment
phd_new test_hypothesis
```
ps: go in bash -> command is <nano ~/.bashrc> -> paste the code -> save and exit (ctrl+x -> y -> enter)

This creates:
- A dated directory (e.g., `20250401_test_hypothesis/`)
- Basic notebook structure
- Data and results directories
- Simple git initialization

### Project Workflow

Projects are serious, long-term research:

```bash
phd_activate project
phd_new climate_model --github
```

This creates:
- GitHub repository
- Full Python package structure
- Tests directory
- Documentation setup
- Proper environment configuration

### AWS Integration

For ML projects requiring cloud computing:

```bash
phd_activate aws
phd_new ml_deployment --github --aws
```

This adds:
- AWS credential templates
- S3 bucket setup scripts
- Metaflow integration
- Deployment templates

## Prerequisites

- Bash or Zsh shell
- Git
- Conda (for environment management)
- GitHub CLI (for GitHub integration)
- AWS CLI (for AWS integration, optional)

## Configuration

Edit the following files to customize your workflow:

- `~/aman_projects/PhD/tools/config/phd_config.yml` - Main configuration
- Templates in `~/aman_projects/PhD/tools/templates/` - Project templates

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. 