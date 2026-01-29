#!/usr/bin/env bash
# Package installation functions

install_dnf_packages() {
    log_phase "Phase 3: DNF Package Installation"

    if is_phase_done "dnf"; then
        log_info "DNF package installation already completed, skipping..."
        return 0
    fi

    # Update package cache
    log_step "Updating DNF cache..."
    sudo dnf makecache -q

    local package_lists=(
        "dnf-core.txt"
        "dnf-hyprland.txt"
        "dnf-desktop.txt"
        "dnf-audio.txt"
        "dnf-theming.txt"
        "dnf-network.txt"
        "dnf-fonts.txt"
    )

    for list in "${package_lists[@]}"; do
        local list_path="${SCRIPT_DIR}/packages/${list}"
        if [[ -f "$list_path" ]]; then
            log_step "Installing packages from ${list}..."
            install_dnf_from_list "$list_path"
        else
            log_warn "Package list not found: $list_path"
        fi
    done

    # Install Google Chrome separately (from its own repo)
    install_dnf_package "google-chrome-stable"

    mark_phase_done "dnf"
}

install_dnf_from_list() {
    local list_file="$1"
    local packages
    packages=$(read_package_list "$list_file")

    for pkg in $packages; do
        install_dnf_package "$pkg"
    done
}

install_dnf_package() {
    local pkg="$1"

    if is_item_done "dnf" "$pkg"; then
        log_info "  $pkg (already installed)"
        return 0
    fi

    # Check if already installed on system
    if rpm -q "$pkg" &>/dev/null; then
        mark_item_done "dnf" "$pkg"
        log_info "  $pkg (already installed)"
        return 0
    fi

    log_step "Installing $pkg..."
    if sudo dnf install -y "$pkg" &>>"$LOG_FILE"; then
        mark_item_done "dnf" "$pkg"
        log_success "  $pkg"
    else
        mark_item_failed "dnf" "$pkg"
        log_warn "  $pkg (failed)"
    fi
}

install_flatpak_packages() {
    log_phase "Phase 4: Flatpak Package Installation"

    if is_phase_done "flatpak"; then
        log_info "Flatpak package installation already completed, skipping..."
        return 0
    fi

    local list_path="${SCRIPT_DIR}/packages/flatpak.txt"
    if [[ ! -f "$list_path" ]]; then
        log_warn "Flatpak package list not found"
        mark_phase_done "flatpak"
        return 0
    fi

    local packages
    packages=$(read_package_list "$list_path")

    for pkg in $packages; do
        install_flatpak_package "$pkg"
    done

    mark_phase_done "flatpak"
}

install_flatpak_package() {
    local pkg="$1"

    if is_item_done "flatpak" "$pkg"; then
        log_info "  $pkg (already installed)"
        return 0
    fi

    # Check if already installed
    if flatpak list --app | grep -q "$pkg"; then
        mark_item_done "flatpak" "$pkg"
        log_info "  $pkg (already installed)"
        return 0
    fi

    log_step "Installing $pkg..."
    if flatpak install -y flathub "$pkg" &>>"$LOG_FILE"; then
        mark_item_done "flatpak" "$pkg"
        log_success "  $pkg"
    else
        mark_item_failed "flatpak" "$pkg"
        log_warn "  $pkg (failed)"
    fi
}

install_pip_cargo_packages() {
    log_phase "Phase 5: Pip and Cargo Package Installation"

    if is_phase_done "pip-cargo"; then
        log_info "Pip/Cargo installation already completed, skipping..."
        return 0
    fi

    # Install pywal via pip if not available
    install_pip_packages

    # Install cargo packages
    install_cargo_packages

    mark_phase_done "pip-cargo"
}

install_pip_packages() {
    log_step "Checking Python packages..."

    # Check if pywal is available
    if ! command_exists wal; then
        log_step "Installing pywal via pip..."
        if pip install --user pywal &>>"$LOG_FILE"; then
            mark_item_done "pip" "pywal"
            log_success "  pywal"
        else
            mark_item_failed "pip" "pywal"
            log_warn "  pywal (failed)"
        fi
    else
        log_info "  pywal (already installed)"
        mark_item_done "pip" "pywal"
    fi
}

install_cargo_packages() {
    log_step "Checking Cargo packages..."

    # Ensure cargo is available
    if ! command_exists cargo; then
        log_step "Installing Rust toolchain..."
        if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y &>>"$LOG_FILE"; then
            source "$HOME/.cargo/env"
            log_success "Rust toolchain installed"
        else
            log_error "Failed to install Rust toolchain"
            return 1
        fi
    fi

    # Install matugen
    if is_item_done "cargo" "matugen"; then
        log_info "  matugen (already installed)"
        return 0
    fi

    if command_exists matugen; then
        mark_item_done "cargo" "matugen"
        log_info "  matugen (already installed)"
        return 0
    fi

    log_step "Installing matugen via cargo..."
    if cargo install matugen &>>"$LOG_FILE"; then
        mark_item_done "cargo" "matugen"
        log_success "  matugen"
    else
        mark_item_failed "cargo" "matugen"
        log_warn "  matugen (failed)"
    fi
}
