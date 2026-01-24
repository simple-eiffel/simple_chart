# S01 - Project Inventory: simple_chart

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23
**Library Version:** 1.0.0

---

## 1. Project Identity

| Attribute | Value |
|-----------|-------|
| Name | simple_chart |
| Purpose | Terminal data visualization library |
| Domain | Data Visualization / CLI |
| Facade Class | SIMPLE_CHART |
| ECF File | simple_chart.ecf |

## 2. File Inventory

### Source Files (src/)

| File | Class | Purpose |
|------|-------|---------|
| simple_chart.e | SIMPLE_CHART | Main facade - load data, render charts |
| csv_data_loader.e | CSV_DATA_LOADER | Load and parse CSV data |
| bar_chart_renderer.e | BAR_CHART_RENDERER | Render horizontal ASCII bar charts |
| table_renderer.e | TABLE_RENDERER | Render formatted ASCII tables |

### Test Files (testing/)

| File | Purpose |
|------|---------|
| test_app.e | Test application entry point |
| lib_tests.e | Library test suite |
| test_set_base.e | Base test set class |

## 3. Dependencies

### ISE Libraries

| Library | Purpose |
|---------|---------|
| base | Core Eiffel classes |

### simple_* Libraries

| Library | Purpose |
|---------|---------|
| simple_csv | CSV parsing |
| simple_file | File I/O |

## 4. Platform Requirements

| Requirement | Value |
|-------------|-------|
| OS | Cross-platform (Windows, Linux, macOS) |
| Terminal | Any terminal supporting ASCII |
| Compiler | EiffelStudio 25.02+ |

## 5. Documentation Assets

| File | Status |
|------|--------|
| README.md | Present |
| CHANGELOG.md | Present |
| research/SIMPLE_CHART_RESEARCH.md | Present (CLI candidates research) |
| docs/index.html | Present |

## 6. Known Limitations

1. ASCII-only output (no Unicode/Braille graphics)
2. Bar charts only (no line, scatter, pie charts yet)
3. CSV input only (no JSON/YAML data sources)
4. No color support (terminal colors)
5. No interactive features
