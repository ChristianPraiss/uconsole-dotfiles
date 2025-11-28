#!/bin/bash
#
# Common utilities library
# Provides shared functions for all modules
#

# Color definitions for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored info messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Function to print colored warning messages
print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to print colored error messages
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to print colored success messages
print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Get the absolute path to the script directory
get_script_dir() {
    echo "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
}

# Check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Please do not run this script as root"
        return 1
    fi
    return 0
}

# Check if a command exists
check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}
