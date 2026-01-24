# S03 - Contracts: simple_chart

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23

---

## 1. SIMPLE_CHART Contracts

### Creation

```eiffel
make
    ensure
        data_loader_created: data_loader /= Void
        bar_renderer_created: bar_renderer /= Void
        table_renderer_created: table_renderer /= Void
```

### Feature Contracts

```eiffel
load_csv (a_path: READABLE_STRING_GENERAL)
    require
        path_not_empty: not a_path.is_empty
    ensure
        data_loaded_or_error: has_data or last_error /= Void

load_csv_string (a_content: READABLE_STRING_GENERAL)
    require
        content_not_empty: not a_content.is_empty
    ensure
        data_loaded_or_error: has_data or last_error /= Void

render_bar_chart (a_label_column, a_value_column: INTEGER): STRING
    require
        has_data: has_data
        label_column_valid: a_label_column >= 1 and a_label_column <= data_loader.column_count
        value_column_valid: a_value_column >= 1 and a_value_column <= data_loader.column_count
    ensure
        result_not_empty: not Result.is_empty

render_table: STRING
    require
        has_data: has_data
    ensure
        result_not_empty: not Result.is_empty
```

### Class Invariant

```eiffel
invariant
    components_initialized: data_loader /= Void and bar_renderer /= Void and table_renderer /= Void
    has_data_delegation: has_data = data_loader.has_data
```

---

## 2. CSV_DATA_LOADER Contracts

### Creation

```eiffel
make
    ensure
        parser_created: csv_parser /= Void
        no_data: not has_data
```

### Feature Contracts

```eiffel
row_count: INTEGER
    require
        has_data: has_data
    ensure
        non_negative: Result >= 0

column_count: INTEGER
    require
        has_data: has_data
    ensure
        non_negative: Result >= 0

headers: ARRAYED_LIST [STRING]
    require
        has_data: has_data
    ensure
        result_attached: Result /= Void

all_rows: ARRAYED_LIST [ARRAYED_LIST [STRING]]
    require
        has_data: has_data
    ensure
        result_attached: Result /= Void
        correct_count: Result.count = row_count

column_values (a_column: INTEGER): ARRAYED_LIST [STRING]
    require
        has_data: has_data
        column_valid: a_column >= 1 and a_column <= column_count
    ensure
        result_attached: Result /= Void
        correct_count: Result.count = row_count

column_as_numbers (a_column: INTEGER): ARRAYED_LIST [REAL_64]
    require
        has_data: has_data
        column_valid: a_column >= 1 and a_column <= column_count
    ensure
        result_attached: Result /= Void
        correct_count: Result.count = row_count

load_from_file (a_path: READABLE_STRING_GENERAL)
    require
        path_not_empty: not a_path.is_empty

load_from_string (a_content: READABLE_STRING_GENERAL)
    require
        content_not_empty: not a_content.is_empty
    ensure
        has_data_if_valid: csv_parser.row_count > 0 implies has_data
```

### Class Invariant

```eiffel
invariant
    parser_attached: csv_parser /= Void
    headers_attached: cached_headers /= Void
    data_consistency: has_data = (csv_parser.row_count > 0)
    headers_match_columns: has_data implies (cached_headers.count = column_count)
```

---

## 3. BAR_CHART_RENDERER Contracts

### Creation

```eiffel
make
    ensure
        output_empty: output.is_empty
        default_width: bar_width = Default_bar_width
```

### Feature Contracts

```eiffel
as_string: STRING
    ensure
        result_attached: Result /= Void

set_bar_width (a_width: INTEGER)
    require
        width_positive: a_width > 0
    ensure
        width_set: bar_width = a_width

set_bar_character (a_char: CHARACTER)
    ensure
        character_set: bar_character = a_char

render (a_labels: ARRAYED_LIST [STRING]; a_values: ARRAYED_LIST [REAL_64])
    require
        labels_attached: a_labels /= Void
        values_attached: a_values /= Void
        same_count: a_labels.count = a_values.count
    ensure
        rendered_if_data: not a_labels.is_empty implies is_rendered
```

### Class Invariant

```eiffel
invariant
    output_attached: output /= Void
    bar_width_positive: bar_width > 0
    is_rendered_consistency: is_rendered = (not output.is_empty)
```

---

## 4. TABLE_RENDERER Contracts

### Creation

```eiffel
make
    ensure
        output_empty: output.is_empty
```

### Feature Contracts

```eiffel
as_string: STRING
    ensure
        result_attached: Result /= Void

render (a_headers: ARRAYED_LIST [STRING]; a_rows: ARRAYED_LIST [ARRAYED_LIST [STRING]])
    require
        headers_attached: a_headers /= Void
        rows_attached: a_rows /= Void
    ensure
        rendered_if_headers: not a_headers.is_empty implies is_rendered
```

### Class Invariant

```eiffel
invariant
    output_attached: output /= Void
    column_widths_attached: column_widths /= Void
    is_rendered_consistency: is_rendered = (not output.is_empty)
```

---

## 5. Contract Summary

| Class | Preconditions | Postconditions | Invariants |
|-------|---------------|----------------|------------|
| SIMPLE_CHART | 6 | 7 | 2 |
| CSV_DATA_LOADER | 8 | 9 | 4 |
| BAR_CHART_RENDERER | 4 | 5 | 3 |
| TABLE_RENDERER | 2 | 3 | 3 |
| **Total** | **20** | **24** | **12** |
