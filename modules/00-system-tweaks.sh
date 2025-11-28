#!/bin/bash
#
# Module: System Tweaks
# Description: Quiets boot/console output and disables unnecessary services
# Dependencies: none
#
# Libraries are sourced by install.sh

# Module metadata
MODULE_ID="system-tweaks"
MODULE_NAME="System Tweaks"
MODULE_DESCRIPTION="Quiet console, disable cloud-init, boot optimization"
MODULE_DEPENDENCIES=()

# Main installation function
install_module() {
    print_info "Installing ${MODULE_NAME}..."

    # 1. Disable cloud-init (not needed on bare-metal uConsole)
    print_info "Disabling cloud-init..."
    if [ ! -f /etc/cloud/cloud-init.disabled ]; then
        sudo mkdir -p /etc/cloud
        if sudo touch /etc/cloud/cloud-init.disabled; then
            print_success "cloud-init disabled"
        else
            print_warning "Failed to disable cloud-init"
        fi
    else
        print_info "cloud-init already disabled"
    fi

    # 2. Configure kernel console log level to reduce TTY noise
    print_info "Configuring quiet console..."
    local sysctl_file="/etc/sysctl.d/99-quiet-console.conf"
    if [ ! -f "$sysctl_file" ]; then
        cat << 'EOF' | sudo tee "$sysctl_file" > /dev/null
# Reduce kernel console log level to suppress informational messages
# Only errors (level 3) will be printed to console
# This prevents WiFi/network messages from cluttering the login TTY
kernel.printk = 3 3 3 3
EOF
        if [ $? -eq 0 ]; then
            sudo sysctl -p "$sysctl_file" 2>/dev/null
            print_success "Quiet console configured"
        else
            print_warning "Failed to create sysctl config"
        fi
    else
        print_info "Quiet console already configured"
    fi

    # 3. Add quiet boot parameters to kernel cmdline (Raspberry Pi)
    print_info "Configuring quiet boot..."
    local cmdline_file=""

    # Check for Raspberry Pi cmdline.txt location
    if [ -f /boot/firmware/cmdline.txt ]; then
        cmdline_file="/boot/firmware/cmdline.txt"
    elif [ -f /boot/cmdline.txt ]; then
        cmdline_file="/boot/cmdline.txt"
    fi

    if [ -n "$cmdline_file" ]; then
        local current_cmdline
        current_cmdline=$(cat "$cmdline_file")

        local needs_update=false
        local new_cmdline="$current_cmdline"

        # Add 'quiet' if not present
        if ! echo "$current_cmdline" | grep -q '\bquiet\b'; then
            new_cmdline="$new_cmdline quiet"
            needs_update=true
        fi

        # Add 'loglevel=3' if not present
        if ! echo "$current_cmdline" | grep -q '\bloglevel='; then
            new_cmdline="$new_cmdline loglevel=3"
            needs_update=true
        fi

        if [ "$needs_update" = true ]; then
            # Backup original
            sudo cp "$cmdline_file" "${cmdline_file}.backup"

            # Write new cmdline (must be single line)
            echo "$new_cmdline" | sudo tee "$cmdline_file" > /dev/null
            if [ $? -eq 0 ]; then
                print_success "Kernel cmdline updated with quiet boot parameters"
                print_info "Backup saved to ${cmdline_file}.backup"
            else
                print_warning "Failed to update kernel cmdline"
            fi
        else
            print_info "Kernel cmdline already has quiet boot parameters"
        fi
    else
        print_warning "Could not find kernel cmdline.txt - skipping boot parameter configuration"
    fi

    print_success "System tweaks applied successfully"
    return 0
}

# Check if module is already installed
check_installed() {
    # Check if cloud-init is disabled and sysctl config exists
    if [ -f /etc/cloud/cloud-init.disabled ] && [ -f /etc/sysctl.d/99-quiet-console.conf ]; then
        return 0
    else
        return 1
    fi
}

# Estimate installation time (seconds)
estimate_time() {
    echo "10"  # ~10 seconds
}

# Prevent direct execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    print_error "Modules cannot be run directly. Use install.sh"
    exit 1
fi
