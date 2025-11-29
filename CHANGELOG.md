# Changelog

All notable changes to projnav will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.4.0] - 2025-11-29

### Added
- **Most Accessed Projects**: New tracking system for project access frequency
  - Lifetime access counts stored in `~/.config/projnav/cache/access_counts.json`
  - Most Accessed column displayed alongside Recent in header
  - Shows access count in parentheses (e.g., `(42)`)
- **Direct Navigation Shortcuts**:
  - `projnav --go N` / `-g N`: Jump directly to project number N
  - `projnav --last` / `-l`: Jump to last visited project
  - Shell function `m N`: Shorthand for `--go N`
  - Shell alias `ml`: Shorthand for `--last`
- **Configurable Recent Projects Count**: `display.recent_projects_count` in YAML config
  - History now respects configured count (default: 3, configurable up to any number)

### Changed
- Header display refactored to two sub-columns (Recent | Most Accessed)
- Version bump to 2.4.0
- Updated help text with new navigation options

### Roadmap
- Added Phase 3: Access Analytics (v2.6) to RECOMMENDED_IMPROVEMENTS.md
  - Planned: Access count decay/weighting toggle
  - Planned: Configurable decay algorithms

## [1.0.1] - 2025-11-20

### Added
- Version command: `projnav --version` or `projnav -v`
- CHANGELOG.md to track version history

### Changed
- Improved `is_external_repo()` performance: replaced `cd` subshell with `git -C`
- Cache file paths now use `~/.config/projnav/cache/` directory structure
- Updated cache filenames: `index`, `state`, `metadata.cache`, `projects.json`

### Fixed
- Corrected GitHub clone URL in README (yourusername → cordlesssteve)
- Clarified dependency requirements (Required vs Recommended vs Optional)

### Removed
- Hardcoded personal suite names from sort logic
- Outdated comment referencing non-existent tools
- Old cache file paths using "project-navigator" naming

## [1.0.0] - 2025-11-20

### Added
- Initial public release
- Visual menu mode with hierarchical project display
- Fuzzy search mode (fzf integration)
- Project suite relationships (parent-child grouping)
- Configurable suite sort priority
- Git worktree awareness
- Two-column smart layout with vertical alignment
- JSON caching for fast performance with 100+ projects
- External repository detection
- Interactive description system (`d<number>` command)
- Comprehensive documentation (installation, configuration, suite setup)
- Automated installation script
- MIT License

### Features
- Dual navigation modes (visual menu + fuzzy search)
- Hierarchical project visualization
- Suite relationships for monorepos and ecosystems
- Category-based organization (Work, Utility, Extra, etc.)
- Column layout adapts to terminal width
- Fast project discovery with caching
- Pure bash implementation (minimal dependencies)

[1.0.1]: https://github.com/cordlesssteve/projnav/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/cordlesssteve/projnav/releases/tag/v1.0.0
