#!/bin/bash

# Project Navigator Library - Shared functions for project discovery and navigation

# Configuration (only set if not already defined)
if [[ -z "${PROJECT_INDEX:-}" ]]; then
    readonly PROJECT_INDEX="$HOME/.config/projnav/cache/index"
fi
if [[ -z "${PROJECT_STATE:-}" ]]; then
    readonly PROJECT_STATE="$HOME/.config/projnav/cache/state"
fi
if [[ -z "${PROJECT_METADATA_CACHE:-}" ]]; then
    readonly PROJECT_METADATA_CACHE="$HOME/.config/projnav/cache/metadata.cache"
fi
if [[ -z "${PROJECT_CACHE_JSON:-}" ]]; then
    readonly PROJECT_CACHE_JSON="$HOME/.config/projnav/cache/projects.json"
fi

# Search configuration for smart git-aware discovery
# These can be overridden by user config file
if [[ -z "${SEARCH_PATHS:-}" ]]; then
    declare -a SEARCH_PATHS=(
        "$HOME/projects"
        "$HOME/dev"
        "$HOME/work"
    )
fi

if [[ -z "${MAX_DEPTH:-}" ]]; then
    MAX_DEPTH=10
fi

# Project grouping configuration
# Define related projects that should be grouped together
# Format: "parent:child1,child2,child3"
# NOTE: Child names must match exact folder names (case-sensitive)
# These defaults are examples - override in user config
if [[ -z "${PROJECT_GROUPS:-}" ]]; then
    declare -A PROJECT_GROUPS=(
        # Example suite - uncomment and customize in your config:
        # ["my-platform"]="api-service,web-frontend,mobile-app"
    )
fi

# Suite sort priority (optional - only needed if you want custom sort order)
# Suites not listed here will sort alphabetically after listed suites
# Lower numbers = higher priority (displayed first)
# Example: SUITE_PRIORITY=(["my-platform"]=1 ["devtools"]=2 ["legacy-project"]=3)
if [[ -z "${SUITE_PRIORITY:-}" ]]; then
    declare -A SUITE_PRIORITY=()
fi

# Color codes for pretty output (only set if not already defined)
if [[ -z "${COLOR_RESET:-}" ]]; then
    readonly COLOR_RESET="\033[0m"
    readonly COLOR_BOLD="\033[1m"
    readonly COLOR_DIM="\033[2m"
    readonly COLOR_CYAN="\033[36m"
    readonly COLOR_GREEN="\033[32m"
    readonly COLOR_YELLOW="\033[33m"
    readonly COLOR_BLUE="\033[34m"
    readonly COLOR_RED="\033[31m"
fi

# ============================================================================
# CORE DISCOVERY FUNCTIONS
# ============================================================================

# Smart git-aware recursive discovery using find (much faster)
# Finds all .git directories and returns their parent directories
discover_git_repos() {
    local base_path="$1"

    # Use find with depth limit to locate all .git directories and files (for worktrees)
    # Explicitly exclude common build/dependency directories that slow things down
    # Max depth 8 to include nested MCP servers in mcp-workspace/servers/your-servers/*
    find "$base_path" -maxdepth 8 \
        \( -name node_modules -o -name .next -o -name dist -o -name build -o -name coverage \) -prune -o \
        \( -type d -name .git -o -type f -name .git \) -print 2>/dev/null | \
        while IFS= read -r git_path; do
            # Skip git worktree metadata directories (/.git/worktrees/*)
            if [[ "$git_path" == *"/.git/worktrees/"* ]]; then
                continue
            fi

            # Skip specific submodule paths to avoid duplicates with standalone repos
            # This can be customized in config with EXCLUDE_SUBMODULE_PATTERNS
            local parent_dir=$(dirname "$git_path")

            # Skip known nested repos if pattern is set
            if [[ -n "${EXCLUDE_SUBMODULE_PATTERNS:-}" ]]; then
                local should_skip=false
                for pattern in "${EXCLUDE_SUBMODULE_PATTERNS[@]}"; do
                    if [[ "$parent_dir" == *"$pattern"* ]]; then
                        should_skip=true
                        break
                    fi
                done
                if [[ "$should_skip" == true ]]; then
                    continue
                fi
            fi

            # Output the parent directory (the actual repo)
            echo "$parent_dir"
        done | sort -u
}

