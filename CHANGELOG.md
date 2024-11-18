# Changelog

All notable changes to this project will be documented in this file.

## 1.2.0

### Added

- New `badge` command to update version badges in README.md
  - Command automatically syncs version badge with pubspec.yaml version
  - Supports dry-run mode to preview changes
  - Configurable file paths for both pubspec.yaml and README.md
  - Comprehensive error handling for missing files and invalid versions

- New `commit` command for version control operations
  - Creates commits and tags for versions independently
  - Supports dry-run mode to preview changes
  - Configurable pubspec.yaml path
  - Integrated with existing --auto-commit functionality

### Changed

- Refactored git operations into separate commit command
- Maintained backward compatibility with --auto-commit flag
- Improved code reuse between bump and commit commands

## 1.1.0 - 2024-02-08

### Added

- New `--auto-commit` flag to control automatic git operations during version bumps
- By default, version bumps no longer automatically create git commits or tags
- Users can opt-in to automatic git operations by using the `--auto-commit` flag
- When enabled, the tool will:
  1. Update the version in pubspec.yaml
  2. Stage changes with `git add`
  3. Create a commit with the message: `build(version): Bump version to {new_version}`
  4. Create a git tag with the new version

## 1.0.0 - 2024-02-07

### Added

- Updating versions without build numbers (1.0.0 -> 2.0.0)
- Keeping versions without build numbers when bumping (1.0.0 -> 1.1.0)
- Converting between formats as needed
- Maintaining existing build numbers with --no-build-number-update
- Command implementation validates flag combinations
- Documentation updated in both README.md and version_management.md with clear examples
- Added semver version bumping functionality to the CLI tool. Users can now bump major (x.0.0), minor (0.x.0), or patch (0.0.x) versions using --major, --minor, or --patch flags respectively. The functionality is fully tested and can be combined with existing date-based build numbers. Example usage:

## 0.0.1 - 2024-02-07

### Added

- Initial release of version_assist CLI tool
- Command to bump Flutter project versions
- Support for version update operations
- CLI completion functionality
- Version bump command implementation
- Update command implementation
