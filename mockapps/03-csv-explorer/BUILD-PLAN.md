# CSVExplorer CLI - Build Plan

## Phase Overview

| Phase | Deliverable | Dependencies |
|-------|-------------|--------------|
| Phase 1 | MVP - info, stats, head commands | simple_chart, simple_csv, simple_cli, simple_math |
| Phase 2 | Full analysis + filtering | Phase 1 + simple_validation, simple_sorter |
| Phase 3 | PDF export, large file handling | Phase 2 + simple_pdf, streaming |

---

## Phase 1: MVP

### Objective

Provide basic CSV exploration: load a file, display info (rows, columns, types), calculate statistics for numeric columns, and show formatted data samples.

### Deliverables

1. **CSVEXPLORER_CLI** - Entry point with `info`, `stats`, `head` commands
2. **CSV_DATA_SOURCE** - Data loading and access wrapper
3. **TYPE_INFERRER** - Basic type detection (integer, decimal, text)
4. **STATS_CALCULATOR** - Mean, median, min, max, count
5. **TABLE_FORMATTER** - Terminal table output with auto-width

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure and ECF | Compiles with all required libraries |
| T1.2 | Implement CSV_DATA_SOURCE | Wraps simple_csv, provides column access |
| T1.3 | Implement TYPE_INFERRER basic | Detects INTEGER, DECIMAL, TEXT |
| T1.4 | Implement STATS_CALCULATOR | Mean, median, min, max, count |
| T1.5 | Implement TABLE_FORMATTER | Auto-width, truncation, alignment |
| T1.6 | Implement `info` command | Row count, columns, types, file size |
| T1.7 | Implement `stats` command | Statistics for numeric columns |
| T1.8 | Implement `head` command | First N rows, formatted |
| T1.9 | Add sparkline distributions | Inline histogram in stats output |
| T1.10 | Write unit tests | 20+ tests for core functionality |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Load CSV | Valid 100-row file | Data source with 100 rows |
| Type inference | "123", "45.6", "abc" | INTEGER, DECIMAL, TEXT |
| Stats: mean | [10, 20, 30, 40, 50] | 30.0 |
| Stats: median | [1, 2, 3, 4, 5] | 3.0 |
| Table format | 5x3 data | Aligned table output |
| Info command | sales.csv | File info summary |
| Head command | --rows 5 | First 5 rows formatted |

### Sample Usage (Phase 1)

```bash
# File overview
csvexplorer info sales.csv

# Statistics
csvexplorer stats sales.csv

# First 10 rows
csvexplorer head sales.csv --rows 10

# Stats for specific column
csvexplorer stats sales.csv --columns amount
```

---

## Phase 2: Full Implementation

### Objective

Add comprehensive type inference, data profiling, filtering/sorting, and interactive exploration features.

### Deliverables

1. **Enhanced TYPE_INFERRER** - Dates, emails, booleans, categories
2. **DATA_PROFILER** - Completeness, uniqueness, patterns
3. **DATA_FILTER** - SQL-like WHERE conditions
4. **`profile` command** - Full data quality report
5. **`filter` command** - Query data
6. **`values` command** - Unique values per column
7. **`chart` command** - Generate visualizations

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Enhance TYPE_INFERRER | DATE, BOOLEAN, EMAIL, CATEGORY detection |
| T2.2 | Implement DATA_PROFILER | Completeness, uniqueness, patterns |
| T2.3 | Implement DATA_FILTER | Parse WHERE expressions, apply filters |
| T2.4 | Implement sorting | --sort column, --desc |
| T2.5 | Implement `profile` command | Full quality report |
| T2.6 | Implement `filter` command | "column > value" syntax |
| T2.7 | Implement `values` command | Unique values with counts |
| T2.8 | Implement `chart` command | --type bar/line/histogram |
| T2.9 | Implement CHART_SUGGESTER | Recommend chart types |
| T2.10 | Add `tail` and `sample` commands | Last N rows, random sample |
| T2.11 | Add column selection | --columns name,sales |
| T2.12 | Write integration tests | Full workflow tests |

### Filter Syntax

