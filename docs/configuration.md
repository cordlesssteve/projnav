# Configuration Guide

projnav is configured through `~/.config/projnav/config`. This file uses bash syntax.

## Basic Configuration

### Search Paths

Define where projnav should search for projects:

```bash
SEARCH_PATHS=(
    "$HOME/projects"
    "$HOME/dev"
    "$HOME/work"
    "$HOME/clients"
)
```

### Search Depth

Control how deep to search for repositories (default: 10):

```bash
MAX_DEPTH=10
```

## Project Suites

Define parent-child relationships between projects:

```bash
declare -A PROJECT_GROUPS=(
    ["my-platform"]="api-service,web-frontend,mobile-app,admin-dashboard"
    ["dev-tools"]="cli-tool,vscode-extension,docs-site"
)
```

**Requirements:**
- Parent name must match the parent project folder name
- Child names must match exact folder names (case-sensitive)
- Separate children with commas (no spaces)

**Example structure:**
```
~/projects/
├── my-platform/              # Parent
├── api-service/              # Child
├── web-frontend/             # Child
└── mobile-app/               # Child
```

projnav will display this as:

```
[MY-PLATFORM SUITE]
   15. my-platform
       16. ├─ api-service      17. ├─ web-frontend      18. ├─ mobile-app
```

## Advanced Configuration

### Exclusion Patterns

Skip directories during discovery:

```bash
EXCLUDE_PATTERNS=(
    "node_modules"
    ".next"
    "dist"
    "build"
    "__pycache__"
)
```

### External Repository Detection

Customize how projnav detects external (non-user) repositories:

```bash
# Mark repos containing this pattern as user-owned
EXTERNAL_CHECK_PATTERN="github.com/yourusername"
```

### Submodule Exclusions

Skip specific nested repositories:

```bash
EXCLUDE_SUBMODULE_PATTERNS=(
    "*/parent-repo/external/nested-repo"
    "*/another-repo/submodules/*"
)
```

### Excluded Projects

Skip specific project names:

```bash
EXCLUDED_PROJECTS=(
    "old-project"
    "archived-repo"
    "test-repo"
)
```

## Display Settings

### Default UI State

```bash
# Show descriptions by default (default: false)
SHOW_DESCRIPTIONS=false

# Use two-column layout (default: true)
USE_TWO_COLUMNS=true

# Show project tags (default: false)
SHOW_TAGS=false
```

## Cache Settings

Customize cache locations (usually not needed):

```bash
CACHE_DIR="$HOME/.config/projnav/cache"
PROJECT_CACHE_JSON="$CACHE_DIR/projects.json"
PROJECT_INDEX="$CACHE_DIR/index"
PROJECT_STATE="$CACHE_DIR/state"
PROJECT_METADATA_CACHE="$CACHE_DIR/metadata.cache"
```

## Example Complete Configuration

```bash
# ~/.config/projnav/config

# Where to search for projects
SEARCH_PATHS=(
    "$HOME/projects"
    "$HOME/dev"
    "$HOME/clients"
)

MAX_DEPTH=10

# Project suites
declare -A PROJECT_GROUPS=(
    # Microservices platform
    ["platform"]="api-gateway,auth-service,user-service,payment-service"

    # Development tools ecosystem
    ["devtools"]="cli,vscode-ext,docs,website"

    # Multi-instance deployment
    ["myapp"]="myapp-prod,myapp-staging,myapp-dev"
)

# Directories to skip
EXCLUDE_PATTERNS=(
    "node_modules"
    ".next"
    "dist"
    "build"
    "coverage"
    "__pycache__"
    ".venv"
)

# Mark my repos (so others are tagged as [EXTERNAL])
EXTERNAL_CHECK_PATTERN="github.com/yourusername"

# Projects to exclude
EXCLUDED_PROJECTS=(
    "old-prototype"
    "archived-2023"
)
```

## Reloading Configuration

After editing your config:

```bash
projnav --rebuild
```

This rebuilds the project index with your new settings.

## Troubleshooting

### Projects Not Showing Up

1. Check `SEARCH_PATHS` includes the parent directory
2. Verify `MAX_DEPTH` is sufficient
3. Check if project is in `EXCLUDED_PROJECTS`
4. Rebuild index: `projnav --rebuild`

### Suite Relationships Not Working

1. Verify parent folder name matches key in `PROJECT_GROUPS`
2. Verify child folder names are exact (case-sensitive)
3. Check for typos in comma-separated child list
4. Rebuild index after changes

### Performance Issues

1. Install `jq` for faster lookups
2. Reduce `MAX_DEPTH` if you have very deep directory structures
3. Add commonly skipped directories to `EXCLUDE_PATTERNS`
