# Changelog

All notable changes to this kernel will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- AnyKernel3 packaging infrastructure
- Automated ZIP generation script (`scripts/package_anykernel3.sh`)
- Comprehensive documentation for building and flashing
- Device compatibility notes for SM-A146B and SM-A146M variants
- Kernel tuning documentation with safety recommendations

### Changed
- Enhanced README.md with detailed build and installation instructions
- Added PACKAGING.md for AnyKernel3 technical details

### Security
- Added device model verification in AnyKernel3 installer
- Prevents flashing on unsupported devices

## [1.0.0] - YYYY-MM-DD

### Added
- Initial kernel release for SM-A146B/M
- KernelSU support integrated
- Android 14 compatibility
- Exynos 1330 (s5e8535) SoC support
- hunter_defconfig configuration

### Notes
- Based on Linux kernel 5.15.104
- Tested on SM-A146B
- Compatible with SM-A146M (with minor caveats)

---

## Version Format

Versions follow semantic versioning: MAJOR.MINOR.PATCH

- **MAJOR**: Incompatible API changes or major kernel version bumps
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes, security patches

## Categories

- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security-related changes

## Template for New Releases

```markdown
## [VERSION] - YYYY-MM-DD

### Added
- New feature description

### Changed
- Changed feature description

### Fixed
- Bug fix description

### Security
- Security patch description

### Notes
- Additional notes
- Testing status
- Known issues
```
