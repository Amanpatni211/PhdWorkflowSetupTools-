#!/bin/bash

# Setup script for experiment environment
echo "Setting up experiment environment..."

# Try to source conda activation script and activate ML_exp
CONDA_ACTIVATED=false
CONDA_BASE=$(conda info --base 2>/dev/null)
if [[ -n "$CONDA_BASE" && -f "$CONDA_BASE/etc/profile.d/conda.sh" ]]; then
    source "$CONDA_BASE/etc/profile.d/conda.sh"
    if conda activate ML_exp 2>/dev/null; then
        echo "Activated ML_exp conda environment (from $CONDA_BASE)" 
        CONDA_ACTIVATED=true
    fi
elif [[ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
    if conda activate ML_exp 2>/dev/null; then
        echo "Activated ML_exp conda environment (from $HOME/miniconda3)" 
        CONDA_ACTIVATED=true
    fi
elif [[ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]]; then
    source "$HOME/anaconda3/etc/profile.d/conda.sh"
    if conda activate ML_exp 2>/dev/null; then
        echo "Activated ML_exp conda environment (from $HOME/anaconda3)" 
        CONDA_ACTIVATED=true
    fi
fi

if [ "$CONDA_ACTIVATED" = false ]; then
    # Try activating directly if sourcing failed or env activation failed above
    if conda activate ML_exp 2>/dev/null; then
        echo "Activated ML_exp conda environment (direct activation)" 
        CONDA_ACTIVATED=true
    else
         echo "WARNING: Could not activate 'ML_exp' conda environment. Please ensure it exists or proceed with the base environment."
    fi
fi

# Create experiment notebook structure
mkdir -p data notebooks results

# Initialize git repository if it doesn't exist (useful even for experiments)
if [ ! -d .git ]; then
    git init
    echo "Initialized local git repository."
fi

# Add common ignores to .gitignore
echo "\n# Data & Results\ndata/\nresults/\n\n# IDE & Environment specific\n.vscode/\n.idea/\n.ipynb_checkpoints/\n\n# Python specific\n__pycache__/\n*.pyc\n*.pyo\n*.pyd\n*.egg-info/\n\n# Secrets\n*.env\n" >> .gitignore

# Create starter notebook
mkdir -p notebooks
cat > notebooks/experiment.ipynb << EOL
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Experiment: $(basename $(pwd))\n",
    "Created: $(date)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "import numpy as np\n",
    "import pandas as pd\n",
    "import matplotlib.pyplot as plt\n",
    "\n",
    "%matplotlib inline"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3 (ipykernel)",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "name": "python",
   "version": "3.9.12" # Example version
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
EOL

# Create README
echo "# Experiment: $(basename $(pwd))" > README.md
echo "Created on: $(date)" >> README.md
echo "" >> README.md
echo "## Quick Start" >> README.md
echo "1. Ensure your Conda environment (ideally 'ML_exp') is activated." >> README.md
echo "2. Open notebooks/experiment.ipynb" >> README.md

echo "Experiment setup complete!" 