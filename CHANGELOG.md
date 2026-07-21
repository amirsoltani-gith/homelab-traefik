# Changelog

All notable changes to this project will be documented in this file.

The project follows Semantic Versioning (SemVer).

## [Unreleased]

### Added

- GitHub Actions workflow for automatic GitHub Releases
- Automatic GitHub Release creation using GitHub CLI
- Automatically generated GitHub Release Notes

---

## [0.5.1] - 2026-07-15

### Added

- Docker backup improvements
- Initial backup and restore enhancements

---

## [0.5.0] - 2026-07-13

### Added

- Full Docker volume restore workflow
- MariaDB restore support
- Backup validation before restore
- Automatic Docker service startup after restore
- Health checks after restore
- Restore confirmation prompt

### Changed

- Improved phpMyAdmin health check
- Added `COMPOSE_PROJECT_NAME` to `.env.example`

### Fixed

- Fixed Docker volume restore path handling
- Fixed project name detection during restore
- Improved restore reliability