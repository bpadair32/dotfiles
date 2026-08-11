# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository for a Fedora/RHEL-based Hyprland desktop environment. Manages shell configuration, window manager settings, and a unified theming system across multiple applications.

## Installation Commands

```bash
# Full installation (idempotent, resumable)
./install.sh

# Fresh install (reset state)
./install.sh --clean

# Run specific phase
./install.sh -p <phase>

# Check installation status
./install.sh --status

# List available phases
./install.sh --list
```

Installation phases: preflight, repos, dnf, flatpak, pip-cargo, fonts, dotfiles, symlinks, plugins, post-install

## Theme System

The theme system provides unified colors across Hyprland, Waybar, Kitty, Rofi, Dunst, SwayNC, wlogout, and GTK.

```bash
# Apply a theme
theme-switch <theme-name>

# List themes
theme-switch --list

# Generate from wallpaper
theme-switch --pywal /path/to/image
theme-switch --matugen /path/to/image

# Save dynamic theme as static
theme-switch --save my-theme
```

Themes are defined in `themes/<name>/theme.toml` using Material Design 3 color tokens. Templates in `templates/` are processed with envsubst to generate app-specific color configs.

## Architecture

### Directory Structure

- `lib/` - Modular bash libraries for the installer (common.sh, state.sh, packages.sh, symlinks.sh, etc.)
- `packages/` - Package lists by category (dnf-core.txt, dnf-hyprland.txt, flatpak.txt, etc.)
- `themes/` - Theme definitions with theme.toml and optional wallpapers
- `templates/` - Color config templates processed by theme-switch
- `scripts/` - Utility scripts symlinked to ~/.local/scripts

### Symlink Mappings

The installer creates symlinks from this repo to their expected locations. Key mappings defined in `lib/symlinks.sh`:
- Shell configs (zshrc, alias.sh, functions.sh) → home directory
- App configs (nvim, kitty, hypr, waybar, rofi, etc.) → ~/.config/
- Scripts directory → ~/.local/scripts

### State Management

Installation state is tracked in `~/.local/share/dotfiles-install/state.json`, allowing:
- Resumable installations (interrupted installs continue where they left off)
- Per-item tracking (packages, symlinks, plugins)
- Failed item retry

### Theme File Format

Themes use TOML with sections:
- `[meta]` - name, description, wallpaper, GTK/icon/cursor theme
- `[colors]` - Material Design 3 tokens (primary, secondary, surface, on_surface, etc.)
- `[colors.terminal]` - Terminal-specific colors (color0-color15)
- `[colors.waybar]` - Custom waybar icon colors

Templates reference these as environment variables (e.g., `${PRIMARY}`, `${SURFACE}`).
