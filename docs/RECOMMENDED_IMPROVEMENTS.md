# Recommended Improvements for projnav

## Executive Summary

Based on analysis of the current system and comparison with the old "master" navigator, here are recommended improvements to make projnav more powerful and flexible.

## Current State

✅ **Already Working:**
- Category-based organization (`[Work]`, `[Utility → DEV-TOOLS]`, etc.)
- Suite parent-child relationships
- Smart flow wrapping for projects
- Recent projects history in header (configurable count)
- **Most Accessed projects tracking with lifetime counts** (v2.4)
- **Direct navigation: `m N` and `ml` shortcuts** (v2.4)
- Two-column boxed header with Recent/Most Accessed sub-columns
- Filter `.disabled` projects
- Fuzzy search with fzf integration
- YAML configuration system with comprehensive options

## Recommended Improvements

### 1. YAML Configuration System ⭐ **HIGH PRIORITY**

**Current Problem:**
- Bash-based config is hard to read and maintain
- Limited structure and validation
- Difficult to add new features
- No schema or documentation

**Solution:**
YAML-based configuration with:

```yaml
discovery:
  search_paths: [~/projects, ~/mcp-servers]
  exclude_patterns: [node_modules, dist]
  include_patterns: ["*-workspace"]  # NEW: whitelist patterns

suites:
  - name: my-platform
    category: Work
    description: "Platform and instances"  # NEW: suite descriptions
    projects: [platform-main, platform-staging]

project_rules:  # NEW: pattern-based auto-categorization
  - pattern: ".*-instance-[0-9]+"
    tag: "INSTANCE"
    color: yellow
```

**Benefits:**
- More expressive and readable
- Easy to extend with new features
- Built-in validation
- Self-documenting
- Standard format (YAML)

**Implementation Status:**
- ✅ Example YAML config created (`config/projnav.yaml.example`)
- ✅ Migration guide written (`docs/YAML_CONFIG_MIGRATION.md`)
- ⏳ Parser implementation needed
- ⏳ Migration tool needed

---

### 2. Pattern-Based Discovery ⭐ **HIGH PRIORITY**

**Current Problem:**
- Can only exclude patterns, not include
- No way to auto-categorize based on naming
- Manual configuration for every project

**Solution:**

```yaml
discovery:
  # Only search these patterns
  include_patterns:
    - "*-workspace"
    - "*-suite"
    - "platform-*"

  # Exclude these
  exclude_patterns:
    - "*-archive"
    - "*-backup"

project_rules:
  # Auto-tag staging environments
  - pattern: ".*-staging$"
    category: "AUTO"  # Use parent category
    tag: "STAGING"
    color: yellow

  # Auto-tag development instances
  - pattern: ".*-dev$"
    tag: "DEV"
    color: cyan
```

**Benefits:**
- Automatic categorization
- Less manual config
- Consistent naming enforcement
- Easier to manage large project sets

---

### 3. Enhanced Project Metadata ⭐ **MEDIUM PRIORITY**

**Current Problem:**
- Only description available
- No way to track tech stack, status, team, etc.
- Limited search capabilities

**Solution:**

```yaml
metadata:
  - project: my-app
    description: "Customer-facing application"
    tech_stack: ["TypeScript", "React", "PostgreSQL"]
    status: production
    team: backend
    last_deploy: "2025-11-20"
    repository: "github.com/user/my-app"
    documentation: "https://docs.my-app.com"
```

**Use Cases:**
- Enhanced search: "Find all TypeScript projects"
- Status filtering: "Show only production projects"
- Team views: "Show backend team projects"
- Better descriptions in display

---

### 4. Git Status Indicators ⭐ **MEDIUM PRIORITY**

**Current Problem:**
- No visibility into git status without opening project
- Can't see which projects need commits/pushes

**Solution:**

Add optional git status indicators:

```
[Work]
  1. my-app ● ↑      # Uncommitted changes + commits to push
  2. other-app ✓     # Clean
  3. third-app ↓     # Commits to pull
```

Symbols:
- `●` - Uncommitted changes
- `↑` - Commits to push
- `↓` - Commits to pull
- `✓` - Clean
- `×` - Conflicts

**Configuration:**

```yaml
advanced:
  git_status: true  # Enable git indicators
  git_status_symbols:
    dirty: "●"
    ahead: "↑"
    behind: "↓"
    clean: "✓"
```

**Performance:**
- Cache git status for 60 seconds
- Parallel status checks
- Optional (disabled by default)

---

### 5. Pinned Projects ⭐ **LOW PRIORITY**

**Current Problem:**
- Important projects buried in categories
- Have to remember numbers

**Solution:**

```yaml
project_rules:
  - project: critical-app
    pin: true  # Show at top in "Pinned" category
    color: red

display:
  show_pinned_section: true
```

Display:

```
[★ Pinned]
  1. critical-app
  2. active-work

[Work]
  3. other-project
  ...
```

---

### 6. Project Aliases ⭐ **LOW PRIORITY**

**Current Problem:**
- Long project names are hard to type
- Common typos in project selection

**Solution:**

```yaml
aliases:
  cm: CodebaseManager
  conn: connoisseur
  pn: projnav
```

