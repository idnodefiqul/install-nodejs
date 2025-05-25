#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' 

print_header() {
    clear
    echo -e "${CYAN}========================================${NC}"
    echo -e "${GREEN}    Node.js Auto Installer (v1.0.0)    ${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo -e "${YELLOW}Powered by Node Fiqul - Setup Node.js${NC}"
    echo -e "${BLUE}Starting installation at $(date)${NC}\n"
}

error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    echo -e "${CYAN}========================================${NC}"
    exit 1
}

detect_os() {
    echo -e "${BLUE}Detecting operating system...${NC}"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    elif [ -n "$(command -v termux-info)" ]; then
        OS="termux"
    else
        error_exit "Sistem operasi tidak didukung atau tidak terdeteksi."
    fi
    echo -e "${GREEN}Detected OS: $OS${NC}"
}

install_node_ubuntu_debian() {
    VERSION=$1
    echo -e "${BLUE}Installing Node.js v$VERSION on $OS...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_$VERSION.x | sudo -E bash - || error_exit "Gagal menambahkan repositori NodeSource."
    sudo apt-get install -y nodejs || error_exit "Gagal menginstal Node.js."
}

install_node_centos() {
    VERSION=$1
    echo -e "${BLUE}Installing Node.js v$VERSION on $OS...${NC}"
    curl -fsSL https://rpm.nodesource.com/setup_$VERSION.x | sudo bash - || error_exit "Gagal menambahkan repositori NodeSource."
    sudo yum install -y nodejs || error_exit "Gagal menginstal Node.js."
}

install_node_termux() {
    VERSION=$1
    echo -e "${BLUE}Installing Node.js v$VERSION on Termux...${NC}"
    pkg install nodejs-$VERSION || error_exit "Gagal menginstal Node.js."
}

verify_installation() {
    echo -e "${BLUE}Verifying installation...${NC}"
    NODE_VERSION=$(node -v 2>/dev/null)
    NPM_VERSION=$(npm -v 2>/dev/null)
    if [ -n "$NODE_VERSION" ]; then
        echo -e "${GREEN}Node.js $NODE_VERSION installed successfully.${NC}"
        echo -e "${GREEN}npm $NPM_VERSION installed successfully.${NC}"
    else
        error_exit "Instalasi gagal, Node.js tidak ditemukan."
    fi
}

NODE_VERSIONS=("18" "20" "22")

print_header

SELECTED_VERSION=$1
if [ -z "$SELECTED_VERSION" ]; then
    error_exit "Versi Node.js tidak ditentukan. Contoh: bash <(curl -s URL) 22"
fi

if [[ ! " ${NODE_VERSIONS[*]} " =~ " ${SELECTED_VERSION} " ]]; then
    error_exit "Versi $SELECTED_VERSION tidak didukung. Pilih dari: ${NODE_VERSIONS[*]}"
fi

echo -e "${YELLOW}Selected Node.js version: $SELECTED_VERSION${NC}\n"

detect_os

if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    echo -e "${BLUE}Updating system packages...${NC}"
    sudo apt update && sudo apt upgrade -y || error_exit "Gagal update sistem."
elif [ "$OS" = "centos" ]; then
    echo -e "${BLUE}Updating system packages...${NC}"
    sudo yum update -y || error_exit "Gagal update sistem."
elif [ "$OS" = "termux" ]; then
    echo -e "${BLUE}Updating system packages...${NC}"
    pkg update && pkg upgrade -y || error_exit "Gagal update sistem."
fi

case $OS in
    "ubuntu"|"debian")
        install_node_ubuntu_debian $SELECTED_VERSION
        ;;
    "centos")
        install_node_centos $SELECTED_VERSION
        ;;
    "termux")
        install_node_termux $SELECTED_VERSION
        ;;
    *)
        error_exit "Sistem operasi $OS tidak didukung."
        ;;
esac

verify_installation

echo -e "\n${CYAN}========================================${NC}"
echo -e "${GREEN}Installation completed successfully!${NC}"
echo -e "${CYAN}========================================${NC}"