# Build the project index
build_index() {
    echo -e "${COLOR_CYAN}Building project index...${COLOR_RESET}"

    local -a all_repos=()

    # Search each configured path
    for search_path in "${SEARCH_PATHS[@]}"; do
        if [[ -d "$search_path" ]]; then
            while IFS= read -r repo; do
                [[ -n "$repo" ]] && all_repos+=("$repo")
            done < <(discover_git_repos "$search_path")
        fi
    done

    # Write to index file
    mkdir -p "$(dirname "$PROJECT_INDEX")"
    printf '%s\n' "${all_repos[@]}" > "$PROJECT_INDEX"

    echo -e "${COLOR_GREEN}✓${COLOR_RESET} Indexed ${#all_repos[@]} git repositories"
    echo -e "${COLOR_DIM}Index saved to: $PROJECT_INDEX${COLOR_RESET}"

    # Build metadata cache
    cache_project_metadata "${all_repos[@]}"

    # Build comprehensive JSON cache
    build_comprehensive_cache "${all_repos[@]}"
}

# Categorize a project path with hierarchical grouping
categorize_project() {
    local path="$1"
    local project_name=$(basename "$path")

    # Priority 0: Check if project is part of a PROJECT_GROUP (parent or child)
    # Group parents get their own suite category (e.g., "CATZEN SUITE")
    # Group children inherit their parent's suite category
    if is_group_parent "$project_name"; then
        # Convert to uppercase and append " SUITE"
        echo "${project_name^^} SUITE"
        return
    fi
    if is_group_child "$project_name"; then
        # Find the parent and use its suite category
        for parent in "${!PROJECT_GROUPS[@]}"; do
            local children="${PROJECT_GROUPS[$parent]}"
            if [[ ",$children," == *",$project_name,"* ]]; then
                echo "${parent^^} SUITE"
                return
            fi
        done
    fi

    # Priority 1: Archive folder takes precedence over everything
    if [[ "$path" == *"/archive/"* ]] || [[ "$path" == *"/Archive/"* ]]; then
        echo "Archive"
        return
    fi

    # Priority 2: Simple path-based categorization
    # Extract category from common path patterns
    local base_dir=$(basename "$(dirname "$path")")
    local parent_dir=$(basename "$(dirname "$(dirname "$path")")")

    # Common patterns: ~/projects/CategoryName/project
    if [[ "$path" == *"/projects/"* ]]; then
        # Check for nested categories like projects/Type/Subcategory/project
        if [[ "$base_dir" != "projects" ]]; then
            if [[ "$parent_dir" != "projects" ]]; then
                echo "${parent_dir} → ${base_dir}"
            else
                echo "$base_dir"
            fi
        else
            echo "Projects"
        fi
    # Common patterns: ~/dev/project or ~/work/project
    elif [[ "$path" == *"/dev/"* ]]; then
        echo "Development"
    elif [[ "$path" == *"/work/"* ]]; then
        echo "Work"
    # Home-level repos (dotfiles, etc)
    elif [[ "$(dirname "$path")" == "$HOME" ]]; then
        echo "Dotfiles"
    else
        echo "Other"
    fi
}

# Check if a project is a group parent
is_group_parent() {
    local project_name="$1"
    [[ -n "${PROJECT_GROUPS[$project_name]:-}" ]]
}

# Check if a project is a group child
is_group_child() {
    local project_name="$1"
    for parent in "${!PROJECT_GROUPS[@]}"; do
        local children="${PROJECT_GROUPS[$parent]}"
        if [[ ",$children," == *",$project_name,"* ]]; then
            return 0
        fi
    done
    return 1
}

# Get the children of a group parent
get_group_children() {
    local parent="$1"
    echo "${PROJECT_GROUPS[$parent]:-}"
}

