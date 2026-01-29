#!/usr/bin/env bash
# Symlink creation with backup

# Define symlink mappings (source -> target)
# Source is relative to DOTFILES_DIR, target is absolute
declare -A SYMLINK_MAP=(
    # Home directory files
    ["zshrc"]="${HOME}/.zshrc"
    ["zsh_plugins.txt"]="${HOME}/.zsh_plugins.txt"
    ["p10k.zsh"]="${HOME}/.p10k.zsh"
    ["alias.sh"]="${HOME}/alias.sh"
    ["functions.sh"]="${HOME}/functions.sh"
    ["greeting.sh"]="${HOME}/greeting.sh"
    ["tmux.conf"]="${HOME}/.tmux.conf"
    ["gitconfig"]="${HOME}/.gitconfig"

    # Config directories
    ["nvim"]="${HOME}/.config/nvim"
    ["kitty"]="${HOME}/.config/kitty"
    ["hypr"]="${HOME}/.config/hypr"
    ["waybar"]="${HOME}/.config/waybar"
    ["rofi"]="${HOME}/.config/rofi"
    ["dunst"]="${HOME}/.config/dunst"
    ["swaync"]="${HOME}/.config/swaync"
    ["wlogout"]="${HOME}/.config/wlogout"
    ["lazygit"]="${HOME}/.config/lazygit"
    ["neofetch"]="${HOME}/.config/neofetch"
    ["matugen"]="${HOME}/.config/matugen"

    # Other directories
    ["tmux"]="${HOME}/.tmux"
    ["scripts"]="${HOME}/.local/scripts"
)

create_symlinks() {
    log_phase "Phase 8: Creating Symlinks"

    if is_phase_done "symlinks"; then
        log_info "Symlink creation already completed, skipping..."
        return 0
    fi

    # Ensure config directory exists
    mkdir -p "${HOME}/.config"
    mkdir -p "${HOME}/.local"

    # Create backup directory if we need to backup anything
    local need_backup=false
    for src in "${!SYMLINK_MAP[@]}"; do
        local tgt="${SYMLINK_MAP[$src]}"
        if [[ -e "$tgt" && ! -L "$tgt" ]]; then
            need_backup=true
            break
        fi
    done

    if $need_backup; then
        mkdir -p "$BACKUP_DIR"
        log_info "Backup directory: $BACKUP_DIR"
    fi

    # Create symlinks
    for src in "${!SYMLINK_MAP[@]}"; do
        local tgt="${SYMLINK_MAP[$src]}"
        create_symlink "$src" "$tgt"
    done

    mark_phase_done "symlinks"
}

create_symlink() {
    local src_rel="$1"
    local tgt="$2"
    local src="${DOTFILES_DIR}/${src_rel}"

    if is_item_done "symlinks" "$src_rel"; then
        log_info "  $src_rel -> $tgt (already done)"
        return 0
    fi

    # Check if source exists
    if [[ ! -e "$src" ]]; then
        log_warn "  Source not found: $src"
        return 1
    fi

    # Ensure parent directory exists
    local parent_dir
    parent_dir=$(dirname "$tgt")
    mkdir -p "$parent_dir"

    # Handle existing target
    if [[ -e "$tgt" && ! -L "$tgt" ]]; then
        # Backup existing file/directory
        local backup_path="${BACKUP_DIR}/$(basename "$tgt")"
        log_step "  Backing up existing: $tgt"
        if mv "$tgt" "$backup_path"; then
            log_info "    Backed up to: $backup_path"
        else
            log_warn "    Failed to backup: $tgt"
            mark_item_failed "symlinks" "$src_rel"
            return 1
        fi
    elif [[ -L "$tgt" ]]; then
        # Remove existing symlink
        rm -f "$tgt"
    fi

    # Create symlink
    if ln -sf "$src" "$tgt"; then
        mark_item_done "symlinks" "$src_rel"
        log_success "  $src_rel -> $tgt"
    else
        mark_item_failed "symlinks" "$src_rel"
        log_warn "  Failed to create symlink: $tgt"
    fi
}
