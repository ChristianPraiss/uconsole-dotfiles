#!/bin/bash

set -e

#
# uConsole Dotfiles Installer - Modular TUI Version
# Interactive installation system with whiptail
#

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source libraries
source "$SCRIPT_DIR/lib/common.sh"
source "$SCRIPT_DIR/lib/package-manager.sh"
source "$SCRIPT_DIR/lib/backup.sh"
source "$SCRIPT_DIR/lib/state.sh"

# Check prerequisites
check_prerequisites() {
    # Check if running on Debian
    if ! command -v apt &> /dev/null; then
        print_error "This script requires Debian/Ubuntu with apt package manager"
        exit 1
    fi

    # Check if whiptail is available
    if ! command -v whiptail &> /dev/null; then
        print_error "whiptail is required but not installed. Installing..."
        sudo apt update && sudo apt install -y whiptail
    fi
}

# Show welcome screen
show_welcome() {
    whiptail --title "uConsole Dotfiles Installer" \
        --msgbox "Welcome to the uConsole Dotfiles Installation System\n\n\
This installer will help you set up your uConsole with Sway and custom dotfiles.\n\n\
You will be able to select which components to install.\n\n\
Press OK to continue." 15 70
}

# Show module selection menu
select_modules() {
    local selected=$(whiptail --title "Select Components" \
        --checklist "Use SPACE to select/deselect, ARROW keys to navigate, ENTER to confirm:" \
        20 78 9 \
        "sway-core" "Sway/Wayland System - Window manager & core tools" ON \
        "audio" "Audio System - PipeWire audio stack" ON \
        "terminal-shell" "Terminal & Shell - Kitty, Zsh, Starship" ON \
        "applications" "Applications - Wofi, Qutebrowser, Neovim, etc." ON \
        "screenshots" "Screenshot Tools - Grim, Slurp, Grimshot" ON \
        "fonts" "Fonts - Nerd Fonts, Departure Mono" ON \
        "gtk-theme" "GTK Theme - Catppuccin Mocha" ON \
        "dotfiles" "Dotfiles Deployment - Install config files" ON \
        "services" "System Services - NetworkManager, Bluetooth" ON \
        3>&1 1>&2 2>&3)

    # Remove quotes from whiptail output
    echo "$selected" | tr -d '"'
}

# Resolve dependencies and sort modules in execution order
# Fixed execution order: 01 -> 02 -> 03 -> 04 -> 05 -> 06 -> 07 -> 08 -> 09
resolve_dependencies() {
    local selected="$1"
    local ordered=""

    # Define all modules in dependency order
    local all_modules=("sway-core" "audio" "terminal-shell" "applications" "screenshots" "fonts" "gtk-theme" "dotfiles" "services")

    # Filter to include only selected modules in correct order
    for module in "${all_modules[@]}"; do
        if echo "$selected" | grep -q "$module"; then
            ordered="$ordered $module"
        fi
    done

    echo "$ordered"
}

# Calculate total estimated time
calculate_total_time() {
    local modules="$1"
    local total=0

    for module_id in $modules; do
        # Source module to get estimate_time function
        source "$SCRIPT_DIR/modules/"*"-${module_id}.sh"
        local time=$(estimate_time)
        total=$((total + time))
    done

    echo $total
}

# Show installation confirmation
confirm_installation() {
    local modules="$1"
    local total_time=$(calculate_total_time "$modules")
    local minutes=$((total_time / 60))
    local seconds=$((total_time % 60))

    local module_list=""
    for module_id in $modules; do
        # Source module to get metadata
        source "$SCRIPT_DIR/modules/"*"-${module_id}.sh"
        module_list="${module_list}✓ $MODULE_NAME\n"
    done

    whiptail --title "Confirm Installation" \
        --yesno "The following components will be installed:\n\n${module_list}\nEstimated total time: ${minutes}m ${seconds}s\n\nContinue with installation?" 18 70
}

