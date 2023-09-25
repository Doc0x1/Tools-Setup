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

function install_go(){
    printf "%s\n" "Go is NOT installed. Installing go..."
    curl -fsSLo https://raw.githubusercontent.com/codenoid/install-latest-go-linux/main/install-go.sh | bash
    sleep 1
    printf "\n%s\n" "If using zsh, add the export lines to your ~/.zshrc file, or wherever you put your PATH export for zsh."
    sleep 4
}

function install_rust(){
    curl --proto '=https' --tlsv1.3 https://sh.rustup.rs -sSf | sh
    source $HOME/.cargo/env
    if is_command_installed cargo;  then
        printf "%s\n" "Rust installed successfully."
        return 0
    else
        return 1
    fi
}

# ============BEGIN============
# check if necessary packages are installed
req_pkgs=(build-essential git wget curl python3 python3-pip seclists nmap)

if command -v apt-get > /dev/null 2>&1; then
	sudo apt-get update -y
	for package in "${req_pkgs[@]}"; do
		sudo apt-get install $package -y
	done
else
	printf "%s\n" "This script is designed for Debian based distros like Kali Linux or Parrot OS."
    printf "%s\n" "If your distro uses a different package manager from apt, you won't be able to use this script."
    sleep 5 && exit
fi

# ============CHECK FOR GO INSTALL============
if is_command_installed go; then
    printf "%s\n" "Go is installed. Great."
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
    go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    go install github.com/tomnomnom/assetfinder@latest
    go install github.com/lc/gau/v2/cmd/gau@latest
else
    install_go
fi

# ============CHECK FOR RUST INSTALL============
if is_command_installed rustc; then
    wget https://github.com/RustScan/RustScan/releases/download/2.0.1/rustscan_2.0.1_amd64.deb -O rustscan_2.0.1_amd64.deb | sudo dpkg -i ./rustscan_2.0.1_amd64.deb
else
    printf "%s\n" "Rust is't installed. Installing rust..."
    install_rust && wget https://github.com/RustScan/RustScan/releases/download/2.0.1/rustscan_2.0.1_amd64.deb -O rustscan_2.0.1_amd64.deb | sudo dpkg -i ./rustscan_2.0.1_amd64.deb
fi

# Remove rustscan .deb file if present
[[ -f "rustscan_2.0.1_amd64.deb "]] && rm -f ./rustscan_2.0.1_amd64.deb

if is_command_installed pip3; then
    pip3 install dirsearch
elif is_command_installed pip; then
    pip install dirsearch
else
    printf "%s\n" "Error installing dirsearch, make sure python3 and pip are installed correctly."
fi
