#!/bin/bash

# Define the name of the virtual environment
VENV_NAME="pywal-accent-color-env"

# Create a virtual environment
python3 -m venv $VENV_NAME

# Activate the virtual environment
source $VENV_NAME/bin/activate

# Upgrade pip to the latest version
pip install --upgrade pip

# Install the required packages
pip install numpy pillow scikit-image scikit-learn

# Inform the user
echo "Virtual environment '$VENV_NAME' created and packages installed."
