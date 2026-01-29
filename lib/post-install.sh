#!/usr/bin/env bash
# Post-installation hooks

post_install() {
    log_phase "Phase 10: Post-Installation"

    if is_phase_done "post-install"; then
        log_info "Post-installation already completed, skipping..."
        return 0
    fi

    set_default_shell
    enable_services
    create_monitors_template
    apply_default_theme

    mark_phase_done "post-install"
}

set_default_shell() {
    log_step "Setting Zsh as default shell..."

    local zsh_path
    zsh_path=$(which zsh)

    if [[ -z "$zsh_path" ]]; then
        log_warn "Zsh not found, cannot set as default shell"
        return 1
    fi

    # Check if zsh is in /etc/shells
    if ! grep -q "$zsh_path" /etc/shells; then
        log_step "  Adding $zsh_path to /etc/shells..."
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    # Check current shell
    if [[ "$SHELL" == "$zsh_path" ]]; then
        log_info "  Zsh is already the default shell"
        return 0
    fi

    # Change shell
    log_step "  Changing default shell to Zsh..."
    if chsh -s "$zsh_path"; then
        log_success "  Default shell set to Zsh"
        log_info "  Please log out and back in for the change to take effect"
    else
        log_warn "  Failed to set Zsh as default shell"
        log_info "  You can manually run: chsh -s $zsh_path"
    fi
}

enable_services() {
    log_step "Enabling system services..."

    local services=("NetworkManager" "bluetooth" "pipewire" "wireplumber")

    for service in "${services[@]}"; do
        if systemctl list-unit-files | grep -q "^${service}"; then
            # Check if it's a user service
            if systemctl --user list-unit-files 2>/dev/null | grep -q "^${service}"; then
                if ! systemctl --user is-enabled "$service" &>/dev/null; then
                    log_step "  Enabling user service: $service"
                    systemctl --user enable "$service" &>>"$LOG_FILE" || true
                fi
            else
                if ! systemctl is-enabled "$service" &>/dev/null; then
                    log_step "  Enabling system service: $service"
                    sudo systemctl enable "$service" &>>"$LOG_FILE" || true
                fi
            fi
        fi
    done

    log_success "  Services configured"
}

create_monitors_template() {
    log_step "Creating monitors.conf template..."

    local monitors_file="${HOME}/.config/hypr/configs/monitors.conf"

    if [[ -f "$monitors_file" ]]; then
        log_info "  monitors.conf already exists"
        return 0
    fi

    mkdir -p "$(dirname "$monitors_file")"

    cat > "$monitors_file" << 'EOF'
# Monitor Configuration
# See https://wiki.hyprland.org/Configuring/Monitors/
#
# Format: monitor = name, resolution@rate, position, scale
#
# Examples:
# monitor = eDP-1, 1920x1080@60, 0x0, 1
# monitor = HDMI-A-1, 2560x1440@144, 1920x0, 1
# monitor = , preferred, auto, 1  # Fallback for any monitor

# Default: automatically configure all monitors
monitor = , preferred, auto, 1
EOF

    log_success "  monitors.conf template created"
    log_info "  Edit ~/.config/hypr/configs/monitors.conf to configure your displays"
}

apply_default_theme() {
    log_step "Applying default theme..."

    local theme_switch="${DOTFILES_DIR}/scripts/theme-switch"

    if [[ ! -x "$theme_switch" ]]; then
        log_warn "  theme-switch script not found or not executable"
        return 1
    fi

    # Check if a default theme exists
    local default_theme="catppuccin-mocha"  # Reasonable default
    local theme_dir="${DOTFILES_DIR}/themes/${default_theme}"

    if [[ ! -d "$theme_dir" ]]; then
        # Try to find any available theme
        local available_theme
        available_theme=$(ls -1 "${DOTFILES_DIR}/themes" 2>/dev/null | grep -v "^_" | head -1)
        if [[ -n "$available_theme" ]]; then
            default_theme="$available_theme"
        else
            log_warn "  No themes found in ${DOTFILES_DIR}/themes"
            return 1
        fi
    fi

    log_step "  Applying theme: $default_theme"
    if "$theme_switch" "$default_theme" &>>"$LOG_FILE"; then
        log_success "  Theme applied: $default_theme"
    else
        log_warn "  Failed to apply theme (may need Hyprland running)"
    fi
}

# Retry failed items
retry_failed() {
    if [[ ! -f "$FAILED_FILE" ]]; then
        return 0
    fi

    local failed_count
    failed_count=$(wc -l < "$FAILED_FILE")

    if [[ $failed_count -eq 0 ]]; then
        return 0
    fi

    log_phase "Retrying Failed Items"
    log_info "Found $failed_count failed items to retry"

    local retry_file="${FAILED_FILE}.retry"
    mv "$FAILED_FILE" "$retry_file"

    while IFS=: read -r category item; do
        case "$category" in
            dnf)
                install_dnf_package "$item"
                ;;
            flatpak)
                install_flatpak_package "$item"
                ;;
            pip)
                log_step "Retrying pip install: $item"
                pip install --user "$item" &>>"$LOG_FILE" && mark_item_done "pip" "$item"
                ;;
            cargo)
                log_step "Retrying cargo install: $item"
                cargo install "$item" &>>"$LOG_FILE" && mark_item_done "cargo" "$item"
                ;;
            fonts)
                install_nerd_font "$item"
                ;;
            *)
                log_warn "Unknown category: $category"
                ;;
        esac
    done < "$retry_file"

    rm -f "$retry_file"

    # Report remaining failures
    if [[ -f "$FAILED_FILE" ]]; then
        failed_count=$(wc -l < "$FAILED_FILE")
        if [[ $failed_count -gt 0 ]]; then
            log_warn "$failed_count items still failed after retry"
            log_info "See: $FAILED_FILE"
        fi
    fi
}

# Print final summary
print_summary() {
    echo ""
    echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${GREEN}  Installation Complete!${NC}"
    echo -e "${BOLD}${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Log out and log back in (for shell change to take effect)"
    echo "  2. Edit ~/.config/hypr/configs/monitors.conf for your display setup"
    echo "  3. Start Hyprland from your display manager or TTY"
    echo ""
    echo "Useful commands:"
    echo "  theme-switch --list       List available themes"
    echo "  theme-switch <name>       Apply a theme"
    echo "  nvim                      Open Neovim (plugins auto-install)"
    echo ""
    echo "Log file: $LOG_FILE"
    echo ""
}
