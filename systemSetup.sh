#!/usr/bin/env bash

# System Setup Script
# This script installs all required packages and configures the system with dotfiles

set -e  # Exit on error

# ANSI color codes for prettier output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print colored section headers
print_section() {
    echo -e "\n${BOLD}${BLUE}==>${NC} ${BOLD}$1${NC}"
}

# Function to print success messages
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Function to print warning messages
print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

# Function to print error messages
print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script as root or with sudo"
    exit 1
fi

# Get the actual username (even when running with sudo)
if [ -n "$SUDO_USER" ]; then
    USER_NAME="$SUDO_USER"
    USER_HOME="/home/$SUDO_USER"
else
    USER_NAME="$USER"
    USER_HOME="/home/$USER"
fi

print_section "Checking and adding necessary repositories"

# Create a temporary file with just the package names (removing versions)
TEMP_PKG_FILE=$(mktemp)
cat installedDnf.txt | sed 's/-[0-9].*$//' > "$TEMP_PKG_FILE"

# Check DNF version to determine the correct commands
DNF_VERSION=$(dnf --version | head -n1 | cut -d' ' -f3 | cut -d'.' -f1)
print_warning "Detected DNF version: $DNF_VERSION"

# Function to add a repository - handles both DNF 4 and DNF 5
add_repo() {
    local repo_url="$1"
    local repo_name="${2:-$1}"
    
    if [ "$DNF_VERSION" -ge "5" ]; then
        # DNF 5 syntax
        print_warning "Using DNF 5 syntax for adding repository: $repo_name"
        dnf config-manager addrepo --from-repofile="$repo_url"
    else
        # DNF 4 syntax
        print_warning "Using DNF 4 syntax for adding repository: $repo_name"
        dnf config-manager --add-repo "$repo_url"
    fi
}

# Function to enable a COPR repository - works with both DNF 4 and DNF 5
enable_copr() {
    local copr_repo="$1"
    print_warning "Enabling COPR repository: $copr_repo"
    
    # COPR repos are handled the same way in both DNF 4 and DNF 5
    dnf copr enable -y "$copr_repo"
}

# Check if RPM Fusion repositories are enabled
if ! dnf repolist | grep -q "rpmfusion-free"; then
    print_warning "RPM Fusion Free repository not found. Adding it..."
    add_repo "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
    print_success "RPM Fusion Free repository added"
fi

if ! dnf repolist | grep -q "rpmfusion-nonfree"; then
    print_warning "RPM Fusion NonFree repository not found. Adding it..."
    add_repo "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    print_success "RPM Fusion NonFree repository added"
fi

# Check for Hyprland repository
if ! dnf repolist | grep -q "copr:copr.fedorainfracloud.org:solopasha:hyprland"; then
    print_warning "Hyprland repository not found. Adding it..."
    enable_copr "solopasha/hyprland"
    print_success "Hyprland repository added"
fi

# Check for Visual Studio Code repository (balena-etcher dependency)
if ! dnf repolist | grep -q "code"; then
    print_warning "VS Code repository not found. Adding it..."
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    
    # Create repo file directly instead of using config-manager
    cat > /etc/yum.repos.d/vscode.repo << EOF
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
    print_success "VS Code repository added"
fi

# Check for Tailscale repository
if ! dnf repolist | grep -q "tailscale"; then
    print_warning "Tailscale repository not found. Adding it..."
    
    # Create repo file directly instead of using config-manager
    cat > /etc/yum.repos.d/tailscale.repo << EOF
[tailscale]
name=Tailscale
baseurl=https://pkgs.tailscale.com/stable/fedora/\$releasever/\$basearch
enabled=1
gpgcheck=1
gpgkey=https://pkgs.tailscale.com/stable/fedora/rpmsign-gpg.key
EOF
    print_success "Tailscale repository added"
fi

# Check for NeoVim repository
if ! dnf repolist | grep -q "copr:copr.fedorainfracloud.org:agriffis:neovim-nightly"; then
    print_warning "NeoVim nightly repository not found. Adding it..."
    enable_copr "agriffis/neovim-nightly"
    print_success "NeoVim nightly repository added"
fi

print_section "Checking package availability"

# Check if all packages are available in repositories
UNAVAILABLE_PACKAGES=""
for package in $(cat "$TEMP_PKG_FILE"); do
    if ! dnf list --available "$package" &>/dev/null; then
        UNAVAILABLE_PACKAGES="$UNAVAILABLE_PACKAGES $package"
    fi
done

if [ -n "$UNAVAILABLE_PACKAGES" ]; then
    print_warning "The following packages are not available in current repositories:"
    for package in $UNAVAILABLE_PACKAGES; do
        echo "  - $package"
    done
    
    read -p "Do you want to continue with installation of available packages? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Installation aborted by user"
        rm "$TEMP_PKG_FILE"
        exit 1
    fi
    
    # Create a new file with only available packages
    AVAILABLE_PKG_FILE=$(mktemp)
    for package in $(cat "$TEMP_PKG_FILE"); do
        if dnf list --available "$package" &>/dev/null; then
            echo "$package" >> "$AVAILABLE_PKG_FILE"
        fi
    done
    
    print_section "Installing available packages"
    dnf install -y $(cat "$AVAILABLE_PKG_FILE")
    rm "$AVAILABLE_PKG_FILE"
else
    print_section "Installing all packages"
    dnf install -y $(cat "$TEMP_PKG_FILE")
fi

rm "$TEMP_PKG_FILE"
print_success "Package installation completed"

print_section "Setting up ZSH and related tools"

# Install antidote if not already installed
if [ ! -d "$USER_HOME/.antidote" ]; then
    print_warning "Installing antidote for ZSH plugin management"
    sudo -u "$USER_NAME" git clone --depth=1 https://github.com/mattmc3/antidote.git "$USER_HOME/.antidote"
    print_success "Antidote installed"
