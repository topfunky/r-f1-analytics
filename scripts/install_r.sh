#!/bin/bash

# Install R from CRAN on Ubuntu
# Based on instructions from https://learnubuntu.com/install-r/

set -e  # Exit on error

echo "Installing R from CRAN..."

# Get Ubuntu version codename
UBUNTU_CODENAME=$(lsb_release -cs)
echo "Detected Ubuntu codename: $UBUNTU_CODENAME"

# Install prerequisite packages
echo "Installing prerequisites..."
sudo apt update
sudo apt install -y software-properties-common dirmngr wget

# Add CRAN GPG key
echo "Adding CRAN GPG key..."
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc

# Add CRAN repository
echo "Adding CRAN repository..."
echo "deb https://cloud.r-project.org/bin/linux/ubuntu $UBUNTU_CODENAME-cran40/" | sudo tee -a /etc/apt/sources.list.d/cran-r.list

# Update package lists
echo "Updating package lists..."
sudo apt update

# Install R
echo "Installing R-base..."
sudo apt install -y r-base r-base-dev

# Verify installation
echo ""
echo "R installation complete!"
echo "Installed version:"
R --version | head -n 1

echo ""
echo "To start R, run: R"
echo "To install project dependencies, run: Rscript -e \"install.packages(c('ggplot2', 'dplyr', 'tidyr', 'lubridate', 'scales')); remotes::install_github('SCasanova/f1dataR')\""
