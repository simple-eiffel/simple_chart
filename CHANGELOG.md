# Changelog

All notable changes to simple_chart will be documented in this file.

## [Unreleased]

- 2026-11-24: removed the tracked cairo 1.17.2 copies (cairo.dll, bin/cairo.dll). Tests take the fleet's cairo 1.18.0 set from simple_cairo (runtime/windows, on PATH through ec.sh); suite 46/0.

### Fixed
- Library target compiles: needed simple_graphviz fix to EIFFEL_GRAPH_GENERATOR (DIRECTORY.entries is PATH).

### Added
- Initial project structure

## [0.0.1] - YYYY-MM-DD

### Added
- Initial release