# Execute module installation
execute_module() {
    local module_id="$1"
    local module_file=$(ls "$SCRIPT_DIR/modules/"*"-${module_id}.sh" 2>/dev/null | head -1)

    if [ -z "$module_file" ]; then
        print_error "Module file not found for: $module_id"
        return 1
    fi

    # Source the module
    source "$module_file"

    # Check if already completed
    if is_completed "$module_id"; then
        print_info "Module '$MODULE_NAME' already completed, skipping..."
        return 0
    fi

    # Execute installation
    log_message "INFO" "Starting module: $MODULE_NAME"
    if install_module; then
        mark_completed "$module_id"
        log_message "INFO" "Module '$MODULE_NAME' completed successfully"
        return 0
    else
        mark_failed "$module_id" "Installation failed"
        log_message "ERROR" "Module '$MODULE_NAME' failed"
        return 1
    fi
}

# Install selected modules
install_modules() {
    local modules="$1"
    local total=$(echo "$modules" | wc -w)
    local current=0
    local failed_modules=""

    for module_id in $modules; do
        current=$((current + 1))
        local percent=$((current * 100 / total))

        # Source module for metadata
        source "$SCRIPT_DIR/modules/"*"-${module_id}.sh"

        # Execute module (output goes to terminal, not gauge)
        if ! execute_module "$module_id"; then
            failed_modules="$failed_modules $module_id"

            # Ask user if they want to continue
            if ! whiptail --title "Module Failed" \
                --yesno "Module '$MODULE_NAME' failed to install.\n\nWould you like to continue with remaining modules?" 10 60; then
                print_error "Installation aborted by user"
                return 1
            fi
        fi
    done

    # Return failure if any modules failed
    if [ -n "$failed_modules" ]; then
        return 1
    else
        return 0
    fi
}

# Show final summary
show_summary() {
    local success=$1
    local completed=$(get_completed_modules | wc -l)
    local failed=$(get_failed_modules | wc -l)

    local message="Installation Summary:\n\n"
    message="${message}✓ Successfully installed: $completed modules\n"

    if [ $failed -gt 0 ]; then
        message="${message}✗ Failed: $failed modules\n"
    fi

    message="${message}\nLog file: .install-state/install.log\n\n"

    if [ $success -eq 0 ]; then
        message="${message}Next steps:\n"
        message="${message}1. Log out and log back in\n"
        message="${message}2. Start Sway by running: sway\n\n"
        message="${message}Key bindings:\n"
        message="${message}  Alt+Return  - Terminal\n"
        message="${message}  Alt+d       - App launcher\n"
        message="${message}  Alt+Shift+e - Power menu\n"
    else
        message="${message}Some modules failed. Check the log for details."
    fi

    whiptail --title "Installation Complete" --msgbox "$message" 22 70
}

# Check for previous installation state
check_resume() {
    if has_previous_state; then
        local completed=$(get_completed_modules | tr '\n' ', ' | sed 's/,$//')
        local failed=$(get_failed_modules | tr '\n' ', ' | sed 's/,$//')

        local msg="A previous installation was detected.\n\n"
        if [ -n "$completed" ]; then
            msg="${msg}Completed: $completed\n\n"
        fi
        if [ -n "$failed" ]; then
            msg="${msg}Failed: $failed\n\n"
        fi
        msg="${msg}Would you like to start fresh (this will clear previous state)?"

        if whiptail --title "Previous Installation Detected" --yesno "$msg" 15 70; then
            clear_state
        fi
    fi
    # Always return 0 to avoid exiting with set -e
    return 0
}

# Main installation flow
main() {
    echo "=========================================="
    echo "uConsole Dotfiles Installation Script"
    echo "=========================================="
    echo ""

    # Check prerequisites
    check_prerequisites

    # Initialize state
    init_state

    # Check for resume
    check_resume

    # Show welcome
    show_welcome

    # Module selection
    selected_modules=$(select_modules)

    if [ -z "$selected_modules" ]; then
        print_info "No modules selected. Exiting."
        exit 0
    fi

    # Resolve dependencies and order
    ordered_modules=$(resolve_dependencies "$selected_modules")

    # Confirm installation
    if ! confirm_installation "$ordered_modules"; then
        print_info "Installation cancelled by user"
        exit 0
    fi

    # Install modules
    print_info "Starting installation..."
    if install_modules "$ordered_modules"; then
        show_summary 0
    else
        show_summary 1
    fi

    echo ""
    print_success "Installation process completed"
}

# Run main
main
