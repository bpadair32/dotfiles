#!/usr/bin/env bash
#
# Dotfiles Installation Script
# Supports Fedora and AlmaLinux/RHEL
#
# Usage: ./install.sh [OPTIONS]
#
set -euo pipefail

# Script directory (where install.sh lives)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"

# Configuration
GIT_REPO="git@gitlab.adair.cloud:bpadair/dotfiles.git"
DOTFILES_TARGET="${HOME}/repos/dotfiles"

# Source library files
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/state.sh"
source "${SCRIPT_DIR}/lib/repos.sh"
source "${SCRIPT_DIR}/lib/packages.sh"
source "${SCRIPT_DIR}/lib/fonts.sh"
source "${SCRIPT_DIR}/lib/symlinks.sh"
source "${SCRIPT_DIR}/lib/plugins.sh"
source "${SCRIPT_DIR}/lib/post-install.sh"

# Export for child scripts
export SCRIPT_DIR DOTFILES_DIR GIT_REPO

# CLI options
OPT_CLEAN=false
OPT_PHASE=""
OPT_STATUS=false
OPT_LIST=false
OPT_UPDATE=false
OPT_DRY_RUN=false
OPT_SKIP_PLUGINS=false

usage() {
    cat << EOF
Dotfiles Installation Script

Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help          Show this help message
  -c, --clean         Start fresh (clear state)
  -p, --phase PHASE   Run only specified phase
  -l, --list          List available phases
  -s, --status        Show installation status
  -u, --update        Pull latest dotfiles and re-run changed phases
  --dry-run           Show what would be done
  --skip-plugins      Skip plugin manager bootstrapping

Phases:
  preflight, repos, dnf, flatpak, pip-cargo, fonts, dotfiles, symlinks, plugins, post-install

Examples:
  $(basename "$0")                  # Full installation
  $(basename "$0") --clean          # Fresh install (reset state)
  $(basename "$0") -p symlinks      # Only run symlinks phase
  $(basename "$0") --status         # Show current status
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -c|--clean)
                OPT_CLEAN=true
                shift
                ;;
            -p|--phase)
                OPT_PHASE="$2"
                shift 2
                ;;
            -l|--list)
                OPT_LIST=true
                shift
                ;;
            -s|--status)
                OPT_STATUS=true
                shift
                ;;
            -u|--update)
                OPT_UPDATE=true
                shift
                ;;
            --dry-run)
                OPT_DRY_RUN=true
                shift
                ;;
            --skip-plugins)
                OPT_SKIP_PLUGINS=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

run_phase() {
    local phase="$1"
    case "$phase" in
        preflight)
            run_preflight
            ;;
        repos)
            setup_repos
            ;;
        dnf)
            install_dnf_packages
            ;;
        flatpak)
            install_flatpak_packages
            ;;
        pip-cargo)
            install_pip_cargo_packages
            ;;
        fonts)
            install_fonts
            ;;
        dotfiles)
            clone_or_update_dotfiles
            ;;
        symlinks)
            create_symlinks
            ;;
        plugins)
            if ! $OPT_SKIP_PLUGINS; then
                bootstrap_plugins
            else
                log_info "Skipping plugin bootstrapping (--skip-plugins)"
            fi
            ;;
        post-install)
            post_install
            ;;
        *)
            log_error "Unknown phase: $phase"
            list_phases
            exit 1
            ;;
    esac
}

run_preflight() {
    log_phase "Phase 1: Pre-flight Checks"

    if is_phase_done "preflight"; then
        log_info "Pre-flight checks already completed, skipping..."
        detect_distro  # Still need this for other phases
        return 0
    fi

    detect_distro
    check_sudo
    check_internet

    mark_phase_done "preflight"
}

clone_or_update_dotfiles() {
    log_phase "Phase 7: Clone/Update Dotfiles"

    if is_phase_done "dotfiles"; then
        log_info "Dotfiles already cloned, skipping..."
        return 0
    fi

    # If we're running from the dotfiles directory, it's already cloned
    if [[ "$SCRIPT_DIR" == "$DOTFILES_TARGET" ]]; then
        log_info "Already running from dotfiles directory"
        if $OPT_UPDATE; then
            log_step "Pulling latest changes..."
            if git -C "$DOTFILES_DIR" pull --quiet; then
                log_success "Dotfiles updated"
            else
                log_warn "Failed to pull latest changes"
            fi
        fi
        mark_phase_done "dotfiles"
        return 0
    fi

    # Check if dotfiles exist at target
    if [[ -d "$DOTFILES_TARGET" ]]; then
        log_info "Dotfiles already exist at $DOTFILES_TARGET"
        DOTFILES_DIR="$DOTFILES_TARGET"
        export DOTFILES_DIR
        if $OPT_UPDATE; then
            log_step "Pulling latest changes..."
            git -C "$DOTFILES_DIR" pull --quiet || log_warn "Failed to pull"
        fi
        mark_phase_done "dotfiles"
        return 0
    fi

    # Clone dotfiles
    log_step "Cloning dotfiles to $DOTFILES_TARGET..."
    mkdir -p "$(dirname "$DOTFILES_TARGET")"
    if git clone "$GIT_REPO" "$DOTFILES_TARGET" &>>"$LOG_FILE"; then
        DOTFILES_DIR="$DOTFILES_TARGET"
        export DOTFILES_DIR
        log_success "Dotfiles cloned to $DOTFILES_TARGET"
        mark_phase_done "dotfiles"
    else
        log_error "Failed to clone dotfiles"
        mark_phase_failed "dotfiles"
        return 1
    fi
}

run_all_phases() {
    local phases=(
        "preflight"
        "repos"
        "dnf"
        "flatpak"
        "pip-cargo"
        "fonts"
        "dotfiles"
        "symlinks"
        "plugins"
        "post-install"
    )

    for phase in "${phases[@]}"; do
        run_phase "$phase"
    done

    # Retry any failed items
    retry_failed

    # Print summary
    print_summary
}

main() {
    parse_args "$@"

    # Handle special modes
    if $OPT_LIST; then
        list_phases
        exit 0
    fi

    if $OPT_STATUS; then
        init_state
        get_status
        exit 0
    fi

    # Banner
    echo ""
    echo -e "${BOLD}${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║           Dotfiles Installation Script                        ║${NC}"
    echo -e "${BOLD}${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Initialize or clean state
    if $OPT_CLEAN; then
        clean_state
    fi
    init_state

    # Dry run mode
    if $OPT_DRY_RUN; then
        log_info "DRY RUN MODE - No changes will be made"
        echo ""
        echo "Would run the following phases:"
        if [[ -n "$OPT_PHASE" ]]; then
            echo "  - $OPT_PHASE"
        else
            echo "  - preflight"
            echo "  - repos"
            echo "  - dnf"
            echo "  - flatpak"
            echo "  - pip-cargo"
            echo "  - fonts"
            echo "  - dotfiles"
            echo "  - symlinks"
            if ! $OPT_SKIP_PLUGINS; then
                echo "  - plugins"
            fi
            echo "  - post-install"
        fi
        exit 0
    fi

    # Run specific phase or all phases
    if [[ -n "$OPT_PHASE" ]]; then
        # For single phase, ensure preflight is done first
        if [[ "$OPT_PHASE" != "preflight" ]] && ! is_phase_done "preflight"; then
            run_phase "preflight"
        fi
        run_phase "$OPT_PHASE"
    else
        run_all_phases
    fi
}

main "$@"
