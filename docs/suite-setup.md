# Suite Setup Guide

Project suites allow you to group related projects in a parent-child relationship.

## What Are Suites?

Suites are useful for:

- **Monorepos** - Multiple services in one ecosystem
- **Microservices** - Related services that work together
- **Multi-instance deployments** - Same app in different environments
- **Tool ecosystems** - Related development tools
- **Git worktrees** - Feature branches as separate directories

## Basic Suite Setup

### 1. Identify Your Suite Structure

Example workspace:
```
~/projects/
├── my-platform/          # Parent (main repo or coordinator)
├── api-service/          # Child (related service)
├── web-frontend/         # Child (related service)
├── mobile-app/           # Child (related service)
└── admin-dashboard/      # Child (related service)
```

### 2. Configure in projnav

Edit `~/.config/projnav/config`:

```bash
declare -A PROJECT_GROUPS=(
    ["my-platform"]="api-service,web-frontend,mobile-app,admin-dashboard"
)
```

### 3. Rebuild Index

```bash
projnav --rebuild
```

### 4. View Result

```bash
$ projnav

[MY-PLATFORM SUITE]
   15. my-platform
       16. ├─ api-service      17. ├─ web-frontend      18. ├─ mobile-app      19. ├─ admin-dashboard
```

## Advanced Examples

### Microservices Platform

```bash
declare -A PROJECT_GROUPS=(
    ["platform"]="api-gateway,auth-service,user-service,payment-service,notification-service,analytics-service"
)
```

### Multi-Environment Deployment

```bash
declare -A PROJECT_GROUPS=(
    ["myapp"]="myapp-production,myapp-staging,myapp-development,myapp-testing"
)
```

### Development Tool Ecosystem

```bash
declare -A PROJECT_GROUPS=(
    ["devtools"]="cli-tool,vscode-extension,intellij-plugin,docs-site,landing-page"
)
```

### Git Worktrees

If you use git worktrees:

```
~/projects/
├── myapp/                # Main worktree
├── myapp-feature-auth/   # Worktree: feature/auth branch
├── myapp-bugfix-login/   # Worktree: bugfix/login branch
└── myapp-hotfix/         # Worktree: hotfix branch
```

```bash
declare -A PROJECT_GROUPS=(
    ["myapp"]="myapp-feature-auth,myapp-bugfix-login,myapp-hotfix"
)
```

## Multiple Suites

You can define as many suites as needed:

```bash
declare -A PROJECT_GROUPS=(
    # Platform services
    ["platform"]="api-gateway,auth-service,user-service"

    # DevTools ecosystem
    ["devtools"]="cli,vscode-ext,docs"

    # Client A projects
    ["client-a"]="client-a-frontend,client-a-backend,client-a-mobile"

    # Client B projects
    ["client-b"]="client-b-web,client-b-api,client-b-admin"
)
```

## Rules and Limitations

### Parent Name Matching

✅ **Correct:** Parent name matches folder name
```bash
["my-platform"]="..."    # Folder: ~/projects/my-platform/
```

❌ **Wrong:** Parent name doesn't match
```bash
["platform"]="..."       # Folder: ~/projects/my-platform/  ← Won't work!
```

### Child Name Matching

✅ **Correct:** Exact folder names (case-sensitive)
```bash
["platform"]="api-service,web-frontend"
# Folders: ~/projects/api-service/, ~/projects/web-frontend/
```

❌ **Wrong:** Approximate or misspelled names
```bash
["platform"]="api,web"
# Looking for: ~/projects/api/, ~/projects/web/  ← Won't find them!
```

### Formatting

✅ **Correct:** Comma-separated, no spaces
```bash
["platform"]="api-service,web-frontend,mobile-app"
```

❌ **Wrong:** Spaces around commas
```bash
["platform"]="api-service, web-frontend, mobile-app"  ← Will fail!
```

## Navigation

Once configured, suites provide multiple navigation paths:

```bash
$ projnav

[MY-PLATFORM SUITE]
   15. my-platform        # Navigate to parent
       16. ├─ api-service # Or directly to child
       17. ├─ web-frontend
       18. ├─ mobile-app
```

- Type `15` → navigates to parent (my-platform)
- Type `16` → navigates to child (api-service)
- Type `d15` → shows parent description
- Type `d16` → shows child description

## Troubleshooting

### Suite Not Showing

**Problem:** Projects appear separately, not grouped

**Solutions:**
1. Verify parent folder name matches key exactly:
   ```bash
   # If folder is "my-platform"
   ["my-platform"]="..."  # ✓ Correct
   ["platform"]="..."     # ✗ Wrong
   ```

2. Check capitalization - bash is case-sensitive:
   ```bash
   # If folder is "MyPlatform"
   ["MyPlatform"]="..."   # ✓ Correct
   ["myplatform"]="..."   # ✗ Wrong
   ```

3. Rebuild index: `projnav --rebuild`

### Children Not Appearing

**Problem:** Parent shows but children don't

**Solutions:**
1. Verify child folder names are exact:
   ```bash
   ls ~/projects/  # Check actual folder names
   ```

2. Check for typos in child list:
   ```bash
   # Wrong:
   ["platform"]="api-sevice"  # Typo in "service"

   # Correct:
   ["platform"]="api-service"
   ```

3. Ensure commas, no spaces:
   ```bash
   # Wrong:
   ["platform"]="api, web"

   # Correct:
   ["platform"]="api,web"
   ```

4. Verify all children are in `SEARCH_PATHS`

### Display Issues

**Problem:** Suite appears but formatting is wrong

This might be a terminal width issue. projnav adapts to your terminal size. Try resizing your terminal or toggling column mode with `c`.

## Tips

1. **Start simple** - Define one suite, test it, then add more
2. **Use consistent naming** - Makes configuration easier
3. **Document your suites** - Add comments in config for clarity
4. **Rebuild after changes** - Always run `projnav --rebuild`

## Example Complete Setup

```bash
# ~/.config/projnav/config

# Where all projects live
SEARCH_PATHS=(
    "$HOME/projects"
)

# Define three suites
declare -A PROJECT_GROUPS=(
    # E-commerce platform (6 microservices)
    ["ecommerce"]="product-service,cart-service,order-service,payment-service,user-service,notification-service"

    # DevOps tools (4 related tools)
    ["devops-tools"]="deployment-cli,monitoring-dashboard,log-aggregator,alert-manager"

    # Mobile app (multi-environment)
    ["mobile-app"]="mobile-app-prod,mobile-app-staging,mobile-app-dev"
)
```

After saving: `projnav --rebuild`

Result:
```
[ECOMMERCE SUITE]
   10. ecommerce
       11. ├─ product-service     12. ├─ cart-service        13. ├─ order-service
       14. ├─ payment-service     15. ├─ user-service        16. ├─ notification-service

[DEVOPS-TOOLS SUITE]
   20. devops-tools
       21. ├─ deployment-cli      22. ├─ monitoring-dashboard
       23. ├─ log-aggregator      24. ├─ alert-manager

[MOBILE-APP SUITE]
   30. mobile-app
       31. ├─ mobile-app-prod     32. ├─ mobile-app-staging  33. ├─ mobile-app-dev
```
