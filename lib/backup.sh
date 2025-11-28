#!/bin/bash
#
# Backup library
# Provides functions for backing up files and directories
#

# Source common utilities (assumes common.sh is already sourced by caller)

# Global backup directory (set by create_backup_dir)
BACKUP_DIR=""

# Create a timestamped backup directory
# Returns the backup directory path
create_backup_dir() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR="$HOME/.dotfiles_backup_$timestamp"

    mkdir -p "$BACKUP_DIR"
    if [ $? -eq 0 ]; then
        print_info "Created backup directory: $BACKUP_DIR"
        echo "$BACKUP_DIR"
        return 0
    else
        print_error "Failed to create backup directory"
        return 1
    fi
}

# Backup a single file
# Usage: backup_file <source_file> [backup_dir]
backup_file() {
    local source="$1"
    local backup_dir="${2:-$BACKUP_DIR}"

    if [ -z "$backup_dir" ]; then
        print_error "Backup directory not specified"
        return 1
    fi

    if [ ! -f "$source" ]; then
        return 0  # File doesn't exist, nothing to backup
    fi

    print_info "Backing up: $source"
    cp "$source" "$backup_dir/" 2>/dev/null
    return $?
}

# Backup a directory
# Usage: backup_directory <source_dir> [backup_dir]
backup_directory() {
    local source="$1"
    local backup_dir="${2:-$BACKUP_DIR}"

    if [ -z "$backup_dir" ]; then
        print_error "Backup directory not specified"
        return 1
    fi

    if [ ! -d "$source" ]; then
        return 0  # Directory doesn't exist, nothing to backup
    fi

    local dirname=$(basename "$source")
    print_info "Backing up directory: $source"
    cp -r "$source" "$backup_dir/$dirname" 2>/dev/null
    return $?
}

# List existing backups
list_backups() {
    print_info "Existing backups:"
    ls -ld "$HOME/.dotfiles_backup_"* 2>/dev/null || print_info "No backups found"
}
