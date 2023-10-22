#!/bin/bash

function is_command_installed(){
    if command -v $1 > /dev/null 2>&1; then
        # 0 = true
        return 0
    else 
        # 1 = false
        return 1
    fi
}

# Function to install Go
function install_go(){
    echo "Go is NOT installed. Installing Go..."
    if curl -sSfL --url https://raw.githubusercontent.com/codenoid/install-latest-go-linux/main/install-go.sh | bash; then
        echo "Go installed successfully."
        sleep 1
        echo "If using zsh, add the export lines to your ~/.zshrc file, or wherever you put your PATH export for zsh."
    else
        echo "Failed to install Go. Exiting."
        exit 1
    fi
}

# Function to install Rust
function install_rust(){
    if curl --proto '=https' --tlsv1.3 https://sh.rustup.rs -sSf | sh && source $HOME/.cargo/env; then
        echo "Rust installed successfully."
        return 0
    else
        echo "Failed to install Rust. Exiting."
        return 1
    fi
}

# ============BEGIN============
# check if necessary packages are installed
if is_command_installed apt-get; then
    sudo apt-get update -y

    # Install required packages
    req_pkgs=(build-essential git wget curl python3 python3-pip nmap)
    for package in "${req_pkgs[@]}"; do
        if sudo apt-get install $package -y; then
            echo "Installed $package successfully."
        else
            echo "Failed to install $package. Exiting."
            exit 1
        fi
    done
else
    echo "This script is designed for Debian based distros like Kali Linux or Parrot OS."
    echo "If your distro uses a different package manager from apt, you won't be able to use this script."
    exit 1
fi

# ============CHECK FOR GO INSTALL============
# Check for Go installation
if is_command_installed go; then
    echo "Go is installed. Great."
else
    install_go
fi

# ============CHECK FOR RUST INSTALL============
if is_command_installed rustc; then
    echo "Rust is installed. Great."
else
    echo "Rust isn't installed. Installing Rust..."
    if install_rust; then
        echo "Rust installed successfully."
    else
        echo "Failed to install Rust. Exiting."
        exit 1
    fi
fi

# Remove rustscan .deb file if present
[ -f "rustscan_2.0.1_amd64.deb" ] && rm -f ./rustscan_2.0.1_amd64.deb

# Install Python package
if is_command_installed pip3 || is_command_installed pip; then
    if pip3 install dirsearch || pip install dirsearch; then
        echo "dirsearch installed successfully."
    else
        echo "Error installing dirsearch. Make sure python3 and pip are installed correctly."
        exit 1
    fi
else
    echo "pip3 or pip not found. Exiting."
    exit 1
fi
