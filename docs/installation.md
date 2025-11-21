# Installation Guide

## Quick Install

```bash
# Clone the repository
git clone https://github.com/cordlesssteve/projnav ~/.projnav

# Run installer
cd ~/.projnav
./install.sh
```

## Manual Installation

If you prefer to install manually:

### 1. Clone Repository

```bash
git clone https://github.com/cordlesssteve/projnav ~/.projnav
```

### 2. Create Symlink

```bash
mkdir -p ~/.local/bin
ln -s ~/.projnav/projnav ~/.local/bin/projnav
```

### 3. Add to PATH

Add `~/.local/bin` to your PATH if it's not already there:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 4. Setup Configuration

```bash
mkdir -p ~/.config/projnav
cp ~/.projnav/config/projnav.conf.example ~/.config/projnav/config
```

### 5. Edit Configuration

Edit `~/.config/projnav/config` to set your project paths:

```bash
# Set your project directories
SEARCH_PATHS=(
    "$HOME/projects"
    "$HOME/dev"
    "$HOME/work"
)

# Define project suites (optional)
declare -A PROJECT_GROUPS=(
    ["my-platform"]="api-service,web-frontend,mobile-app"
)
```

### 6. Build Index

```bash
projnav --rebuild
```

## Shell Integration

For the best experience, create an alias that sources projnav:

```bash
echo "alias pn='source projnav'" >> ~/.bashrc
source ~/.bashrc
```

Now you can use `pn` to quickly navigate projects!

## Optional Dependencies

### jq (Recommended)

Significantly improves performance:

```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq

# Fedora
sudo dnf install jq
```

### fzf (Recommended for Fuzzy Mode)

Enables fuzzy search mode (`projnav -f`):

```bash
# Ubuntu/Debian
sudo apt install fzf

# macOS
brew install fzf

# Fedora
sudo dnf install fzf
```

## Updating

```bash
cd ~/.projnav
git pull
```

## Uninstallation

```bash
rm ~/.local/bin/projnav
rm -rf ~/.projnav
rm -rf ~/.config/projnav
```

Remove the alias from your `~/.bashrc` if you added it.
