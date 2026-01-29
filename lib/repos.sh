#!/usr/bin/env bash
# Repository setup (COPR, RPM Fusion, Flatpak, etc.)

setup_repos() {
    log_phase "Phase 2: Repository Setup"

    if is_phase_done "repos"; then
        log_info "Repository setup already completed, skipping..."
        return 0
    fi

    setup_copr
    setup_rpm_fusion
    setup_google_chrome_repo
    setup_flatpak

    mark_phase_done "repos"
}

setup_copr() {
    log_step "Setting up COPR repositories..."

    # Hyprland COPR
    if ! sudo dnf copr list | grep -q "solopasha/hyprland"; then
        log_step "Enabling solopasha/hyprland COPR..."
        if sudo dnf copr enable -y solopasha/hyprland; then
            log_success "COPR solopasha/hyprland enabled"
        else
            log_warn "Failed to enable solopasha/hyprland COPR"
        fi
    else
        log_info "COPR solopasha/hyprland already enabled"
    fi
}

setup_rpm_fusion() {
    log_step "Setting up RPM Fusion repositories..."

    local fusion_free="https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-\$(rpm -E %fedora).noarch.rpm"
    local fusion_nonfree="https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-\$(rpm -E %fedora).noarch.rpm"

    if [[ "$DISTRO" == "almalinux" || "$DISTRO" == "rhel" ]]; then
        fusion_free="https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-\$(rpm -E %rhel).noarch.rpm"
        fusion_nonfree="https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-\$(rpm -E %rhel).noarch.rpm"
    fi

    # Check if RPM Fusion Free is installed
    if ! rpm -q rpmfusion-free-release &>/dev/null; then
        log_step "Installing RPM Fusion Free..."
        if sudo dnf install -y "$fusion_free"; then
            log_success "RPM Fusion Free installed"
        else
            log_warn "Failed to install RPM Fusion Free"
        fi
    else
        log_info "RPM Fusion Free already installed"
    fi

    # Check if RPM Fusion Nonfree is installed
    if ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
        log_step "Installing RPM Fusion Nonfree..."
        if sudo dnf install -y "$fusion_nonfree"; then
            log_success "RPM Fusion Nonfree installed"
        else
            log_warn "Failed to install RPM Fusion Nonfree"
        fi
    else
        log_info "RPM Fusion Nonfree already installed"
    fi
}

setup_google_chrome_repo() {
    log_step "Setting up Google Chrome repository..."

    local chrome_repo="/etc/yum.repos.d/google-chrome.repo"

    if [[ ! -f "$chrome_repo" ]]; then
        log_step "Adding Google Chrome repository..."
        sudo tee "$chrome_repo" > /dev/null << 'EOF'
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF
        if [[ $? -eq 0 ]]; then
            log_success "Google Chrome repository added"
        else
            log_warn "Failed to add Google Chrome repository"
        fi
    else
        log_info "Google Chrome repository already exists"
    fi
}

setup_flatpak() {
    log_step "Setting up Flatpak..."

    # Install flatpak if not present
    if ! command_exists flatpak; then
        log_step "Installing Flatpak..."
        if sudo dnf install -y flatpak; then
            log_success "Flatpak installed"
        else
            log_error "Failed to install Flatpak"
            return 1
        fi
    fi

    # Add Flathub remote
    if ! flatpak remotes | grep -q "flathub"; then
        log_step "Adding Flathub remote..."
        if flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo; then
            log_success "Flathub remote added"
        else
            log_warn "Failed to add Flathub remote"
        fi
    else
        log_info "Flathub remote already configured"
    fi
}
