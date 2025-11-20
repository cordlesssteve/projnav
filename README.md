# projnav

**Visual project navigator with fuzzy search for complex multi-repo workspaces**

Navigate through dozens of projects with visual hierarchy, suite relationships, and git worktree awareness. Switch between visual menu mode and blazing-fast fuzzy search.

## Features

- 🌲 **Hierarchical visualization** - See project suites, categories, and relationships at a glance
- 🔍 **Dual navigation modes** - Visual menu (beginner-friendly) or fuzzy search (power users)
- 🎯 **Git worktree aware** - Automatically groups related worktrees together
- 📦 **Suite relationships** - Parent-child project grouping (monorepos, ecosystems)
- 🎨 **Smart column layout** - Adapts to terminal width with vertical alignment
- ⚡ **Fast** - JSON caching makes navigation instant even with 100+ projects
- 🛠️ **Zero dependencies** - Pure bash (fzf optional for fuzzy mode)

## Quick Start

```bash
# Visual menu mode (default)
projnav

# Fuzzy search mode
projnav -f
```

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/projnav ~/.projnav

# Run installer
~/.projnav/install.sh

# Or manual installation
ln -s ~/.projnav/projnav ~/.local/bin/projnav
cp ~/.projnav/config/projnav.conf.example ~/.config/projnav/config
```

## Usage

### Visual Menu Mode

```bash
$ projnav

[MY-PLATFORM SUITE]
   15. my-platform
       16. ├─ api-service      17. ├─ web-frontend      18. ├─ mobile-app      19. ├─ admin-dashboard

[DEV-TOOLS SUITE]
   28. dev-tools
       29. ├─ cli-tool      30. ├─ vscode-extension      31. ├─ docs-site

[Work]
   45. client-project-a      46. client-project-b      47. internal-tool

Commands:
  <number>  Navigate to project
  d<number> Show project description
  f         Switch to fuzzy mode
  c         Toggle column layout
  t         Toggle tags
  q         Quit
```

### Fuzzy Search Mode

```bash
$ projnav -f

# Type partial name: "apiser"
# Instantly finds: my-platform/api-service
# Press Enter to navigate
```

## Configuration

Edit `~/.config/projnav/config` to customize:

- Project search paths
- Suite relationships (parent-child groupings)
- Category definitions
- Exclusion patterns

See [docs/configuration.md](docs/configuration.md) for details.

## Why projnav?

**For developers managing complex workspaces:**

- **Consultants** - Juggling multiple client projects
- **Open source maintainers** - Dozens of repositories to track
- **Monorepo architects** - Multiple services in one ecosystem
- **Worktree users** - Feature branches as separate directories

**Complements existing tools:**

| Tool | Use Case | projnav Adds |
|------|----------|--------------|
| `z` / `autojump` | Fast navigation to frequent dirs | Visual discovery, hierarchy |
| `tmux` sessions | Persistent terminal contexts | Project-aware navigation |
| `fzf` scripts | Generic fuzzy finding | Suite relationships, worktree grouping |

## Documentation

- [Installation Guide](docs/installation.md)
- [Configuration Guide](docs/configuration.md)
- [Suite Setup](docs/suite-setup.md)

## Requirements

- Bash 4.0+
- `tput` (usually pre-installed)
- `jq` (for caching)
- `fzf` (optional, for fuzzy search mode)

## License

MIT License - see [LICENSE](LICENSE) for details

## Contributing

Contributions welcome! Please open an issue or PR.

---

**projnav** - Because navigating 100+ projects shouldn't require memorizing paths
