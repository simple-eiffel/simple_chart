# CSVExplorer CLI - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_chart | Data visualization (histograms, bars, sparklines) | CHART_RENDERER |
| simple_csv | CSV parsing and iteration | CSV_PARSER, streaming |
| simple_file | File operations, size checking | File loading |
| simple_cli | Command-line argument parsing | CSVEXPLORER_CLI |
| simple_math | Statistical calculations | STATS_CALCULATOR |
| simple_validation | Type pattern matching | TYPE_INFERRER |
| simple_sorter | Data sorting | DATA_FILTER.sort |
| simple_container | Data structures | Column storage, aggregates |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_pdf | PDF report export | When --format pdf used |
| simple_json | JSON output format | When --format json used |
| simple_regex | Pattern detection | DATA_PROFILER patterns |
| simple_datetime | Date parsing and validation | TYPE_INFERRER for dates |
| simple_encoding | Character set handling | Non-UTF8 files |

## Integration Patterns

### simple_chart Integration

**Purpose:** Visualize data distributions and comparisons

**Usage:**
```eiffel
render_histogram (a_values: ARRAYED_LIST [REAL_64]; a_bin_count: INTEGER): STRING_32
    -- Render distribution as terminal histogram.
  local
    l_chart: SIMPLE_CHART
  do
    create l_chart.make
    l_chart.histogram_renderer.set_bin_count (a_bin_count)
    l_chart.set_braille_mode (True)
    Result := l_chart.histogram (a_values)
  end

render_sparkline_summary (a_values: ARRAYED_LIST [REAL_64]): STRING_32
    -- Render inline distribution sparkline.
  local
    l_chart: SIMPLE_CHART
  do
    create l_chart.make
    Result := l_chart.sparkline (a_values)
  end

render_category_bars (a_categories: ARRAYED_LIST [STRING]; a_counts: ARRAYED_LIST [REAL_64]): STRING
    -- Render category distribution as bar chart.
  local
    l_chart: SIMPLE_CHART
  do
    create l_chart.make
    l_chart.bar_renderer.set_bar_width (40)
    Result := l_chart.bar_chart (a_categories, a_counts)
  end
```

**Data flow:** Column values -> Statistical analysis -> Chart rendering -> Terminal

### simple_csv Integration

**Purpose:** Parse and iterate CSV data

**Usage:**
```eiffel
load_csv (a_path: STRING): CSV_DATA_SOURCE
    -- Load CSV file for analysis.
  local
    l_loader: CSV_DATA_LOADER
  do
    create l_loader.make
    l_loader.load_from_file (a_path)
    if l_loader.has_data then
      create Result.make_from_loader (l_loader)
    else
      create Result.make_empty
      Result.set_error (l_loader.last_error)
    end
  end

stream_csv (a_path: STRING; a_callback: PROCEDURE [ARRAYED_LIST [STRING]])
    -- Stream CSV for large files without loading all into memory.
  local
    l_csv: SIMPLE_CSV
    l_file: SIMPLE_FILE
    l_line: STRING
    l_row: ARRAYED_LIST [STRING]
  do
    create l_file.make (a_path)
    create l_csv.make

    across l_file.lines as line loop
      l_row := l_csv.parse_line (line)
      a_callback.call ([l_row])
    end
  end
```

### simple_math Integration

**Purpose:** Statistical calculations

**Usage:**
```eiffel
calculate_statistics (a_values: ARRAYED_LIST [REAL_64]): COLUMN_STATS
    -- Calculate full statistics for numeric column.
  local
    l_math: SIMPLE_MATH
  do
    create l_math.make
    create Result.make

    Result.set_count (a_values.count)
    Result.set_mean (l_math.mean (a_values))
    Result.set_median (l_math.median (a_values))
    Result.set_stddev (l_math.standard_deviation (a_values))
    Result.set_min (l_math.min (a_values))
    Result.set_max (l_math.max (a_values))
    Result.set_quartiles (l_math.quartiles (a_values))
    Result.set_mode (l_math.mode (a_values))
  end
```

### simple_validation Integration

**Purpose:** Type detection via pattern matching

**Usage:**
```eiffel
infer_column_type (a_sample: ARRAYED_LIST [STRING]): COLUMN_TYPE
    -- Infer column type from sample values.
  local
    l_validator: SIMPLE_VALIDATION
    l_integers, l_decimals, l_dates, l_emails: INTEGER
  do
    create l_validator.make

    across a_sample as v loop
      if v.is_empty then
        -- Skip empty
      elseif l_validator.is_integer (v) then
        l_integers := l_integers + 1
      elseif l_validator.is_decimal (v) then
        l_decimals := l_decimals + 1
      elseif l_validator.is_date (v) then
        l_dates := l_dates + 1
      elseif l_validator.is_email (v) then
        l_emails := l_emails + 1
      end
    end

    -- Determine type by majority
    Result := determine_majority_type (l_integers, l_decimals, l_dates, l_emails, a_sample.count)
  end
```

### simple_sorter Integration

**Purpose:** Sort data by columns

