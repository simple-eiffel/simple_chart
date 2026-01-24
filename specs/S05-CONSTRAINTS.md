# S05 - Constraints: simple_chart

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23

---

## 1. Data Input Constraints

### CSV Format

| Constraint | Value | Rationale |
|------------|-------|-----------|
| First row | Headers | Used as column names |
| Delimiter | Comma (via SIMPLE_CSV) | Standard CSV format |
| Empty values | Allowed | Treated as empty string or 0 |
| Quoted values | Supported | Via SIMPLE_CSV parser |

### Numeric Conversion

| Input | Result |
|-------|--------|
| Valid number | Parsed REAL_64 |
| Empty string | 0.0 |
| Non-numeric | 0.0 |

### Column Indexing

| Constraint | Value |
|------------|-------|
| Index base | 1-based |
| Minimum | 1 |
| Maximum | column_count |

---

## 2. Bar Chart Constraints

### Bar Width

| Constraint | Value |
|------------|-------|
| Minimum | > 0 |
| Default | 40 characters |
| Maximum | Unlimited (but terminal width limits display) |

### Value Handling

| Scenario | Behavior |
|----------|----------|
| All zeros | All bars have length 0 |
| Negative values | Clamped to 0 bar length |
| Max value | Full bar_width |
| Scaling | Linear: (value/max) * width |

### Label Handling

| Constraint | Description |
|------------|-------------|
| Alignment | Right-padded to max label width |
| Separator | " | " between label and bar |
| Value display | Appended after bar |

---

## 3. Table Constraints

### Column Width

| Constraint | Description |
|------------|-------------|
| Minimum | Width of header or widest cell |
| Maximum | Unlimited |
| Padding | 1 space on each side |

### Border Characters

| Element | Character |
|---------|-----------|
| Horizontal | - |
| Vertical | \| |
| Corner/Intersection | + |

### Row Handling

| Scenario | Behavior |
|----------|----------|
| Missing cells | Empty string |
| Extra cells | Columns added dynamically |

---

## 4. State Constraints

### Data Loading State

| State | has_data | last_error | Operations Allowed |
|-------|----------|------------|-------------------|
| Initial | False | Void | load_csv, load_csv_string |
| Loaded | True | Void | render_bar_chart, render_table, reload |
| Error | False | Set | reload |

### Renderer State

| State | is_rendered | Operations |
|-------|-------------|------------|
| Initial | False | render |
| Rendered | True | as_string, re-render |

---

## 5. Data Consistency Invariants

### SIMPLE_CHART

```eiffel
has_data_delegation: has_data = data_loader.has_data
```

### CSV_DATA_LOADER

```eiffel
data_consistency: has_data = (csv_parser.row_count > 0)
headers_match_columns: has_data implies (cached_headers.count = column_count)
```

### Renderers

```eiffel
is_rendered_consistency: is_rendered = (not output.is_empty)
```

---

## 6. Memory Constraints

| Component | Constraint |
|-----------|------------|
| CSV data | Held in memory as ARRAYED_LIST |
| Output strings | Regenerated on each render |
| Column widths | Recalculated per render |

### Large Data Considerations

| Data Size | Recommendation |
|-----------|----------------|
| < 1000 rows | No concerns |
| 1000-10000 rows | Acceptable |
| > 10000 rows | Consider streaming/pagination |

---

## 7. Thread Safety

| Component | Thread Safety |
|-----------|---------------|
| SIMPLE_CHART | Not thread-safe |
| CSV_DATA_LOADER | Not thread-safe |
| BAR_CHART_RENDERER | Not thread-safe |
| TABLE_RENDERER | Not thread-safe |

**Note:** For concurrent use, create separate instances per thread.

---

## 8. Output Constraints

### Character Set

| Constraint | Value |
|------------|-------|
| Output encoding | ASCII |
| Unicode | Not supported |
| Control characters | Newlines only (%N) |

### Terminal Compatibility

| Feature | Status |
|---------|--------|
| ANSI colors | Not implemented |
| Unicode blocks | Not implemented |
| Braille patterns | Not implemented |
