#!/bin/bash

# Get project name from directory name
PROJECT_NAME=$(basename $(pwd))
ENV_NAME=$(echo $PROJECT_NAME | tr '-' '_')

echo "Setting up AWS project: $PROJECT_NAME"

# Ask about conda environment
read -p "Create a dedicated conda environment? (y/n): " CREATE_ENV
if [[ "$CREATE_ENV" == "y" ]]; then
    # Create conda environment specific to this project
    if [ -f ~/miniconda3/etc/profile.d/conda.sh ]; then
        source ~/miniconda3/etc/profile.d/conda.sh
    elif [ -f /c/Users/Admin/miniconda3/etc/profile.d/conda.sh ]; then
        source /c/Users/Admin/miniconda3/etc/profile.d/conda.sh 
    else
        echo "WARNING: conda.sh not found. Trying to use conda directly."
    fi
    
    conda create -y -n $ENV_NAME python=3.9
    conda activate $ENV_NAME
    
    # Install AWS dependencies
    conda install -y numpy pandas matplotlib jupyter ipykernel
    pip install boto3 awscli metaflow sagemaker

    echo "# Generated by conda environment creation" > environment.yml
    conda env export > environment.yml

    echo "Created conda environment: $ENV_NAME with AWS dependencies"
else
    echo "Skipping conda environment creation. Please install required packages manually."
fi

# Create modern ML project structure with AWS integrations
mkdir -p src/$PROJECT_NAME/{data,models,utils,visualization,cloud}
mkdir -p notebooks tests configs data results docs

# Create __init__.py files to make the modules importable
touch src/$PROJECT_NAME/__init__.py
touch src/$PROJECT_NAME/data/__init__.py
touch src/$PROJECT_NAME/models/__init__.py
touch src/$PROJECT_NAME/utils/__init__.py
touch src/$PROJECT_NAME/visualization/__init__.py
touch src/$PROJECT_NAME/cloud/__init__.py

# Create setup.py for easier importing
cat > setup.py << EOL
from setuptools import setup, find_packages

setup(
    name="$PROJECT_NAME",
    version="0.1",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
)
EOL

# Create AWS config directory
mkdir -p .aws
touch .aws/credentials.template
cat > .aws/credentials.template << EOL
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
region = us-east-1
EOL
echo ".aws/" >> .gitignore

# Setup Metaflow configuration
mkdir -p .metaflow
cat > .metaflow/config.json << EOL
{
    "METAFLOW_PROFILE": "aws",
    "METAFLOW_DEFAULT_DATASTORE": "s3",
    "METAFLOW_DEFAULT_METADATA": "service",
    "METAFLOW_S3_BUCKET_NAME": "phd-$PROJECT_NAME-metaflow"
}
EOL
echo ".metaflow/" >> .gitignore

# Create basic files
touch requirements.txt
cat > requirements.txt << EOL
# Core Data Science
numpy
pandas
matplotlib
scikit-learn

# AWS & Deployment
boto3
metaflow>=2.8.0
sagemaker
aws-cdk-lib
constructs>=10.0.0

# Notebooks
jupyter
ipykernel

# Development
pytest
black
flake8

# Add your additional requirements here
EOL

# Create README with AWS-focused documentation
cat > README.md << EOL
# $PROJECT_NAME