# Load projects from comprehensive JSON cache (fast path)
discover_projects() {
    # If JSON cache exists and jq is available, use fast path
    if [[ -f "$PROJECT_CACHE_JSON" ]] && command -v jq &>/dev/null; then
        # Read from JSON cache - single jq command, no loops!
        # Output format: category|name|path|is_external|is_suite_parent|is_suite_child
        jq -r '.projects[] |
            select(.category != "Archive") |
            "\(.category)|\(.name)|\(.path)|\(.is_external)|\(.is_suite_parent)|\(.is_suite_child)"' \
            "$PROJECT_CACHE_JSON" | \
        sort -t'|' -k1,1 -k2,2 -k3,3
        return
    fi

    # Fallback: traditional slow path (if JSON cache doesn't exist)
    # If no index exists, build it (which will create JSON cache)
    if [[ ! -f "$PROJECT_INDEX" ]]; then
        build_index
        # Recursively call ourselves to use the newly created JSON cache
        discover_projects
        return
    fi

    # Legacy fallback if jq not available
    # User can configure EXCLUDED_PROJECTS in config
    local -a excluded_projects=()
    if [[ -n "${EXCLUDED_PROJECTS:-}" ]]; then
        excluded_projects=("${EXCLUDED_PROJECTS[@]}")
    fi

    local -a projects=()

    while IFS= read -r path; do
        [[ -z "$path" ]] && continue

        local project=$(basename "$path")

        local excluded=false
        for excluded_name in "${excluded_projects[@]}"; do
            if [[ "$project" == "$excluded_name" ]]; then
                excluded=true
                break
            fi
        done

        [[ "$excluded" == true ]] && continue

        local category=$(categorize_project "$path")

        [[ "$category" == "Archive" ]] && continue

        projects+=("$category|$project|$path")
    done < "$PROJECT_INDEX"

    sort_projects "${projects[@]}"
}

# Check if a repository is external (not managed by user)
# Can be configured with EXTERNAL_CHECK_PATTERN in config
is_external_repo() {
    local project_path="$1"

    # Check if .git directory or file exists
    if [[ ! -d "$project_path/.git" && ! -f "$project_path/.git" ]]; then
        echo "false"
        return
    fi

    # Get the remote origin URL
    local remote_url
    remote_url=$(cd "$project_path" && git remote get-url origin 2>/dev/null)

    # If no remote or error, assume it's user-managed
    if [[ -z "$remote_url" ]]; then
        echo "false"
        return
    fi

    # Check if user has configured an external check pattern
    if [[ -n "${EXTERNAL_CHECK_PATTERN:-}" ]]; then
        if [[ "$remote_url" == *"${EXTERNAL_CHECK_PATTERN}"* ]]; then
            echo "false"
        else
            echo "true"
        fi
    else
        # Default: check if it's from common external sources
        if [[ "$remote_url" == *"github.com/"* ]] && [[ "$remote_url" != *"github.com/$USER/"* ]]; then
            echo "true"
        else
            echo "false"
        fi
    fi
}

# Build metadata cache for fast description lookups
cache_project_metadata() {
    local -a projects=("$@")

    echo -e "${COLOR_CYAN}Building metadata cache...${COLOR_RESET}"

    # Create cache file
    mkdir -p "$(dirname "$PROJECT_METADATA_CACHE")"
    > "$PROJECT_METADATA_CACHE"

    local cached_count=0
    for project_path in "${projects[@]}"; do
        local desc=$(get_project_description_uncached "$project_path")
        echo "$project_path|$desc" >> "$PROJECT_METADATA_CACHE"
        ((cached_count++))
    done

    echo -e "${COLOR_GREEN}✓${COLOR_RESET} Cached descriptions for $cached_count projects"
}

