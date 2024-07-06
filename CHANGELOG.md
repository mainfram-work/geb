# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- N/A

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

## [0.1.12] - 2024-07-06
### Added
- New Site Variables feature
- --debug option to the `geb server` command to show full build output when file changes are detected
- Updated bootstrap_jquery bundled template
- Updated basic bundled template
### Changed
- Simplified build and release command APIs
### Fixed
- Configured port not being used by the `geb server` command
- Fixed issue with template paths not working with certain wild card paths (.e.g. **/*.html)
### Security
- Fixed issues with generating a site template with `geb release --with_template`, it now packages a sanitized version of `geb.config.yml` without remote_url and remote_path

## [0.1.11] - 2024-07-04
### Added
- Initial release of Geb with core features for managing and building static websites.
- Command-line interface
- Support for initializing new sites with `geb init`.
- Site building capabilities with `geb build` and `geb release`.
- Local server for previewing sites with `geb server`.
- Remote upload functionality with `geb upload`.
- Built-in site templates including "basic" and "bootstrap_jquery".
- Configuration file support with `geb.config.yml`.
- Documentation and examples for site structure, pages, templates, and partials.