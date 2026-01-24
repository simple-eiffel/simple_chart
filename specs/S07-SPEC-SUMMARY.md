# S07 - Specification Summary: simple_chart

**Status:** BACKWASH (reverse-engineered from implementation)
**Date:** 2026-01-23

---

## 1. Library Overview

**simple_chart** is a terminal data visualization library for Eiffel, providing ASCII bar charts and tables from CSV data.

### Key Capabilities

| Capability | Description |
|------------|-------------|
| CSV Loading | Load data from files or strings |
| Bar Charts | Horizontal ASCII bar charts |
| Tables | Formatted ASCII tables with auto-sizing |
| Column Access | Extract columns as strings or numbers |
| Configuration | Customizable bar width and character |

---

## 2. Architecture Summary

### Component Count

| Component | Count |
|-----------|-------|
| Classes | 4 |
| Public Features | 25+ |
| Preconditions | 20 |
| Postconditions | 24 |
| Class Invariants | 12 |

### Design Patterns

| Pattern | Application |
|---------|-------------|
| Facade | SIMPLE_CHART coordinates all operations |
| Strategy | Renderers encapsulate visualization algorithms |
| Delegation | Facade delegates to specialized components |

---

## 3. API Quick Reference

### Basic Usage

```eiffel
chart: SIMPLE_CHART
create chart.make

-- Load CSV data
chart.load_csv ("sales.csv")
-- or
chart.load_csv_string ("Name,Value%NAlice,100%NBob,75")

if chart.has_data then
    -- Render bar chart (column 1 = labels, column 2 = values)
    print (chart.render_bar_chart (1, 2))

    -- Render table
    print (chart.render_table)
else
    print ("Error: " + chart.last_error)
end
```

### Bar Chart Output

```
Alice | ################################ 100
Bob   | ######################## 75
Carol | ################ 50
```

### Table Output

```
+-------+-------+
| Name  | Value |
+-------+-------+
| Alice |   100 |
| Bob   |    75 |
| Carol |    50 |
+-------+-------+
```

### Configuration

```eiffel
-- Customize bar chart
chart.bar_renderer.set_bar_width (60)
chart.bar_renderer.set_bar_character ('=')

-- Then render
print (chart.render_bar_chart (1, 2))
```

---

## 4. Constraint Summary

### Data Constraints

| Constraint | Value |
|------------|-------|
| CSV format | Standard CSV with headers |
| Column indexing | 1-based |
| Numeric conversion | Non-numeric becomes 0.0 |

### Rendering Constraints

| Parameter | Default | Range |
|-----------|---------|-------|
| bar_width | 40 | > 0 |
| bar_character | '#' | Any character |

---

## 5. Dependencies

### Required

| Dependency | Purpose |
|------------|---------|
| ISE base library | Core Eiffel classes |
| simple_csv | CSV parsing |
| simple_file | File I/O |

---

## 6. Platform Support

| Platform | Status |
|----------|--------|
| Windows | Supported |
| Linux | Supported |
| macOS | Supported |

**Note:** Pure Eiffel, no platform-specific code.

---

## 7. Performance Characteristics

| Operation | Complexity |
|-----------|------------|
| CSV parsing | O(n) where n = characters |
| Column extraction | O(r) where r = rows |
| Bar chart render | O(r) |
| Table render | O(r * c) where c = columns |

---

## 8. Completeness Assessment

### Implemented Features

- [x] CSV file loading
- [x] CSV string loading
- [x] Horizontal bar charts
- [x] ASCII tables
- [x] Column value extraction
- [x] Numeric conversion
- [x] Configurable bar width
- [x] Configurable bar character
- [x] Auto-sizing table columns
- [x] Error handling

### Not Implemented (Future)

- [ ] Line charts
- [ ] Scatter plots
- [ ] Pie charts
- [ ] Sparklines
- [ ] Unicode/Braille graphics
- [ ] Terminal colors
- [ ] JSON data source
- [ ] Data sorting
- [ ] Data aggregation
- [ ] Chart titles/legends

---

## 9. Usage Recommendations

### Best Practices

1. **Check has_data** before rendering
2. **Validate column indices** (1 to column_count)
3. **Use last_error** for debugging load failures
4. **Adjust bar_width** for terminal width

### Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Rendering before loading | Check has_data first |
| Invalid column index | Use column_count to validate |
| Non-numeric values | Handled as 0.0, may need preprocessing |
| Wide output | Reduce bar_width or use narrower data |
