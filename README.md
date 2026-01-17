<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/claude_eiffel_op_docs/main/artwork/LOGO.png" alt="simple_ library logo" width="400">
</p>

# simple_chart

**[Documentation](https://simple-eiffel.github.io/simple_chart/)** | **[GitHub](https://github.com/simple-eiffel/simple_chart)**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Eiffel](https://img.shields.io/badge/Eiffel-25.02-blue.svg)](https://www.eiffel.org/)
[![Design by Contract](https://img.shields.io/badge/DbC-enforced-orange.svg)]()
[![Built with simple_codegen](https://img.shields.io/badge/Built_with-simple__codegen-blueviolet.svg)](https://github.com/simple-eiffel/simple_code)

ASCII chart and table rendering library for Eiffel. Load CSV data and render bar charts or formatted tables.

Part of the [Simple Eiffel](https://github.com/simple-eiffel) ecosystem.

## Status

**Development** - 13 tests passing

## Overview

SIMPLE_CHART provides a facade for loading CSV data and rendering it as ASCII visualizations. It supports horizontal bar charts with customizable width and character, and formatted ASCII tables with automatic column sizing.

## Features

- **CSV Data Loading** - Load from files or strings using simple_csv
- **Bar Chart Rendering** - Horizontal ASCII bar charts with scaling
- **Table Rendering** - Formatted ASCII tables with borders and alignment
- **Customizable** - Set bar width, bar character, column widths
- **Design by Contract** - Full preconditions, postconditions, invariants
- **Void Safe** - Fully void-safe implementation
- **SCOOP Compatible** - Ready for concurrent use

## Installation

1. Set the ecosystem environment variable (one-time setup for all simple_* libraries):
```bash
export SIMPLE_EIFFEL=D:\prod
```

2. Add to your ECF:
```xml
<library name="simple_chart" location="$SIMPLE_EIFFEL/simple_chart/simple_chart.ecf"/>
```

## Quick Start

### Bar Chart

```eiffel
local
    chart: SIMPLE_CHART
do
    create chart.make
    chart.load_csv_string ("Name,Sales%NAlice,150%NBob,200%NCharlie,175")
    print (chart.render_bar_chart (1, 2))
end
```

Output:
```
Alice   | ##############################  150
Bob     | ########################################  200
Charlie | ###################################  175
```

### Formatted Table

```eiffel
local
    chart: SIMPLE_CHART
do
    create chart.make
    chart.load_csv_string ("Name,Age,City%NAlice,30,NYC%NBob,25,LA")
    print (chart.render_table)
end
```

Output:
```
+-------+-----+------+
| Name  | Age | City |
+-------+-----+------+
| Alice | 30  | NYC  |
| Bob   | 25  | LA   |
+-------+-----+------+
```

## API Reference

### SIMPLE_CHART (Facade)

| Feature | Description |
|---------|-------------|
| `make` | Create chart instance |
| `load_csv (path)` | Load CSV from file |
| `load_csv_string (content)` | Load CSV from string |
| `render_bar_chart (label_col, value_col)` | Render bar chart |
| `render_table` | Render formatted table |
| `has_data` | Check if data is loaded |
| `last_error` | Get last error message |

### BAR_CHART_RENDERER

| Feature | Description |
|---------|-------------|
| `set_bar_width (width)` | Set max bar width (default: 40) |
| `set_bar_character (char)` | Set bar fill character (default: #) |

### CSV_DATA_LOADER

| Feature | Description |
|---------|-------------|
| `row_count` | Number of data rows |
| `column_count` | Number of columns |
| `headers` | Get header row |
| `column_values (col)` | Get column as strings |
| `column_as_numbers (col)` | Get column as REAL_64 |

## Dependencies

- simple_csv (CSV parsing)
- simple_file (file operations)

## License

MIT License - Copyright (c) 2024-2025, Larry Rix
