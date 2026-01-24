# S02 - Class Catalog: simple_chart

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23

---

## 1. Class Hierarchy

```
SIMPLE_CHART (facade)
    |
    +-- CSV_DATA_LOADER (data input)
    |
    +-- BAR_CHART_RENDERER (visualization)
    |
    +-- TABLE_RENDERER (visualization)
```

## 2. Class Descriptions

### SIMPLE_CHART (Facade)

| Attribute | Value |
|-----------|-------|
| Role | Main entry point and facade |
| Responsibility | Coordinate data loading and rendering |
| Creatable | Yes (via `make`) |
| Inherits | None |

**Key Collaborators:**
- Uses CSV_DATA_LOADER for data input
- Uses BAR_CHART_RENDERER for bar charts
- Uses TABLE_RENDERER for tables

### CSV_DATA_LOADER

| Attribute | Value |
|-----------|-------|
| Role | Data input handler |
| Responsibility | Load and parse CSV, provide data access |
| Creatable | Yes (via `make`) |
| Inherits | None |

**Key Collaborators:**
- Uses SIMPLE_CSV for parsing
- Uses SIMPLE_FILE for file I/O

### BAR_CHART_RENDERER

| Attribute | Value |
|-----------|-------|
| Role | Visualization generator |
| Responsibility | Render horizontal ASCII bar charts |
| Creatable | Yes (via `make`) |
| Inherits | None |

**Key Collaborators:**
- Receives data from SIMPLE_CHART
- Produces STRING output

### TABLE_RENDERER

| Attribute | Value |
|-----------|-------|
| Role | Visualization generator |
| Responsibility | Render formatted ASCII tables |
| Creatable | Yes (via `make`) |
| Inherits | None |

**Key Collaborators:**
- Receives data from SIMPLE_CHART
- Produces STRING output

## 3. Feature Groupings

### SIMPLE_CHART Features

| Category | Features |
|----------|----------|
| Access | data_loader, bar_renderer, table_renderer |
| Status report | has_data, last_error |
| Element change | load_csv, load_csv_string |
| Output | render_bar_chart, render_table |

### CSV_DATA_LOADER Features

| Category | Features |
|----------|----------|
| Access | row_count, column_count, headers, all_rows, column_values, column_as_numbers |
| Status report | has_data |
| Element change | load_from_file, load_from_string |

### BAR_CHART_RENDERER Features

| Category | Features |
|----------|----------|
| Access | output, as_string |
| Settings | bar_width, bar_character, set_bar_width, set_bar_character |
| Status report | is_rendered |
| Element change | render |
| Constants | Default_bar_width |

### TABLE_RENDERER Features

| Category | Features |
|----------|----------|
| Access | output, as_string |
| Status report | is_rendered |
| Element change | render |

## 4. Visibility Matrix

| Class | SIMPLE_CHART | CSV_DATA_LOADER | BAR_CHART_RENDERER | TABLE_RENDERER |
|-------|--------------|-----------------|-------------------|----------------|
| SIMPLE_CHART | - | Owns | Owns | Owns |
| CSV_DATA_LOADER | - | - | - | - |
| BAR_CHART_RENDERER | - | - | - | - |
| TABLE_RENDERER | - | - | - | - |

## 5. Data Flow

```
CSV File/String
      |
      v
CSV_DATA_LOADER
      | (parsed rows/columns)
      v
SIMPLE_CHART (coordinates)
      |
      +-----> BAR_CHART_RENDERER --> ASCII bar chart
      |
      +-----> TABLE_RENDERER --> ASCII table
```
