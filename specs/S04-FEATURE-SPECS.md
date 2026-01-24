# S04 - Feature Specifications: simple_chart

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23

---

## 1. SIMPLE_CHART Feature Specifications

### make

| Attribute | Value |
|-----------|-------|
| Category | Creation |
| Signature | `make` |
| Purpose | Initialize chart facade with all components |
| Algorithm | Create data_loader, bar_renderer, table_renderer |

### load_csv

| Attribute | Value |
|-----------|-------|
| Category | Element change |
| Signature | `load_csv (a_path: READABLE_STRING_GENERAL)` |
| Purpose | Load CSV data from file |
| Parameters | a_path: path to CSV file |
| Algorithm | 1. Clear last_error; 2. Delegate to data_loader.load_from_file; 3. Set last_error if failed |
| Side Effects | Updates has_data, may set last_error |

### load_csv_string

| Attribute | Value |
|-----------|-------|
| Category | Element change |
| Signature | `load_csv_string (a_content: READABLE_STRING_GENERAL)` |
| Purpose | Load CSV data from string |
| Parameters | a_content: CSV content as string |
| Algorithm | Delegate to data_loader.load_from_string |

### render_bar_chart

| Attribute | Value |
|-----------|-------|
| Category | Output |
| Signature | `render_bar_chart (a_label_column, a_value_column: INTEGER): STRING` |
| Purpose | Render horizontal bar chart |
| Parameters | a_label_column: column for labels (1-based); a_value_column: column for values (1-based) |
| Algorithm | 1. Get labels from column; 2. Get numeric values; 3. Delegate to bar_renderer.render; 4. Return as_string |
| Return | ASCII art bar chart |

### render_table

| Attribute | Value |
|-----------|-------|
| Category | Output |
| Signature | `render_table: STRING` |
| Purpose | Render data as ASCII table |
| Algorithm | 1. Get headers; 2. Get all rows; 3. Delegate to table_renderer.render; 4. Return as_string |
| Return | ASCII art table |

---

## 2. CSV_DATA_LOADER Feature Specifications

### row_count

| Attribute | Value |
|-----------|-------|
| Category | Access |
| Signature | `row_count: INTEGER` |
| Purpose | Get number of data rows (excluding header) |
| Algorithm | Return csv_parser.row_count - 1 |

### column_count

| Attribute | Value |
|-----------|-------|
| Category | Access |
| Signature | `column_count: INTEGER` |
| Purpose | Get number of columns |
| Algorithm | Return count of first row |

### column_values

| Attribute | Value |
|-----------|-------|
| Category | Access |
| Signature | `column_values (a_column: INTEGER): ARRAYED_LIST [STRING]` |
| Purpose | Get all values from a column (excluding header) |
| Parameters | a_column: 1-based column index |
| Algorithm | Iterate rows 2..n, extract column value |

### column_as_numbers

| Attribute | Value |
|-----------|-------|
| Category | Access |
| Signature | `column_as_numbers (a_column: INTEGER): ARRAYED_LIST [REAL_64]` |
| Purpose | Get column values as numbers |
| Parameters | a_column: 1-based column index |
| Algorithm | Get column_values, convert each to REAL_64 (0.0 if not numeric) |

---

## 3. BAR_CHART_RENDERER Feature Specifications

### render

| Attribute | Value |
|-----------|-------|
| Category | Element change |
| Signature | `render (a_labels: ARRAYED_LIST [STRING]; a_values: ARRAYED_LIST [REAL_64])` |
| Purpose | Generate ASCII bar chart |
| Parameters | a_labels: row labels; a_values: numeric values |
| Algorithm | 1. Find max value; 2. Find max label width; 3. For each row: pad label, draw bar scaled to max |
| Output Format | `label | ######## value` |

### Bar Scaling Algorithm

```
bar_length = (value / max_value) * bar_width
```

### Output Example

```
Product A | ################################ 100
Product B | ######################## 75
Product C | ################ 50
Product D | ######## 25
```

---

## 4. TABLE_RENDERER Feature Specifications

### render

| Attribute | Value |
|-----------|-------|
| Category | Element change |
| Signature | `render (a_headers: ARRAYED_LIST [STRING]; a_rows: ARRAYED_LIST [ARRAYED_LIST [STRING]])` |
| Purpose | Generate ASCII table |
| Parameters | a_headers: column headers; a_rows: data rows |
| Algorithm | 1. Calculate column widths; 2. Render separator; 3. Render header; 4. Render separator; 5. Render each row; 6. Render bottom separator |

### Column Width Algorithm

```
width[col] = max(header[col].count, max_row_value[col].count)
```

### Output Example

```
+----------+-------+--------+
| Product  | Sales | Profit |
+----------+-------+--------+
| Widget A |  1000 |    250 |
| Widget B |   500 |    100 |
| Widget C |  2500 |    750 |
+----------+-------+--------+
```

---

## 5. Configuration Options

### BAR_CHART_RENDERER Settings

| Setting | Default | Range | Purpose |
|---------|---------|-------|---------|
| bar_width | 40 | > 0 | Maximum bar length in characters |
| bar_character | '#' | Any char | Character used for bar fill |

### Potential Future Settings

| Setting | Purpose |
|---------|---------|
| show_percentage | Display percentages instead of values |
| sort_order | Sort bars by value |
| min_bar_length | Minimum bar for visibility |
