#!/bin/bash
#
# State management library
# Provides functions for tracking installation state
#

# Source common utilities (assumes common.sh is already sourced by caller)

# State directory (use SCRIPT_DIR from install.sh)
# Note: These are set in init_state() to avoid calling functions at source time
STATE_DIR=""
COMPLETED_FILE=""
FAILED_FILE=""
LOG_FILE=""

# Initialize state directory
init_state() {
    # Set state directory paths (using SCRIPT_DIR from install.sh)
    STATE_DIR="$SCRIPT_DIR/.install-state"
    COMPLETED_FILE="$STATE_DIR/completed.txt"
    FAILED_FILE="$STATE_DIR/failed.txt"
    LOG_FILE="$STATE_DIR/install.log"

    if [ ! -d "$STATE_DIR" ]; then
        mkdir -p "$STATE_DIR"
        touch "$COMPLETED_FILE"
        touch "$FAILED_FILE"
        touch "$LOG_FILE"
    fi
    log_message "INFO" "State initialized"
}

# Clear state (for fresh install)
clear_state() {
    if [ -d "$STATE_DIR" ]; then
        rm -rf "$STATE_DIR"
    fi
    init_state
    log_message "INFO" "State cleared"
}

# Mark a module as completed
# Usage: mark_completed module_id
mark_completed() {
    local module_id="$1"
    echo "$module_id" >> "$COMPLETED_FILE"
    log_message "INFO" "Module '$module_id' marked as completed"
}

# Mark a module as failed
# Usage: mark_failed module_id error_message
mark_failed() {
    local module_id="$1"
    local error_msg="${2:-Unknown error}"
    echo "$module_id" >> "$FAILED_FILE"
    log_message "ERROR" "Module '$module_id' failed: $error_msg"
}

# Check if a module is completed
# Usage: is_completed module_id
is_completed() {
    local module_id="$1"
    if [ -f "$COMPLETED_FILE" ] && grep -q "^${module_id}$" "$COMPLETED_FILE"; then
        return 0
    else
        return 1
    fi
}

# Get list of completed modules
get_completed_modules() {
    if [ -f "$COMPLETED_FILE" ]; then
        cat "$COMPLETED_FILE"
    fi
}

# Get list of failed modules
get_failed_modules() {
    if [ -f "$FAILED_FILE" ]; then
        cat "$FAILED_FILE"
    fi
}

# Check if previous installation exists
has_previous_state() {
    if [ -f "$COMPLETED_FILE" ] && [ -s "$COMPLETED_FILE" ]; then
        return 0
    else
        return 1
    fi
}

# Log a message to the install log
# Usage: log_message level message
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}