else
    print_success "Antidote already installed"
fi

# Set up tmux plugin manager
if [ ! -d "$USER_HOME/.tmux/plugins/tpm" ]; then
    print_warning "Installing Tmux Plugin Manager"
    sudo -u "$USER_NAME" mkdir -p "$USER_HOME/.tmux/plugins"
    sudo -u "$USER_NAME" git clone https://github.com/tmux-plugins/tpm "$USER_HOME/.tmux/plugins/tpm"
    print_success "Tmux Plugin Manager installed"
else
    print_success "Tmux Plugin Manager already installed"
fi

print_section "Setting up dotfiles"

# Create function to safely copy dotfiles with backup
copy_dotfile() {
    local src="$1"
    local dest="$2"
    
    # Extract filename from source
    local filename=$(basename "$src")
    
    # Strip the 'dot_' prefix if it exists and add a '.' at the beginning
    if [[ "$filename" == dot_* ]]; then
        filename=".${filename#dot_}"
    fi
    
    # Strip the '.tmpl' suffix if it exists
    if [[ "$filename" == *.tmpl ]]; then
        filename="${filename%.tmpl}"
    fi
    
    # Create full destination path
    local full_dest="$dest/$filename"
    
    # Create backup if file exists
    if [ -f "$full_dest" ]; then
        sudo -u "$USER_NAME" cp "$full_dest" "${full_dest}.bak"
        print_warning "Backed up existing $full_dest to ${full_dest}.bak"
    fi
    
    # Copy the file
    sudo -u "$USER_NAME" cp "$src" "$full_dest"
    print_success "Copied $filename to $dest"
}

# Copy all dotfiles to home directory
copy_dotfile "dot_gitconfig" "$USER_HOME"
copy_dotfile "dot_gitignore_global" "$USER_HOME"
copy_dotfile "dot_p10k.zsh" "$USER_HOME"
copy_dotfile "dot_tmux.conf.tmpl" "$USER_HOME"
copy_dotfile "dot_zsh_plugins.txt" "$USER_HOME"
copy_dotfile "dot_zshrc" "$USER_HOME"
copy_dotfile "executable_greeting.sh" "$USER_HOME"
copy_dotfile "alias.sh.tmpl" "$USER_HOME"
copy_dotfile "functions.sh" "$USER_HOME"

# Make sure the greeting script is executable
chmod +x "$USER_HOME/executable_greeting.sh"
sudo -u "$USER_NAME" mv "$USER_HOME/executable_greeting.sh" "$USER_HOME/greeting.sh"
chmod +x "$USER_HOME/greeting.sh"

# Create Hyprland config directory
sudo -u "$USER_NAME" mkdir -p "$USER_HOME/.config/hypr"

# Copy Hyprland config files
copy_dotfile "dot_config/hypr/hypridle.conf" "$USER_HOME/.config/hypr"
copy_dotfile "dot_config/hypr/hyprland.conf" "$USER_HOME/.config/hypr"
copy_dotfile "dot_config/hypr/hyprlock.conf" "$USER_HOME/.config/hypr"
copy_dotfile "dot_config/hypr/hyprpaper.conf" "$USER_HOME/.config/hypr"
copy_dotfile "dot_config/hypr/pyprland.toml" "$USER_HOME/.config/hypr"

# Fix filenames of Hyprland config files (remove the dot_ prefix)
for file in "$USER_HOME/.config/hypr/dot_config_hypr_"*; do
    if [ -f "$file" ]; then
        new_name=$(echo "$file" | sed 's/dot_config_hypr_//')
        sudo -u "$USER_NAME" mv "$file" "$new_name"
    fi
done

print_success "All dotfiles copied successfully"

print_section "Setting ZSH as default shell"

# Set ZSH as the default shell for the user
chsh -s $(which zsh) "$USER_NAME"
print_success "ZSH set as default shell for $USER_NAME"

print_section "Creating Wallpaper Directory"

# Create wallpaper directory if it doesn't exist
sudo -u "$USER_NAME" mkdir -p "$USER_HOME/Pictures"

# Check if wallpaper.jpg exists
if [ ! -f "$USER_HOME/Pictures/wallpaper.jpg" ]; then
    print_warning "No wallpaper.jpg found in $USER_HOME/Pictures"
    print_warning "You will need to add a wallpaper manually at $USER_HOME/Pictures/wallpaper.jpg"
fi

print_section "Final Setup Tasks"

# Make sure tmux.conf has the correct name
if [ -f "$USER_HOME/.tmux.conf.tmpl" ]; then
    sudo -u "$USER_NAME" mv "$USER_HOME/.tmux.conf.tmpl" "$USER_HOME/.tmux.conf"
fi

# Make sure alias.sh has the correct name
if [ -f "$USER_HOME/alias.sh.tmpl" ]; then
    sudo -u "$USER_NAME" mv "$USER_HOME/alias.sh.tmpl" "$USER_HOME/alias.sh"
fi

# Fix permissions on all files
sudo -u "$USER_NAME" chmod 644 "$USER_HOME/.zshrc" "$USER_HOME/.tmux.conf" "$USER_HOME/.p10k.zsh" "$USER_HOME/.gitconfig"

print_success "All configuration files are in place"
print_success "Setup complete!"

echo -e "\n${BOLD}${GREEN}System setup complete!${NC}"
echo -e "${YELLOW}You should restart your system or at least log out and log back in to apply all changes.${NC}"
echo -e "${YELLOW}Then run 'source ~/.zshrc' to initialize your new shell configuration.${NC}"
echo -e "${YELLOW}In tmux, press prefix + I (capital i) to install plugins.${NC}"