```
column = value        # Equality
column != value       # Not equal
column > value        # Greater than
column < value        # Less than
column >= value       # Greater or equal
column <= value       # Less or equal
column ~ pattern      # Regex match
column in (a, b, c)   # In list
column is null        # Null check
column is not null    # Not null check
```

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Type: DATE | "2024-01-15" | DATE type detected |
| Type: BOOLEAN | "true", "false" | BOOLEAN type detected |
| Type: EMAIL | "user@example.com" | EMAIL type detected |
| Profile | CSV with nulls | Completeness percentages |
| Filter | "amount > 100" | Filtered rows |
| Sort | --sort amount --desc | Descending order |
| Values | column "region" | Unique values with counts |
| Chart bar | --type bar --x name | Bar chart output |
| Chart histogram | --type histogram | Distribution chart |

### Sample Usage (Phase 2)

```bash
# Full profile
csvexplorer profile sales.csv

# Filter data
csvexplorer filter sales.csv "amount > 1000 and region = 'West'"

# Sort by column
csvexplorer head sales.csv --sort amount --desc

# Unique values
csvexplorer values sales.csv --column region

# Generate histogram
csvexplorer chart sales.csv --type histogram --column amount

# Bar chart
csvexplorer chart sales.csv --type bar --x name --y amount

# Random sample
csvexplorer sample sales.csv --rows 100
```

---

## Phase 3: Production Polish

### Objective

Add PDF export, large file handling with streaming, and production hardening.

### Deliverables

1. **PDF_EXPORTER** - Professional PDF reports
2. **Streaming analysis** - Handle GB+ files
3. **RESERVOIR_SAMPLER** - Memory-efficient sampling
4. **`export` command** - Export data in various formats
5. **Performance optimization** - Parallel processing

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement PDF_EXPORTER | Profile + charts in PDF |
| T3.2 | Implement streaming parser | Process without full load |
| T3.3 | Implement RESERVOIR_SAMPLER | Random sampling from stream |
| T3.4 | Implement streaming stats | Welford's algorithm |
| T3.5 | Implement `export` command | CSV, JSON, PDF output |
| T3.6 | Add --sample option | Sample large files |
| T3.7 | Add progress indicator | For large files |
| T3.8 | Improve error messages | Actionable suggestions |
| T3.9 | Performance optimization | Parallel column analysis |
| T3.10 | Write documentation | README, man page, examples |

### Sample Usage (Phase 3)

```bash
# PDF report
csvexplorer profile sales.csv --format pdf --output report.pdf

# Large file with sampling
csvexplorer stats large.csv --sample 10000

# Export filtered data
csvexplorer filter sales.csv "region = 'West'" --export west_sales.csv

# Export as JSON
csvexplorer head sales.csv --format json

# Show progress for large files
csvexplorer profile huge.csv --progress
```

---

## ECF Target Structure

```xml
<!-- Library target (reusable core) -->
<target name="csvexplorer_lib">
    <root all_classes="true"/>
    <library name="simple_chart" location="..."/>
    <library name="simple_csv" location="..."/>
    <library name="simple_math" location="..."/>
    <library name="simple_validation" location="..."/>
    <library name="simple_sorter" location="..."/>
    <cluster name="src" location="./src/" recursive="true">
        <file_rule>
            <exclude>/cli$</exclude>
        </file_rule>
    </cluster>
</target>

<!-- CLI executable target -->
<target name="csvexplorer" extends="csvexplorer_lib">
    <root class="CSVEXPLORER_CLI" feature="make"/>
    <library name="simple_cli" location="..."/>
    <cluster name="cli" location="./src/cli/" recursive="true"/>
</target>

<!-- Test target -->
<target name="csvexplorer_tests" extends="csvexplorer_lib">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="..."/>
    <cluster name="tests" location="./testing/" recursive="true"/>
</target>
```

## Build Commands

```bash
# Compile CLI
ec.exe -batch -config csvexplorer.ecf -target csvexplorer -c_compile

# Compile CLI (finalized)
ec.exe -batch -config csvexplorer.ecf -target csvexplorer -finalize -c_compile

# Run tests
ec.exe -batch -config csvexplorer.ecf -target csvexplorer_tests -c_compile
./EIFGENs/csvexplorer_tests/W_code/csvexplorer.exe
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All tests | 100% |
| Small file (<10MB) | Response time | < 1 second |
| Medium file (10-100MB) | Response time | < 5 seconds |
| Large file (1GB) with sampling | Response time | < 30 seconds |
| Type detection accuracy | Correct types | > 95% |
| Statistics accuracy | Verified calculations | 100% |
| Documentation | README + examples | Complete |

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Memory overflow on large files | Streaming + sampling |
| Slow type inference | Sample-based inference |
| Complex filter expressions | Start simple, add operators incrementally |
| Encoding issues | Default to UTF-8, detect alternatives |
