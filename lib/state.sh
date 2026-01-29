#!/usr/bin/env bash
# State management for resumable installation

# Initialize state file if it doesn't exist
init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" << 'EOF'
{
    "phases": {},
    "packages": {
        "dnf": {},
        "flatpak": {},
        "pip": {},
        "cargo": {}
    },
    "symlinks": {},
    "plugins": {},
    "started_at": null,
    "last_updated": null
}
EOF
        update_state_timestamp "started_at"
    fi
    update_state_timestamp "last_updated"
}

# Update timestamp in state
update_state_timestamp() {
    local field="$1"
    local timestamp
    timestamp=$(date -Iseconds)
    local tmp
    tmp=$(mktemp)
    jq --arg ts "$timestamp" ".$field = \$ts" "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"
}

# Clean state for fresh install
clean_state() {
    log_info "Cleaning installation state..."
    rm -f "$STATE_FILE" "$FAILED_FILE"
    init_state
    log_success "State cleaned"
}

# Mark a phase as done
mark_phase_done() {
    local phase="$1"
    local tmp
    tmp=$(mktemp)
    jq --arg p "$phase" '.phases[$p] = "done"' "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"
    update_state_timestamp "last_updated"
    log_success "Phase completed: $phase"
}

# Mark a phase as failed
mark_phase_failed() {
    local phase="$1"
    local tmp
    tmp=$(mktemp)
    jq --arg p "$phase" '.phases[$p] = "failed"' "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"
    update_state_timestamp "last_updated"
}

# Check if phase is done
is_phase_done() {
    local phase="$1"
    local status
    status=$(jq -r --arg p "$phase" '.phases[$p] // "pending"' "$STATE_FILE")
    [[ "$status" == "done" ]]
}

# Mark an item (package, symlink, etc.) as done
mark_item_done() {
    local category="$1"  # dnf, flatpak, pip, cargo, symlinks, plugins
    local item="$2"
    local tmp
    tmp=$(mktemp)

    if [[ "$category" == "symlinks" || "$category" == "plugins" ]]; then
        jq --arg c "$category" --arg i "$item" '.[$c][$i] = "done"' "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"
    else
        jq --arg c "$category" --arg i "$item" '.packages[$c][$i] = "done"' "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"
    fi
    update_state_timestamp "last_updated"
}

# Mark an item as failed
mark_item_failed() {
    local category="$1"
    local item="$2"
    local tmp
    tmp=$(mktemp)

    if [[ "$category" == "symlinks" || "$category" == "plugins" ]]; then
        jq --arg c "$category" --arg i "$item" '.[$c][$i] = "failed"' "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"
    else
        jq --arg c "$category" --arg i "$item" '.packages[$c][$i] = "failed"' "$STATE_FILE" > "$tmp" && mv "$tmp" "$STATE_FILE"
    fi

    # Also add to failed file for retry
    echo "$category:$item" >> "$FAILED_FILE"
    update_state_timestamp "last_updated"
}

# Check if item is done
is_item_done() {
    local category="$1"
    local item="$2"
    local status

    if [[ "$category" == "symlinks" || "$category" == "plugins" ]]; then
        status=$(jq -r --arg c "$category" --arg i "$item" '.[$c][$i] // "pending"' "$STATE_FILE")
    else
        status=$(jq -r --arg c "$category" --arg i "$item" '.packages[$c][$i] // "pending"' "$STATE_FILE")
    fi
    [[ "$status" == "done" ]]
}

# Get installation status summary
get_status() {
    echo ""
    echo -e "${BOLD}Installation Status${NC}"
    echo "==================="
    echo ""

    echo -e "${CYAN}Phases:${NC}"
    jq -r '.phases | to_entries[] | "  \(.key): \(.value)"' "$STATE_FILE" 2>/dev/null || echo "  No phases recorded"
    echo ""

    echo -e "${CYAN}DNF Packages:${NC}"
    local dnf_done dnf_failed
    dnf_done=$(jq '[.packages.dnf | to_entries[] | select(.value == "done")] | length' "$STATE_FILE" 2>/dev/null || echo 0)
    dnf_failed=$(jq '[.packages.dnf | to_entries[] | select(.value == "failed")] | length' "$STATE_FILE" 2>/dev/null || echo 0)
    echo "  Done: $dnf_done, Failed: $dnf_failed"

    echo -e "${CYAN}Flatpak Packages:${NC}"
    local flatpak_done flatpak_failed
    flatpak_done=$(jq '[.packages.flatpak | to_entries[] | select(.value == "done")] | length' "$STATE_FILE" 2>/dev/null || echo 0)
    flatpak_failed=$(jq '[.packages.flatpak | to_entries[] | select(.value == "failed")] | length' "$STATE_FILE" 2>/dev/null || echo 0)
    echo "  Done: $flatpak_done, Failed: $flatpak_failed"

    echo -e "${CYAN}Symlinks:${NC}"
    local symlinks_done
    symlinks_done=$(jq '[.symlinks | to_entries[] | select(.value == "done")] | length' "$STATE_FILE" 2>/dev/null || echo 0)
    echo "  Done: $symlinks_done"

    echo -e "${CYAN}Plugins:${NC}"
    local plugins_done
    plugins_done=$(jq '[.plugins | to_entries[] | select(.value == "done")] | length' "$STATE_FILE" 2>/dev/null || echo 0)
    echo "  Done: $plugins_done"

    echo ""
    if [[ -f "$FAILED_FILE" ]]; then
        local failed_count
        failed_count=$(wc -l < "$FAILED_FILE")
        if [[ $failed_count -gt 0 ]]; then
            echo -e "${RED}Failed items: $failed_count${NC}"
            echo "  See: $FAILED_FILE"
        fi
    fi

    echo ""
    echo "State file: $STATE_FILE"
    echo "Log file: $LOG_FILE"
}

# List available phases
list_phases() {
    echo ""
    echo -e "${BOLD}Available Phases${NC}"
    echo "================"
    echo ""
    echo "  1. preflight     - Pre-flight checks (distro, sudo, internet)"
    echo "  2. repos         - Repository setup (COPR, RPM Fusion, Flatpak)"
    echo "  3. dnf           - DNF package installation"
    echo "  4. flatpak       - Flatpak package installation"
    echo "  5. pip-cargo     - Pip and Cargo package installation"
    echo "  6. fonts         - Nerd Font installation"
    echo "  7. dotfiles      - Clone/update dotfiles repository"
    echo "  8. symlinks      - Create configuration symlinks"
    echo "  9. plugins       - Bootstrap plugin managers"
    echo "  10. post-install - Post-installation tasks"
    echo ""
}