Usage:
```bash
$ pn
> cm   # Quick jump to CodebaseManager
```

---

### 7. Saved Filters/Workspaces ⭐ **LOW PRIORITY**

**Current Problem:**
- Can't save commonly used project sets
- Always see all projects even when working on subset

**Solution:**

```yaml
workspaces:
  - name: client-work
    description: "Active client projects"
    include_categories: ["Work"]
    exclude_tags: ["ARCHIVED"]

  - name: mcp-dev
    description: "MCP server development"
    include_suites: ["mcp-workspace"]
    include_projects: ["projnav", "CodebaseManager"]
```

Usage:
```bash
$ pn --workspace client-work   # Show only client projects
$ pn -w mcp-dev                # MCP development view
```

---

### 8. Custom Hooks ⭐ **LOW PRIORITY**

**Current Problem:**
- No way to run custom commands on project selection
- Manual setup needed for each project

**Solution:**

```yaml
hooks:
  # Run on ANY project selection
  on_select:
    - "echo 'Opening {{project_name}}'"

  # Project-specific hooks
  project_hooks:
    - project: my-app
      on_select:
        - "source .env"
        - "echo 'Environment loaded'"
      on_leave:
        - "echo 'Goodbye!'"
```

---

### 9. Multi-Column Suite Display ⭐ **MEDIUM PRIORITY**

**Current Problem:**
- Suite children always in horizontal flow
- Hard to scan large suites

**Solution:**

For large suites (>5 children), use column layout:

```
[mcp-workspace → your-servers]
  49. autogen-unified          50. claude-telemetry      51. conversation-search
  52. file-converter           53. imthemap-mcp-server   54. layered-memory
  55. namecheap                56. token-analyzer        57. topolop-mcp-server
```

With tree chars option:

```
[mcp-workspace]
  49. mcp-workspace
      ├─ 50. autogen-unified       51. claude-telemetry      52. conversation-search
      ├─ 53. file-converter        54. imthemap-mcp-server   55. layered-memory
      └─ 56. namecheap             57. token-analyzer        58. topolop-mcp-server
```

---

### 10. Search Enhancements ⭐ **LOW PRIORITY**

**Current Problem:**
- Can only search by project name (via fzf)
- No advanced filtering

**Solution:**

```bash
# Search by tech stack
$ pn --search "tech:TypeScript"

# Search by category
$ pn --search "category:Work"

# Search by status
$ pn --search "status:production"

# Combined search
$ pn --search "tech:React status:production"
```

---

## Implementation Priority

### Phase 1: Foundation (v2.3) ✅ COMPLETE
1. ✅ YAML configuration schema design
2. ✅ YAML parser implementation
3. ✅ Config validation (`--validate-config`)
4. ✅ Pattern-based discovery

### Phase 2: Enhancement (v2.4) ✅ COMPLETE
5. ✅ Most Accessed projects tracking (lifetime counts)
6. ✅ Two sub-column header (Recent + Most Accessed)
7. ✅ Direct navigation shortcuts (`m N`, `ml`, `--go N`, `--last`)
8. ✅ Configurable recent projects count

### Phase 2.5: Additional Enhancements (v2.5)
- Enhanced metadata system
- Git status indicators
- Multi-column suite display

### Phase 3: Access Analytics (v2.6)
- Access count decay/weighting toggle (time-weighted vs lifetime counts)
- Access pattern visualization
- Configurable decay algorithm (exponential, linear, step)

### Phase 4: Advanced (v2.7+)
- Pinned projects
- Project aliases
- Saved workspaces
- Custom hooks
- Search enhancements

---

## Technical Considerations

### YAML Parsing in Bash

**Option 1: Pure Bash** (Recommended)
- Use `yq` tool for YAML parsing
- Fast and reliable
- Easy to install: `brew install yq` or `apt install yq`

**Option 2: Python**
- Use Python script for parsing
- More complex but more powerful
- Requires Python dependency

**Recommendation:** Use `yq` for YAML → JSON, then parse JSON with `jq` (already used)

### Backward Compatibility

- Keep old Bash config working indefinitely
- YAML takes precedence if both exist
- Provide migration tool: `projnav --migrate-config`
- No breaking changes to CLI interface

### Performance

- Cache parsed YAML config
- Invalidate cache when config file changes
- Use parallel discovery for git status
- Lazy load metadata (only when needed)

---

## User Feedback Questions

Before implementing, get feedback on:

1. **YAML vs. TOML** - Which format do you prefer?
2. **Git Status** - Want always-on or opt-in?
3. **Workspaces** - Useful feature or overkill?
4. **Hooks** - What hooks would you use?
5. **Search** - What search criteria matter most?

---

## Next Steps

1. Review this document and prioritize features
2. Implement Phase 1 (YAML config system)
3. Test with real projects
4. Gather user feedback
5. Iterate on Phase 2 features

---

## Summary

**Highest Impact, Lowest Effort:**
- YAML configuration system
- Pattern-based discovery
- Git status indicators (optional)

**High Impact, Medium Effort:**
- Enhanced metadata
- Multi-column suite display

**Nice to Have:**
- Pinned projects
- Aliases
- Workspaces
- Custom hooks
