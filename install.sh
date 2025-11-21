#!/bin/bash
# projnav installation script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     projnav Installation Script        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check bash version
if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
    echo -e "${RED}✗ Error: Bash 4.0+ required (you have $BASH_VERSION)${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Bash version: $BASH_VERSION"

# Check required commands
echo ""
echo "Checking dependencies..."

check_command() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 installed"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $1 not found"
        return 1
    fi
}

check_command "tput" || { echo -e "${RED}✗ tput is required${NC}"; exit 1; }
check_command "jq" || echo -e "${YELLOW}  Install jq for better performance: sudo apt install jq${NC}"
check_command "fzf" || echo -e "${YELLOW}  Install fzf for fuzzy search: sudo apt install fzf${NC}"

# Install to ~/.local/bin
echo ""
echo -e "${BLUE}Installing projnav...${NC}"

INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}⚠ $HOME/.local/bin is not in your PATH${NC}"
    echo ""
    echo "Add this line to your ~/.bashrc or ~/.zshrc:"
    echo -e "${GREEN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    echo ""
    read -p "Add to ~/.bashrc now? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        echo -e "${GREEN}✓${NC} Added to ~/.bashrc"
    fi
fi

# Create symlink
if [[ -L "$INSTALL_DIR/projnav" ]]; then
    rm "$INSTALL_DIR/projnav"
fi
ln -s "$SCRIPT_DIR/projnav" "$INSTALL_DIR/projnav"
echo -e "${GREEN}✓${NC} Installed to $INSTALL_DIR/projnav"

# Setup config directory
CONFIG_DIR="$HOME/.config/projnav"
mkdir -p "$CONFIG_DIR"

if [[ ! -f "$CONFIG_DIR/config" ]]; then
    cp "$SCRIPT_DIR/config/projnav.conf.example" "$CONFIG_DIR/config"
    echo -e "${GREEN}✓${NC} Created config file: $CONFIG_DIR/config"
    echo -e "${YELLOW}  Please edit this file to configure your projects${NC}"
else
    echo -e "${YELLOW}⚠${NC} Config already exists: $CONFIG_DIR/config"
fi

# Offer to create alias
echo ""
echo -e "${BLUE}Setting up shell integration...${NC}"
echo ""
echo "projnav works best when sourced (so it can change directories)"
echo "Recommended alias:"
echo -e "${GREEN}alias pn='source projnav'${NC}"
echo ""
read -p "Add this alias to ~/.bashrc? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "" >> ~/.bashrc
    echo "# projnav - Project Navigator" >> ~/.bashrc
    echo "alias pn='source projnav'" >> ~/.bashrc
    echo -e "${GREEN}✓${NC} Alias added to ~/.bashrc"
    echo -e "${YELLOW}  Run 'source ~/.bashrc' or start a new terminal${NC}"
fi

# Build initial index
echo ""
echo -e "${BLUE}Building project index...${NC}"
if "$INSTALL_DIR/projnav" --rebuild 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Project index created"
else
    echo -e "${YELLOW}⚠${NC} Could not build index (configure ~/.config/projnav/config first)"
fi

# Installation complete
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Installation Complete!               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo -e "  1. Edit ${BLUE}$CONFIG_DIR/config${NC} to configure your project paths"
echo -e "  2. Run ${GREEN}projnav${NC} to navigate your projects"
echo -e "  3. Use ${GREEN}pn${NC} alias for quick access"
echo -e "  4. Run ${GREEN}projnav -f${NC} for fuzzy search mode"
echo ""
echo "Documentation: https://github.com/cordlesssteve/projnav"
echo ""
