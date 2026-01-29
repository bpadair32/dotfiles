#!/usr/bin/env bash
# Plugin manager bootstrapping

ANTIDOTE_DIR="${HOME}/.antidote"
TPM_DIR="${HOME}/.tmux/plugins/tpm"

bootstrap_plugins() {
    log_phase "Phase 9: Bootstrap Plugin Managers"

    if is_phase_done "plugins"; then
        log_info "Plugin bootstrapping already completed, skipping..."
        return 0
    fi

    bootstrap_antidote
    bootstrap_tpm
    bootstrap_lazyvim

    mark_phase_done "plugins"
}

bootstrap_antidote() {
    log_step "Setting up Antidote (Zsh plugin manager)..."

    if is_item_done "plugins" "antidote"; then
        log_info "  Antidote (already setup)"
        return 0
    fi

    if [[ -d "$ANTIDOTE_DIR" ]]; then
        log_step "  Updating Antidote..."
        if git -C "$ANTIDOTE_DIR" pull --quiet &>>"$LOG_FILE"; then
            mark_item_done "plugins" "antidote"
            log_success "  Antidote updated"
        else
            log_warn "  Failed to update Antidote"
        fi
    else
        log_step "  Cloning Antidote..."
        if git clone --depth=1 https://github.com/mattmc3/antidote.git "$ANTIDOTE_DIR" &>>"$LOG_FILE"; then
            mark_item_done "plugins" "antidote"
            log_success "  Antidote installed"
        else
            mark_item_failed "plugins" "antidote"
            log_warn "  Failed to install Antidote"
        fi
    fi
}

bootstrap_tpm() {
    log_step "Setting up TPM (Tmux Plugin Manager)..."

    if is_item_done "plugins" "tpm"; then
        log_info "  TPM (already setup)"
        return 0
    fi

    if [[ -d "$TPM_DIR" ]]; then
        log_step "  Updating TPM..."
        if git -C "$TPM_DIR" pull --quiet &>>"$LOG_FILE"; then
            log_success "  TPM updated"
        else
            log_warn "  Failed to update TPM"
        fi
    else
        log_step "  Cloning TPM..."
        mkdir -p "${HOME}/.tmux/plugins"
        if git clone https://github.com/tmux-plugins/tpm "$TPM_DIR" &>>"$LOG_FILE"; then
            log_success "  TPM installed"
        else
            mark_item_failed "plugins" "tpm"
            log_warn "  Failed to install TPM"
            return 1
        fi
    fi

    # Install tmux plugins
    log_step "  Installing Tmux plugins..."
    if [[ -x "${TPM_DIR}/bin/install_plugins" ]]; then
        if "${TPM_DIR}/bin/install_plugins" &>>"$LOG_FILE"; then
            mark_item_done "plugins" "tpm"
            log_success "  Tmux plugins installed"
        else
            log_warn "  Failed to install Tmux plugins"
        fi
    else
        mark_item_done "plugins" "tpm"
        log_info "  TPM install script not found, plugins will be installed on first tmux launch"
    fi
}

bootstrap_lazyvim() {
    log_step "Setting up lazy.nvim (Neovim plugin manager)..."

    if is_item_done "plugins" "lazyvim"; then
        log_info "  lazy.nvim (already setup)"
        return 0
    fi

    if ! command_exists nvim; then
        log_warn "  Neovim not installed, skipping lazy.nvim setup"
        return 1
    fi

    log_step "  Syncing Neovim plugins..."
    if nvim --headless "+Lazy! sync" +qa 2>>"$LOG_FILE"; then
        mark_item_done "plugins" "lazyvim"
        log_success "  lazy.nvim plugins synced"
    else
        mark_item_failed "plugins" "lazyvim"
        log_warn "  Failed to sync lazy.nvim plugins (may work on first nvim launch)"
    fi
}
