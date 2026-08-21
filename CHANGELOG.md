# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.2] - 2026-08-21

### Fixed

- Dim green (`\033[2;32m`) was low-contrast on dark terminal backgrounds —
  same issue dim red had before. Switched to bright green (`\033[92m`).

## [0.1.1] - 2026-08-21

### Fixed

- Percentage text (`5%` / `50%` / `100%`) was variable width, so clawd's column
  shifted depending on how many digits the percentage had. Padded to a fixed
  4-character width so all three lines stay aligned regardless of value.

## [0.1.0] - 2026-08-21

Initial public release.

### Added

- Live 5-hour / 7-day rate-limit and context-window usage bars, color-coded
  green/yellow/red by threshold.
- clawd, Claude Code's real mascot (reverse-engineered pose art and color from
  the installed binary), sitting beside the bars with occasional random poses
  and a timed speech-bubble message.
- `install.sh` / `uninstall.sh` one-line installers.
- WTFPL license with the FAQ's suggested no-warranty disclaimer.
- README with screenshot and a "how it works" section.

[unreleased]: https://github.com/nghiatm-twendee/clawd-statusline/compare/v0.1.2...HEAD
[0.1.2]: https://github.com/nghiatm-twendee/clawd-statusline/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/nghiatm-twendee/clawd-statusline/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/nghiatm-twendee/clawd-statusline/releases/tag/v0.1.0
