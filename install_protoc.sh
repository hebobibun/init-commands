#!/bin/bash

# Check if a version is provided as an argument
if [ -z "$1" ]; then
  echo "Please provide a version as an argument (e.g., ./install_protoc.sh 29.0)."
  exit 1
fi

# Set the version for protoc
PROTOC_VERSION=$1

# Install dependencies
echo "Installing dependencies..."
sudo apt update
sudo apt install -y wget unzip build-essential

# Remove the existing protoc if it exists
echo "Removing any existing protoc installation..."
sudo rm -f /usr/local/bin/protoc
sudo rm -rf /usr/local/include/google

# Download and install the specified version of protoc
echo "Downloading protoc $PROTOC_VERSION..."
wget "https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOC_VERSION/protoc-${PROTOC_VERSION}-linux-x86_64.zip"

# Extract the downloaded zip file
echo "Extracting protoc..."
unzip "protoc-${PROTOC_VERSION}-linux-x86_64.zip" -d protoc

# Install protoc
echo "Installing protoc..."
sudo cp -r protoc/bin/* /usr/local/bin/
sudo cp -r protoc/include/* /usr/local/include/

# Clean up
rm -rf protoc "protoc-${PROTOC_VERSION}-linux-x86_64.zip"

# Verify protoc installation
echo "Verifying protoc installation..."
protoc --version

# Install the Go plugin for protoc
echo "Installing Go plugin for protoc..."
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

# Install the gRPC plugin for protoc
echo "Installing gRPC plugin for protoc..."
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest


# Ensure GOPATH/bin is in the PATH
echo "Adding GOPATH/bin to PATH..."
if ! grep -q '(go env GOPATH)/bin' ~/.bashrc; then
    echo 'export PATH="$PATH:$(go env GOPATH)/bin"' >> ~/.bashrc
fi

# sourcing bashrc
echo "Sourcing ~/.bashrc"
source ~/.bashrc

# Verify Go plugin installation
echo "Verifying Go plugin installation..."
protoc-gen-go --version
protoc-gen-go-grpc --version

echo "Installation complete!"
