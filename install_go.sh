#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# Add error handling
trap 'echo "Error occurred at line $LINENO. Command was: $BASH_COMMAND"' ERR

# example : ./install_go.sh 1.22.7

# Check if a version argument is provided; default to 1.22.7 if not
GO_VERSION=${1:-1.22.7}
GO_TAR="go${GO_VERSION}.linux-amd64.tar.gz"
GO_URL="https://go.dev/dl/${GO_TAR}"
INSTALL_DIR="/usr/bin"
GO_PATH="${INSTALL_DIR}/go"
CACHE_DIR="/opt/go-versions"
VERSION_DIR="${CACHE_DIR}/${GO_VERSION}"

echo "Debug: Download URL is $GO_URL"

# Create cache directory if it doesn't exist
if [ ! -d "$CACHE_DIR" ]; then
    echo "Creating cache directory at $CACHE_DIR..."
    sudo mkdir -p "$CACHE_DIR"
fi

# Check if requested version is already cached
if [ -d "$VERSION_DIR" ]; then
    echo "Found cached Go ${GO_VERSION} at $VERSION_DIR"
else
    # Clean up any existing tar files first
    rm -f "${GO_TAR}"*

    # Download Go tarball with progress and error checking
    echo "Downloading Go ${GO_VERSION}..."
    if ! wget --progress=bar:force:noscroll -O "${GO_TAR}" "$GO_URL" 2>&1; then
        echo "Error: Download failed. Please check if version $GO_VERSION exists at https://go.dev/dl/"
        sudo rm -f "${GO_TAR}"*
        exit 1
    fi

    # Verify the file was downloaded
    if [ ! -f "$GO_TAR" ]; then
        echo "Error: Download file not found"
        sudo rm -f "${GO_TAR}"*
        exit 1
    fi

    # Extract to cache directory
    echo "Caching Go ${GO_VERSION}..."
    sudo mkdir -p "$VERSION_DIR"
    sudo tar -C "$VERSION_DIR" -xzf "$GO_TAR"

    # Clean up downloaded file
    rm -f "$GO_TAR"
fi

# Update the main Go installation
if [ -d "$GO_PATH" ] || [ -L "$GO_PATH" ]; then
    echo "Removing existing Go installation from $GO_PATH..."
    sudo rm -rf "$GO_PATH"
fi

# Create symbolic link from cache to install directory
echo "Installing Go ${GO_VERSION} to $INSTALL_DIR..."
sudo ln -s "${VERSION_DIR}/go/bin/go" "$GO_PATH"

# Update PATH in current session
export PATH="$PATH:/usr/local/go/bin"

# Update environment variables in .bashrc if needed
BASHRC_FILE="$HOME/.bashrc"
GO_PATH_LINE='export PATH=$PATH:/usr/local/go/bin'
if ! grep -q "$GO_PATH_LINE" "$BASHRC_FILE"; then
    echo "Updating environment variables in $BASHRC_FILE..."
    echo "$GO_PATH_LINE" >> "$BASHRC_FILE"
fi

# source
echo "sourcing ~/.bashrc..."
source ~/.bashrc
echo "source completed."

# Verify installation
echo "Verifying Go installation..."
INSTALLED_VERSION=$(go version)
echo "Installed version: $INSTALLED_VERSION"

if [[ "$INSTALLED_VERSION" == *"$GO_VERSION"* ]]; then
    echo "Go ${GO_VERSION} has been installed successfully."
else
    echo "Warning: Version mismatch. Expected ${GO_VERSION}, got ${INSTALLED_VERSION}"
    echo "Please check the installation."
fi

# List all cached versions
echo -e "\nCached Go versions:"
ls -1 "$CACHE_DIR"

# Cleanup any leftover temporary files
sudo rm -f go*.tar.gz*