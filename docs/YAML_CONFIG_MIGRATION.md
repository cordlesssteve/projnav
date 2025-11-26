# YAML Configuration Migration Guide

## Overview

projnav v2.3+ supports a powerful YAML-based configuration system that provides:

- **Pattern-based discovery** - Include/exclude patterns for flexible project discovery
- **Custom hierarchies** - Define unlimited categories and subcategories
- **Project metadata** - Rich descriptions, tech stacks, status tracking
- **Pattern-based rules** - Auto-categorize projects based on naming patterns
- **Visual customization** - Colors, tree characters, display modes
- **Advanced features** - Git status, parallel discovery, caching control

## Quick Start

### 1. Create YAML Config

```bash
# Copy the example to your config directory
cp config/projnav.yaml.example ~/.config/projnav/projnav.yaml

# Edit to customize
vim ~/.config/projnav/projnav.yaml
```

### 2. Migration from Old Config

If you have an existing `~/.config/projnav/config` file, projnav will automatically migrate:

```bash
# projnav will detect old config and offer to migrate
pn

# Or force migration
projnav --migrate-config
```

### 3. Validation

```bash
# Validate your YAML configuration
projnav --validate-config

# Show effective configuration (merged with defaults)
projnav --show-config
```

## Configuration Structure

### Discovery Settings

Control how projnav finds your projects:

```yaml
discovery:
  search_paths:
    - ~/projects
    - ~/custom-path

  max_depth: 10

  # Exclude directories
  exclude_patterns:
    - node_modules
    - dist

  # Only include specific patterns (optional)
  include_patterns:
    - "*-workspace"

  # Exclude specific project names
  exclude_projects:
    - temp-project

  # Auto-discover git worktrees
  discover_worktrees: true

  # Mark repos not matching this pattern as [EXTERNAL]
  external_check_pattern: "your-github-username"
```

### Suite Definitions

Define project groupings (formerly PROJECT_GROUPS):

```yaml
suites:
  - name: my-platform
    category: Work
    description: "Main platform and instances"
    projects:
      - platform-main
      - platform-staging
      - platform-instance-1

  - name: dev-tools
    category: "Utility → DEV-TOOLS"
    description: "Development utilities"
    projects:
      - tool-1
      - tool-2
```

**Benefits over old format:**
- Hierarchical categories with `→` separators
- Descriptions for each suite
- Visual organization in display

### Categories

Define and order your categories:

```yaml
categories:
  - name: Work
    priority: 1
    color: cyan
    description: "Client projects"

  - name: "Utility → DEV-TOOLS"
    priority: 2
    color: blue
    description: "Development tools"
```

**Priority determines display order** (lower = shown first)

### Project Rules

Auto-categorize based on patterns:

```yaml
project_rules:
  # Pattern-based (regex)
  - pattern: ".*-instance-[0-9]+"
    category: "AUTO"  # Use parent category
    tag: "INSTANCE"
    color: yellow

  - pattern: ".*-staging$"
    category: "AUTO"
    tag: "STAGING"

  # Explicit rules
  - project: critical-project
    pin: true  # Show at top
    color: red
    tag: "CRITICAL"
```

### Project Metadata

Add rich metadata for search and display:

```yaml
metadata:
  - project: my-app
    description: "Customer-facing application"
    tech_stack: ["TypeScript", "React", "PostgreSQL"]
    status: production
    team: backend
    last_deploy: "2025-11-20"
```

**Use metadata for:**
- Enhanced search (search by tech stack, team, etc.)
- Better descriptions in display
- Status tracking
- Documentation

### Display Settings

Customize the visual experience:

```yaml
display:
  default_mode: two_column
  show_tags: true
  show_descriptions: false
  recent_projects_count: 5

  colors:
    header: blue
    category: cyan
    suite_tag: cyan
    project_tag: green

  tree_chars:
    branch: "├─"
    last: "└─"
```

## Advanced Features

### Pattern-Based Discovery

Include only specific patterns:

```yaml
discovery:
  include_patterns:
    - "*-workspace"
    - "*-suite"
```

### Multiple Category Hierarchies

Create deep hierarchies with `→`:

```yaml
categories:
  - name: "Work → Client → Platform"
    priority: 1

  - name: "Work → Client → Services"
    priority: 2

  - name: "Utility → DEV-TOOLS → MCP"
    priority: 10
```

### Conditional Rules

Apply rules based on context:

```yaml
project_rules:
  - pattern: ".*-dev$"
    category: "AUTO"
    tag: "DEV"
    color: cyan
    # Only show in development mode
    show_when:
      env: development
```

### Git Status Integration

```yaml
advanced:
  git_status: true  # Show git status indicators
```

Shows:
- `●` uncommitted changes
- `↑` commits to push
- `↓` commits to pull
- `✓` clean

### Performance Tuning

```yaml
advanced:
  parallel_discovery: true  # Faster search
  profile: true  # Show timing information

cache:
  enabled: true
  expiry: 3600  # 1 hour
```

## Migration Examples

### Old Format (Bash)

```bash
PROJECT_GROUPS=(
    ["CodebaseManager"]="Tool1,Tool2,Tool3"
    ["my-suite"]="app1,app2"
)

EXCLUDE_PATTERNS=(
    "node_modules"
    "dist"
)
```

### New Format (YAML)

```yaml
suites:
  - name: CodebaseManager
    category: "Utility → DEV-TOOLS"
    description: "Service orchestrator"
    projects:
      - Tool1
      - Tool2
      - Tool3

  - name: my-suite
    category: Work
    projects:
      - app1
      - app2

discovery:
  exclude_patterns:
    - node_modules
    - dist
```

## Benefits of YAML Config

1. **More Expressive** - Hierarchical structure is clearer
2. **Type Safe** - Validation catches errors early
3. **Better Defaults** - Fallback to sensible defaults
4. **Extensible** - Easy to add new features
5. **Documented** - Self-documenting with comments
6. **Standard Format** - YAML is widely understood

## Backward Compatibility

- Old Bash config (`~/.config/projnav/config`) still works
- YAML takes precedence if both exist
- Migration tool converts old format to new
- No breaking changes to existing workflows

## Troubleshooting

### Config Not Loading

```bash
# Check config path
projnav --config-path

# Validate syntax
projnav --validate-config

# Show errors
projnav --debug
```

### YAML Parsing Issues

- Ensure proper indentation (2 spaces recommended)
- Quote strings with special characters: `"Utility → DEV-TOOLS"`
- Use consistent formatting
- Check for tabs (YAML requires spaces)

### Migration Issues

```bash
# Force re-migration
projnav --migrate-config --force

# Keep old config as backup
cp ~/.config/projnav/config ~/.config/projnav/config.backup
```

## Future Enhancements

Planned features for YAML config:

- **Hooks** - Run commands on project selection
- **Aliases** - Custom shortcuts for projects
- **Filters** - Save custom filter presets
- **Workspaces** - Switch between different project sets
- **Remote Config** - Sync config across machines
- **Templates** - Config templates for common setups

## Examples

See `config/examples/` for complete configuration examples:

- `config/examples/minimal.yaml` - Minimal configuration
- `config/examples/full-featured.yaml` - All features enabled
- `config/examples/multi-team.yaml` - Multi-team setup
- `config/examples/monorepo.yaml` - Monorepo structure
