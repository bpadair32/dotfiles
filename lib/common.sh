#!/usr/bin/env bash
# Common utilities, logging, and error handling

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Paths
STATE_DIR="${HOME}/.local/share/dotfiles-install"
STATE_FILE="${STATE_DIR}/state.json"
LOG_FILE="${STATE_DIR}/install.log"
FAILED_FILE="${STATE_DIR}/failed.txt"
BACKUP_DIR="${HOME}/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# Initialize log file
touch "$LOG_FILE"

# Logging functions
log() {
    local level="$1"
    shift
    local msg="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $msg" >> "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
    log "INFO" "$*"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $*"
    log "SUCCESS" "$*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
    log "WARN" "$*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
    log "ERROR" "$*"
}

log_phase() {
    echo ""
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}  $*${NC}"
    echo -e "${BOLD}${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    log "PHASE" "$*"
}

log_step() {
    echo -e "${CYAN}  →${NC} $*"
    log "STEP" "$*"
}

# Error handling
die() {
    log_error "$*"
    exit 1
}

# Check if running on supported distro
detect_distro() {
    if [[ -f /etc/fedora-release ]]; then
        DISTRO="fedora"
        log_info "Detected Fedora"
    elif [[ -f /etc/almalinux-release ]]; then
        DISTRO="almalinux"
        log_info "Detected AlmaLinux"
    elif [[ -f /etc/redhat-release ]]; then
        DISTRO="rhel"
        log_info "Detected RHEL-compatible"
    else
        die "Unsupported distribution. This script supports Fedora and AlmaLinux/RHEL."
    fi
    export DISTRO
}

# Check prerequisites
check_sudo() {
    if ! sudo -v; then
        die "Sudo access required. Please run with a user that has sudo privileges."
    fi
    # Keep sudo alive
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

check_internet() {
    log_step "Checking internet connectivity..."
    if ! ping -c 1 -W 5 google.com &>/dev/null && ! ping -c 1 -W 5 1.1.1.1 &>/dev/null; then
        die "No internet connection. Please check your network."
    fi
    log_success "Internet connectivity OK"
}

# Command existence check
command_exists() {
    command -v "$1" &>/dev/null
}

# Read package list from file (ignoring comments and blank lines)
read_package_list() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        log_warn "Package list not found: $file"
        return 1
    fi
    grep -v '^#' "$file" | grep -v '^[[:space:]]*$'
}

# Ask user yes/no question
confirm() {
    local prompt="${1:-Continue?}"
    local default="${2:-y}"

    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n] "
    else
        prompt="$prompt [y/N] "
    fi

    read -r -p "$prompt" response
    response=${response:-$default}
    [[ "$response" =~ ^[Yy]$ ]]
}