## AWS Setup
1. Configure AWS credentials:
   \`\`\`bash
   cp .aws/credentials.template .aws/credentials
   # Edit .aws/credentials with your AWS access keys
   \`\`\`
2. Set up S3 buckets:
   \`\`\`bash
   ./setup_aws.sh
   \`\`\`

## Environment Setup
\`\`\`bash
# Clone the repository
git clone https://github.com/Amanpatni211/$PROJECT_NAME.git
cd $PROJECT_NAME

# Option 1: Create and activate conda environment
conda env create -f environment.yml
conda activate $ENV_NAME

# Option 2: Install in existing environment
pip install -e .
pip install -r requirements.txt
\`\`\`

## Project Structure
\`\`\`
├── .aws/             # AWS credential templates (not in Git)
├── .metaflow/        # Metaflow configuration
├── configs/          # Configuration files
├── data/             # Raw and processed data (not in Git)
├── notebooks/        # Jupyter notebooks
├── results/          # Output of experiments (not in Git)
├── src/              # Source code
│   └── $PROJECT_NAME/
│       ├── cloud/    # AWS deployment code
│       ├── data/     # Data processing
│       ├── models/   # ML models
│       ├── utils/    # Utilities
│       └── visualization/ # Plotting and visualization
└── tests/            # Unit tests
\`\`\`

## Using Metaflow with AWS
\`\`\`python
from metaflow import FlowSpec, step, S3

class MyFlow(FlowSpec):
    @step
    def start(self):
        self.next(self.process_data)
        
    @step
    def process_data(self):
        """Process the data."""
        import numpy as np
        self.data = np.random.random(10)
        self.next(self.store_results)
        
    @step
    def store_results(self):
        """Store results to S3."""
        import pickle
        # Store to S3 when running on AWS
        with S3(run=self) as s3:
            s3.put("results.pkl", pickle.dumps(self.data))
        self.next(self.end)
        
    @step
    def end(self):
        """End the flow."""
        print("Flow complete!")

if __name__ == '__main__':
    MyFlow()
\`\`\`

## License
Copyright (c) $(date +%Y) [Your Name]
EOL

# Initialize git repository
git init
echo "data/" >> .gitignore
echo "results/" >> .gitignore
echo ".ipynb_checkpoints/" >> .gitignore
echo "__pycache__/" >> .gitignore
echo "*.pyc" >> .gitignore
echo ".aws/credentials" >> .gitignore
echo "*.egg-info/" >> .gitignore
echo ".vscode/" >> .gitignore
echo ".idea/" >> .gitignore

# Create config template
mkdir -p configs
cat > configs/default.yml << EOL
# Project configuration
project_name: $PROJECT_NAME
aws:
  region: us-east-1
  s3_bucket: phd-$PROJECT_NAME-data
  batch_compute_environment: myjobenv
data_path: data/
results_path: results/
EOL

# Create AWS setup script
cat > setup_aws.sh << EOL
#!/bin/bash
echo "Setting up AWS resources for $PROJECT_NAME..."

# Create S3 buckets
aws s3 mb s3://phd-$PROJECT_NAME-data
aws s3 mb s3://phd-$PROJECT_NAME-results
aws s3 mb s3://phd-$PROJECT_NAME-metaflow

echo "AWS S3 buckets created"

# Optional: Configure Metaflow to use AWS 
metaflow configure aws
EOL
chmod +x setup_aws.sh

# Create example Metaflow script
mkdir -p src/$PROJECT_NAME/cloud
cat > src/$PROJECT_NAME/cloud/example_flow.py << EOL
"""Example Metaflow workflow."""
from metaflow import FlowSpec, step, S3, batch, conda_base

@conda_base(libraries={'scikit-learn': '1.0.2', 'pandas': '1.4.1'})
class ${ENV_NAME}Flow(FlowSpec):
    """
    A simple Metaflow for $PROJECT_NAME.
    
    Run with:
    python -m src.$PROJECT_NAME.cloud.example_flow run
    
    Run on AWS Batch:
    python -m src.$PROJECT_NAME.cloud.example_flow run --with batch
    """
    
    @step
    def start(self):
        """Start the flow."""
        import numpy as np
        self.data = np.random.random(10)
        self.next(self.process)
        
    @step
    def process(self):
        """Process the data."""
        import numpy as np
        self.processed_data = self.data * 2
        self.next(self.store_results)
        
    @step
    def store_results(self):
        """Store results to S3."""
        import pickle
        # Store to S3 when running on AWS
        with S3(run=self) as s3:
            s3.put("results.pkl", pickle.dumps(self.processed_data))
        self.next(self.end)
        
    @step
    def end(self):
        """End the flow."""
        print("Flow complete!")

if __name__ == "__main__":
    ${ENV_NAME}Flow()
EOL

# Create a simple AWS utility module
cat > src/$PROJECT_NAME/cloud/aws_utils.py << EOL
"""AWS utility functions."""
import os
import boto3
import logging

logger = logging.getLogger(__name__)

def get_s3_client():
    """Get a boto3 S3 client."""
    return boto3.client('s3')

def upload_to_s3(local_path, bucket, s3_key):
    """Upload a file to S3.
    
    Args:
        local_path (str): Local file path
        bucket (str): S3 bucket name
        s3_key (str): S3 object key
    """
    s3 = get_s3_client()
    try:
        s3.upload_file(local_path, bucket, s3_key)
        logger.info(f"Uploaded {local_path} to s3://{bucket}/{s3_key}")
        return True
    except Exception as e:
        logger.error(f"Failed to upload {local_path}: {e}")
        return False

def download_from_s3(bucket, s3_key, local_path):
    """Download a file from S3.
    
    Args:
        bucket (str): S3 bucket name
        s3_key (str): S3 object key
        local_path (str): Local file path
    """
    s3 = get_s3_client()
    try:
        s3.download_file(bucket, s3_key, local_path)
        logger.info(f"Downloaded s3://{bucket}/{s3_key} to {local_path}")
        return True
    except Exception as e:
        logger.error(f"Failed to download s3://{bucket}/{s3_key}: {e}")
        return False
EOL

# Create notebook for AWS exploration
mkdir -p notebooks
cat > notebooks/01_aws_exploration.ipynb << EOL
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# $PROJECT_NAME: AWS Exploration\n",
    "Created: $(date)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "import sys\n",
    "sys.path.append(\"..\")\n",
    "\n",
    "import boto3\n",
    "import pandas as pd\n",
    "import numpy as np\n",
    "import matplotlib.pyplot as plt\n",
    "\n",
    "# Import project modules\n",
    "from src.$PROJECT_NAME.cloud import aws_utils\n",
    "\n",
    "%matplotlib inline"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "# Connect to AWS services\n",
    "s3 = boto3.client('s3')\n",
    "\n",
    "# List buckets\n",
    "response = s3.list_buckets()\n",
    "for bucket in response['Buckets']:\n",
    "    print(bucket['Name'])"
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

echo "AWS Project setup complete!" 