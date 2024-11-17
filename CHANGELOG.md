# Changelog

All notable changes to this project will be documented in this file.

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
