# S06 - Boundaries: simple_chart

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23

---

## 1. External Boundaries

### File System Interface

```
File System
     |
     | (CSV file path)
     v
SIMPLE_FILE
     |
     | (file content)
     v
SIMPLE_CSV
     |
     | (parsed rows)
     v
CSV_DATA_LOADER
```

### Dependencies

| Boundary | Dependency | Interface |
|----------|------------|-----------|
| CSV Parsing | simple_csv | SIMPLE_CSV.parse |
| File I/O | simple_file | SIMPLE_FILE.read_all |

---

## 2. Internal Module Boundaries

### Facade Pattern

```
Client Code
     |
     v
+-------------------+
|   SIMPLE_CHART    |  <-- Facade
+-------------------+
     |
     +--------+--------+
     |        |        |
     v        v        v
+--------+ +--------+ +--------+
|DATA    | |BAR     | |TABLE   |
|LOADER  | |RENDERER| |RENDERER|
+--------+ +--------+ +--------+
```

### Module Responsibilities

| Module | Responsibility | Does NOT Handle |
|--------|----------------|-----------------|
| SIMPLE_CHART | Coordination, error handling | Parsing, rendering details |
| CSV_DATA_LOADER | Data parsing, column access | Visualization |
| BAR_CHART_RENDERER | Bar chart generation | Data loading, tables |
| TABLE_RENDERER | Table generation | Data loading, charts |

---

## 3. Data Flow Boundaries

### Load-Render Pipeline

```
CSV Input
     |
     | load_csv / load_csv_string
     v
CSV_DATA_LOADER
     | (stores parsed data)
     v
has_data = True
     |
     | render_bar_chart / render_table
     v
Extract columns/rows
     |
     v
Renderer.render
     |
     v
STRING output
```

### Column Extraction Flow

```
column_values(n)
     |
     v
Iterate csv_parser.row_at(2..count)
     |
     v
Extract i_th(n) from each row
     |
     v
ARRAYED_LIST [STRING]
```

### Numeric Conversion Flow

```
column_as_numbers(n)
     |
     v
column_values(n)
     |
     v
For each value:
  if is_double then to_double
  else 0.0
     |
     v
ARRAYED_LIST [REAL_64]
```

---

## 4. Output Boundaries

### Bar Chart Output Structure

```
+------------------+-----+------------------------+--------+
| Label (padded)   | " | " | Bar (scaled)         | Value  |
+------------------+-----+------------------------+--------+
```

### Table Output Structure

```
+----+----+----+    <- Separator
| H1 | H2 | H3 |    <- Header row
+----+----+----+    <- Separator
| D1 | D2 | D3 |    <- Data rows
| D1 | D2 | D3 |
+----+----+----+    <- Separator
```

---

## 5. Error Boundaries

### Error Propagation

```
File not found
     |
     v
SIMPLE_FILE returns empty/error
     |
     v
CSV_DATA_LOADER.has_data = False
     |
     v
SIMPLE_CHART.last_error set
     |
     v
Client checks last_error
```

### Error States

| Error Source | Detection | Client Action |
|--------------|-----------|---------------|
| File not found | has_data = False, last_error set | Check last_error |
| Parse error | has_data = False | Check last_error |
| Invalid column | Precondition violation | Fix column index |
| No data | Precondition violation | Load data first |

---

## 6. Scope Boundaries

### In Scope

- CSV data loading (file and string)
- Horizontal bar charts
- ASCII tables
- Column extraction (string and numeric)
- Basic configuration (bar width, character)

### Out of Scope

- JSON/YAML data sources
- Line charts, scatter plots, pie charts
- Unicode/Braille graphics
- Terminal colors
- Interactive features
- Data aggregation/transformation
- Chart export (PNG, SVG)
- Real-time data updates

### Future Extensions

| Feature | Potential Integration |
|---------|----------------------|
| JSON data | simple_json |
| Color output | simple_console |
| Unicode blocks | simple_console |
| Chart images | simple_cairo |

---

## 7. API Boundaries

### Public API (SIMPLE_CHART)

| Feature | Visibility |
|---------|------------|
| make | Public |
| load_csv | Public |
| load_csv_string | Public |
| render_bar_chart | Public |
| render_table | Public |
| has_data | Public |
| last_error | Public |
| data_loader | Public (for advanced access) |
| bar_renderer | Public (for configuration) |
| table_renderer | Public |

### Internal API (direct use discouraged)

| Class | Features |
|-------|----------|
| CSV_DATA_LOADER | All features accessible but use via facade |
| BAR_CHART_RENDERER | Configuration exposed, render via facade |
| TABLE_RENDERER | Render via facade |
