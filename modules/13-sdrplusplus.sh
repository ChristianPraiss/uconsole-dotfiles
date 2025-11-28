#!/bin/bash
#
# Module: HackerGadgets AIO Board
# Description: Installs HackerGadgets AIO board package with SDR++, drivers, and tools
# Dependencies: sway-core
#
# This installs the official HackerGadgets package which includes:
# - SDR++ (brown variant)
# - RTL-SDR drivers
# - tar1090 (ADS-B flight tracking)
# - PyGPSClient (GPS diagnostics)
# - Meshtastic-MUI (mesh networking)
# - readsb service (aviation data decoding)
#
# Libraries are sourced by install.sh

# Module metadata
MODULE_ID="sdrplusplus"
MODULE_NAME="HackerGadgets AIO Board"
MODULE_DESCRIPTION="SDR++, RTL-SDR, LoRa/Meshtastic, GPS, and tools"
MODULE_DEPENDENCIES=("sway-core")

# Main installation function
install_module() {
    print_info "Installing ${MODULE_NAME}..."

    # Install the HackerGadgets AIO board package
    print_info "Installing hackergadgets-uconsole-aio-board package..."
    print_info "This includes SDR++, RTL-SDR drivers, tar1090, PyGPSClient, and Meshtastic-MUI"

    if ! apt_install hackergadgets-uconsole-aio-board; then
        print_error "Failed to install HackerGadgets AIO board package"
        return 1
    fi

    print_success "HackerGadgets AIO board package installed successfully"
    print_info "Applications installed:"
    print_info "  - SDR++ (brown variant) - Software-defined radio"
    print_info "  - tar1090 - ADS-B flight tracking interface"
    print_info "  - PyGPSClient - GPS diagnostic tool"
    print_info "  - Meshtastic-MUI - Mesh networking application"
    print_info "  - readsb - Aviation data decoding service"
    print_warning "A reboot is required for all services to function properly"

    return 0
}

# Check if module is already installed
check_installed() {
    if apt_check_installed "hackergadgets-uconsole-aio-board"; then
        return 0
    else
        return 1
    fi
}

# Estimate installation time (seconds)
estimate_time() {
    echo "180"  # ~3 minutes for package installation
}

# Prevent direct execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    print_error "Modules cannot be run directly. Use install.sh"
    exit 1
fi
