#!/bin/bash

# Setup script for experiment environment
echo "Setting up experiment environment..."

# Try to activate the ML_exp conda environment if it exists
if [ -f ~/miniconda3/etc/profile.d/conda.sh ]; then
    source ~/miniconda3/etc/profile.d/conda.sh
    conda activate ML_exp 2>/dev/null || echo "ML_exp environment not found. Continuing with current environment."
elif [ -f /c/Users/Admin/miniconda3/etc/profile.d/conda.sh ]; then
    source /c/Users/Admin/miniconda3/etc/profile.d/conda.sh
    conda activate ML_exp 2>/dev/null || echo "ML_exp environment not found. Continuing with current environment."
else
    echo "conda.sh not found. Continuing with current environment."
fi

# Create experiment notebook structure
mkdir -p data notebooks results

# Initialize git repository (useful even for experiments)
git init
echo "data/" >> .gitignore
echo "results/" >> .gitignore
echo ".ipynb_checkpoints/" >> .gitignore
echo "__pycache__/" >> .gitignore
echo "*.pyc" >> .gitignore

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
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOL

# Create README
echo "# Experiment: $(basename $(pwd))" > README.md
echo "Created on: $(date)" >> README.md
echo "" >> README.md
echo "## Quick Start" >> README.md
echo "1. Open notebooks/experiment.ipynb" >> README.md

echo "Experiment setup complete!" 