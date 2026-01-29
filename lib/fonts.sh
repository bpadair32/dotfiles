#!/usr/bin/env bash
# Nerd Font installation from GitHub releases

FONTS_DIR="${HOME}/.local/share/fonts"
NERD_FONTS_VERSION="v3.3.0"
NERD_FONTS_BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}"

install_fonts() {
    log_phase "Phase 6: Font Installation"

    if is_phase_done "fonts"; then
        log_info "Font installation already completed, skipping..."
        return 0
    fi

    # Create fonts directory
    mkdir -p "$FONTS_DIR"

    # Install Nerd Fonts
    install_nerd_font "JetBrainsMono"
    install_nerd_font "FiraCode"

    # Refresh font cache
    log_step "Refreshing font cache..."
    if fc-cache -fv &>>"$LOG_FILE"; then
        log_success "Font cache refreshed"
    else
        log_warn "Font cache refresh may have failed"
    fi

    mark_phase_done "fonts"
}

install_nerd_font() {
    local font_name="$1"
    local font_dir="${FONTS_DIR}/${font_name}"
    local zip_file="/tmp/${font_name}.zip"
    local download_url="${NERD_FONTS_BASE_URL}/${font_name}.zip"

    if is_item_done "fonts" "$font_name"; then
        log_info "  ${font_name} Nerd Font (already installed)"
        return 0
    fi

    # Check if font is already installed
    if fc-list | grep -qi "${font_name}.*Nerd"; then
        mark_item_done "fonts" "$font_name"
        log_info "  ${font_name} Nerd Font (already installed)"
        return 0
    fi

    log_step "Installing ${font_name} Nerd Font..."

    # Download font
    log_step "  Downloading ${font_name}.zip..."
    if ! curl -fsSL -o "$zip_file" "$download_url"; then
        log_warn "  Failed to download ${font_name} Nerd Font"
        mark_item_failed "fonts" "$font_name"
        return 1
    fi

    # Create font directory
    mkdir -p "$font_dir"

    # Extract font
    log_step "  Extracting ${font_name}..."
    if unzip -q -o "$zip_file" -d "$font_dir"; then
        # Remove Windows-specific fonts and license files to save space
        rm -f "${font_dir}"/*Windows* "${font_dir}"/*.txt "${font_dir}"/*.md 2>/dev/null
        mark_item_done "fonts" "$font_name"
        log_success "  ${font_name} Nerd Font installed"
    else
        log_warn "  Failed to extract ${font_name} Nerd Font"
        mark_item_failed "fonts" "$font_name"
    fi

    # Cleanup
    rm -f "$zip_file"
}