# Build comprehensive JSON cache with ALL pre-computed metadata
build_comprehensive_cache() {
    local -a projects=("$@")

    echo -e "${COLOR_CYAN}Building comprehensive JSON cache...${COLOR_RESET}"

    # Create cache directory
    mkdir -p "$(dirname "$PROJECT_CACHE_JSON")"

    # Start JSON structure
    cat > "$PROJECT_CACHE_JSON" << EOF
{
  "version": "1.0",
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "projects": [
EOF

    local total=${#projects[@]}
    local count=0

    for project_path in "${projects[@]}"; do
        ((count++))

        # Pre-compute all metadata
        local project_name=$(basename "$project_path")
        local category=$(categorize_project "$project_path")
        local description=$(get_project_description_uncached "$project_path")
        local is_external=$(is_external_repo "$project_path")

        # Check suite membership
        local is_parent="false"
        local is_child="false"
        local suite_name="null"

        if is_group_parent "$project_name"; then
            is_parent="true"
        fi

        if is_group_child "$project_name"; then
            is_child="true"
            # Find which suite this belongs to
            for parent in "${!PROJECT_GROUPS[@]}"; do
                local children="${PROJECT_GROUPS[$parent]}"
                if [[ ",$children," == *",$project_name,"* ]]; then
                    suite_name="\"$parent\""
                    break
                fi
            done
        fi

        # Determine sort key (for sort_projects logic)
        local sort_key
        case "$category" in
            "Work")                      sort_key="1|$category|$project_name" ;;
            "Utility → DEV-TOOLS")       sort_key="2|$category|$project_name" ;;
            "Utility → LOGISTICAL")      sort_key="3|$category|$project_name" ;;
            "Utility → MULTI-AGENT")     sort_key="4|$category|$project_name" ;;
            "Utility → RESEARCH")        sort_key="5|$category|$project_name" ;;
            "Utility")                   sort_key="6|$category|$project_name" ;;
            "Extra → GAMES")             sort_key="7|$category|$project_name" ;;
            "Extra → OTHER")             sort_key="8|$category|$project_name" ;;
            "Extra")                     sort_key="9|$category|$project_name" ;;
            # Suite categories - check for custom priority
            *" SUITE")
                # Extract suite name (remove " SUITE" suffix)
                local suite_base="${category% SUITE}"
                suite_base="${suite_base,,}"  # Convert to lowercase for lookup

                # Check if suite has custom priority
                if [[ -n "${SUITE_PRIORITY[$suite_base]:-}" ]]; then
                    local priority="${SUITE_PRIORITY[$suite_base]}"
                    # Format priority as Y01, Y02, etc. for proper sorting
                    printf -v sort_key "Y%02d|%s|%s" "$priority" "$category" "$project_name"
                else
                    # No custom priority - sort alphabetically after prioritized suites
                    sort_key="Y99|$category|$project_name"
                fi
                ;;
            "System Config")             sort_key="ZZ|$category|$project_name" ;;
            *)                           sort_key="ZZZ|$category|$project_name" ;;
        esac

        # Escape JSON strings
        description=$(echo "$description" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed 's/$/\\n/' | tr -d '\n')
        project_path_escaped=$(echo "$project_path" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
        project_name_escaped=$(echo "$project_name" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
        category_escaped=$(echo "$category" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
        sort_key_escaped=$(echo "$sort_key" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')

        # Write JSON object
        cat >> "$PROJECT_CACHE_JSON" << EOF
    {
      "path": "$project_path_escaped",
      "name": "$project_name_escaped",
      "category": "$category_escaped",
      "description": "$description",
      "is_suite_parent": $is_parent,
      "is_suite_child": $is_child,
      "suite_name": $suite_name,
      "is_external": $is_external,
      "sort_key": "$sort_key_escaped"
    }
EOF

        # Add comma if not last item
        if [[ $count -lt $total ]]; then
            echo "," >> "$PROJECT_CACHE_JSON"
        fi
    done

    # Close JSON structure
    cat >> "$PROJECT_CACHE_JSON" << EOF

  ]
}
EOF

    echo -e "${COLOR_GREEN}✓${COLOR_RESET} Built comprehensive cache for $total projects"
}

# Get cached description (fast lookup)
get_cached_description() {
    local project_path="$1"
    grep "^${project_path}|" "$PROJECT_METADATA_CACHE" 2>/dev/null | cut -d'|' -f2-
}

# Get project description from package.json or README.md (uncached version)
get_project_description_uncached() {
    local project_path="$1"
    local package_json="$project_path/package.json"
    local readme="$project_path/README.md"
    local desc=""
    local max_length=100

    # Try package.json first
    if [[ -f "$package_json" ]]; then
        desc=$(grep -m1 '"description"' "$package_json" | sed 's/.*"description"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | tr -d '\r')
        if [[ -n "$desc" && "$desc" != *"description"* ]]; then
            if [[ ${#desc} -gt $max_length ]]; then
                echo "${desc:0:$max_length}..."
            else
                # Pad shorter descriptions to max_length, then add ...
                printf "%-${max_length}s...\n" "$desc"
            fi
            return
        fi
    fi

    # Fallback to README.md
    if [[ -f "$readme" ]]; then
        # Try to extract description from README
        # Strategy: Get first substantial non-empty, non-title line (at least 10 chars)
        while IFS= read -r line; do
            # Skip headers, empty lines, markdown syntax, HTML tags
            if [[ "$line" =~ ^#.*$ ]] || [[ -z "$line" ]] || [[ "$line" =~ ^\[.*$ ]] || [[ "$line" =~ ^-+$ ]] || [[ "$line" == \`\`\`* ]] || [[ "$line" =~ ^\<.*$ ]]; then
                continue
            fi
            # Clean markdown formatting, HTML tags, and strip carriage returns
            cleaned=$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/^> //' | sed 's/\*\*//g' | sed 's/__//g' | sed 's/<[^>]*>//g' | tr -d '\r')
            # Only use if substantial (>10 chars) and not just HTML/markdown artifacts
            if [[ ${#cleaned} -gt 10 ]] && [[ ! "$cleaned" =~ ^[[:space:]]*$ ]]; then
                desc="$cleaned"
                break
            fi
        done < "$readme"

        if [[ -n "$desc" ]]; then
            if [[ ${#desc} -gt $max_length ]]; then
                echo "${desc:0:$max_length}..."
            else
                # Pad shorter descriptions to max_length, then add ...
                printf "%-${max_length}s...\n" "$desc"
            fi
        fi
    fi
}

# Get project description from package.json or README.md (cached wrapper)
get_project_description() {
    local project_path="$1"

    # Fast path: Try JSON cache with jq
    if [[ -f "$PROJECT_CACHE_JSON" ]] && command -v jq &>/dev/null; then
        local desc=$(jq -r --arg path "$project_path" \
            '.projects[] | select(.path == $path) | .description' \
            "$PROJECT_CACHE_JSON" 2>/dev/null)
        if [[ -n "$desc" && "$desc" != "null" ]]; then
            echo "$desc"
            return
        fi
    fi

    # Fallback: Try old cache
    if [[ -f "$PROJECT_METADATA_CACHE" ]]; then
        local cached=$(get_cached_description "$project_path")
        if [[ -n "$cached" ]]; then
            echo "$cached"
            return
        fi
    fi

    # Last resort: uncached lookup
    get_project_description_uncached "$project_path"
}

# Custom sorting for projects (Work → Utility → Extra → Suites → Everything Else)
sort_projects() {
    local -a input_projects=("$@")

    printf '%s\n' "${input_projects[@]}" | while IFS='|' read -r category project path; do
        case "$category" in
            "Work")                      echo "1|$category|$project|$path" ;;
            "Utility → DEV-TOOLS")       echo "2|$category|$project|$path" ;;
            "Utility → LOGISTICAL")      echo "3|$category|$project|$path" ;;
            "Utility → MULTI-AGENT")     echo "4|$category|$project|$path" ;;
            "Utility → RESEARCH")        echo "5|$category|$project|$path" ;;
            "Utility")                   echo "6|$category|$project|$path" ;;
            "Extra → GAMES")             echo "7|$category|$project|$path" ;;
            "Extra → OTHER")             echo "8|$category|$project|$path" ;;
            "Extra")                     echo "9|$category|$project|$path" ;;
            # Suite categories - check for custom priority
            *" SUITE")
                # Extract suite name (remove " SUITE" suffix)
                suite_base="${category% SUITE}"
                suite_base="${suite_base,,}"  # Convert to lowercase for lookup

                # Check if suite has custom priority
                if [[ -n "${SUITE_PRIORITY[$suite_base]:-}" ]]; then
                    priority="${SUITE_PRIORITY[$suite_base]}"
                    # Format priority as Y01, Y02, etc. for proper sorting
                    printf "Y%02d|%s|%s|%s\n" "$priority" "$category" "$project" "$path"
                else
                    # No custom priority - sort alphabetically after prioritized suites
                    echo "Y99|$category|$project|$path"
                fi
                ;;
            "System Config")             echo "ZZ|$category|$project|$path" ;;
            *)                           echo "ZZZ|$category|$project|$path" ;;
        esac
    done | sort -t'|' -k1,1 -k2,2 -k3,3 | cut -d'|' -f2-
}

# ============================================================================
# STATE MANAGEMENT
# ============================================================================

# Save last selected project
save_state() {
    local project_path="$1"
    mkdir -p "$(dirname "$PROJECT_STATE")"
    echo "$project_path" > "$PROJECT_STATE"
}

# Load last selected project
load_state() {
    if [[ -f "$PROJECT_STATE" ]]; then
        cat "$PROJECT_STATE"
    fi
}