**Usage:**
```eiffel
sort_by_column (a_data: ARRAYED_LIST [CSV_ROW]; a_column: INTEGER; a_descending: BOOLEAN)
    -- Sort data by specified column.
  local
    l_sorter: SIMPLE_SORTER
  do
    create l_sorter.make
    l_sorter.sort_by_key (a_data, agent (row: CSV_ROW; col: INTEGER): COMPARABLE
      do
        Result := row.value_at (col)
      end (?, a_column))

    if a_descending then
      l_sorter.reverse (a_data)
    end
  end
```

## Dependency Graph

```
csvexplorer
    ├── simple_chart (required)
    │   ├── simple_csv
    │   ├── simple_json
    │   └── simple_file
    ├── simple_csv (required)
    │   └── simple_file
    ├── simple_cli (required)
    │   └── simple_file
    ├── simple_math (required)
    ├── simple_validation (required)
    │   └── simple_regex
    ├── simple_sorter (required)
    │   └── simple_container
    ├── simple_container (required)
    ├── simple_pdf (optional)
    │   └── simple_file
    ├── simple_datetime (optional)
    └── ISE base (required)
```

## ECF Configuration

```xml
<system name="csvexplorer" uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX">
    <target name="csvexplorer">
        <root class="CSVEXPLORER_CLI" feature="make"/>
        <option warning="warning">
            <assertions precondition="true" postcondition="true" check="true" invariant="true"/>
        </option>
        <capability>
            <concurrency support="scoop"/>
            <void_safety support="all"/>
        </capability>

        <!-- ISE base -->
        <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>

        <!-- Required simple_* -->
        <library name="simple_chart" location="$SIMPLE_EIFFEL/simple_chart/simple_chart.ecf"/>
        <library name="simple_csv" location="$SIMPLE_EIFFEL/simple_csv/simple_csv.ecf"/>
        <library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
        <library name="simple_math" location="$SIMPLE_EIFFEL/simple_math/simple_math.ecf"/>
        <library name="simple_validation" location="$SIMPLE_EIFFEL/simple_validation/simple_validation.ecf"/>
        <library name="simple_sorter" location="$SIMPLE_EIFFEL/simple_sorter/simple_sorter.ecf"/>
        <library name="simple_container" location="$SIMPLE_EIFFEL/simple_container/simple_container.ecf"/>

        <!-- Optional simple_* -->
        <!-- <library name="simple_pdf" location="$SIMPLE_EIFFEL/simple_pdf/simple_pdf.ecf"/> -->
        <!-- <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/> -->
        <!-- <library name="simple_datetime" location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf"/> -->

        <cluster name="src" location="./src/" recursive="true"/>
    </target>

    <target name="csvexplorer_tests" extends="csvexplorer">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <cluster name="tests" location="./testing/" recursive="true"/>
    </target>
</system>
```

## Data Flow Summary

```
┌──────────────────────────────────────────────────────────────────────┐
│                         CSVExplorer Flow                              │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│   CSV File ──► simple_csv ──► Row Iterator                           │
│                                    │                                  │
│                    ┌───────────────┼───────────────┐                 │
│                    ▼               ▼               ▼                 │
│              TYPE_INFERRER   STATS_CALCULATOR   DATA_PROFILER        │
│              (simple_validation)  (simple_math)                      │
│                    │               │               │                 │
│                    └───────────────┼───────────────┘                 │
│                                    ▼                                  │
│                              CSV_ANALYZER                            │
│                                    │                                  │
│         ┌──────────────────────────┼──────────────────────────┐      │
│         ▼                          ▼                          ▼      │
│   TABLE_FORMATTER          CHART_RENDERER           PDF_EXPORTER    │
│   (terminal tables)        (simple_chart)          (simple_pdf)     │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

## Performance Considerations

### Large File Handling

```eiffel
analyze_large_file (a_path: STRING; a_sample_size: INTEGER): CSV_ANALYSIS
    -- Analyze large file using sampling.
  local
    l_file_size: INTEGER_64
    l_sample: ARRAYED_LIST [CSV_ROW]
    l_sampler: RESERVOIR_SAMPLER
  do
    l_file_size := file_size (a_path)

    if l_file_size > Max_memory_load then
      -- Use reservoir sampling for large files
      create l_sampler.make (a_sample_size)
      stream_csv (a_path, agent l_sampler.consider)
      l_sample := l_sampler.sample

      create Result.make_from_sample (l_sample)
      Result.mark_as_sampled (a_sample_size, estimated_row_count (l_file_size))
    else
      -- Load entire file
      Result := analyze_full (a_path)
    end
  end
```

### Memory-Efficient Statistics

```eiffel
streaming_stats: STREAMING_STATISTICS
    -- Calculate stats without loading all data.
    -- Uses Welford's online algorithm for variance.
feature
    count: INTEGER_64
    mean: REAL_64
    m2: REAL_64  -- For variance calculation
    min_value, max_value: REAL_64

    update (a_value: REAL_64)
        local
            delta, delta2: REAL_64
        do
            count := count + 1
            delta := a_value - mean
            mean := mean + delta / count
            delta2 := a_value - mean
            m2 := m2 + delta * delta2

            if a_value < min_value then min_value := a_value end
            if a_value > max_value then max_value := a_value end
        end

    variance: REAL_64
        do
            if count > 1 then
                Result := m2 / (count - 1)
            end
        end
end
```
