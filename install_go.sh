#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# example : ./install_go.sh 1.22.7

# Check if a version argument is provided; default to 1.22.7 if not
GO_VERSION=${1:-1.22.7}
GO_TAR="go${GO_VERSION}.linux-amd64.tar.gz"
GO_URL="https://go.dev/dl/${GO_TAR}"
INSTALL_DIR="/usr/bin"
GO_PATH="${INSTALL_DIR}/go"

# Remove any existing Go installation
if [ -d "$GO_PATH" ]; then
    echo "Removing existing Go installation from $GO_PATH..."
    sudo rm -rf "$GO_PATH"
fi

# Download Go tarball
echo "Downloading Go ${GO_VERSION}..."
wget -q "$GO_URL"

# Extract and install
echo "Installing Go ${GO_VERSION} to $INSTALL_DIR..."
sudo tar -C "$INSTALL_DIR" -xzf "$GO_TAR"

# Clean up downloaded file
rm "$GO_TAR"

# Update environment variables in .bashrc
BASHRC_FILE="$HOME/.bashrc"
if ! grep -q '/usr/local/go/bin' "$BASHRC_FILE"; then
    echo "Updating environment variables in $BASHRC_FILE..."
    echo 'export PATH=$PATH:/usr/local/go/bin' >> "$BASHRC_FILE"
    source "$BASHRC_FILE"
fi

# Verify installation
echo "Verifying Go installation..."
go version
echo "Go ${GO_VERSION} has been installed successfully."
