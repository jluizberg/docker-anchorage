#!/bin/bash
set -euo pipefail

# Ensure teh scritp is being executed as root
check_root() {
    # Must run as root (prefer sudo)
    if [[ "$(id -u)" -ne 0 ]]; then
        echo "ERROR: run as root (sudo)." >&2
        exit 1
    fi
}

# Load the environment variables to memory and expand to docker compose environment parameters
load_environment() {
    set -a
    source ./parms.env
    set +a

    envsubst < ./parms.env > .env
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to compare files with md5 checksum
files_are_different() {
    local file1="$1"
    local file2="$2"
    
    if [ ! -f "$file1" ] || [ ! -f "$file2" ]; then
        return 0  # Files don't exist, so they are different
    fi
    
    local md5_1 md5_2
    md5_1=$(md5sum "$file1" | cut -d' ' -f1)
    md5_2=$(md5sum "$file2" | cut -d' ' -f1)
    
    [ "$md5_1" != "$md5_2" ]
}

