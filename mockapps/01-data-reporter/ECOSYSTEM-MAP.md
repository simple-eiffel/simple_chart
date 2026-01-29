# DataReporter CLI - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_chart | Chart rendering (bar, line, sparkline, scatter, histogram) | REPORT_ENGINE chart generation |
| simple_csv | CSV data loading and parsing | DATA_SOURCE.load_csv |
| simple_json | JSON data loading, config parsing | DATA_SOURCE.load_json, config loading |
| simple_file | File I/O, path operations | All file operations |
| simple_pdf | PDF document generation | PDF_RENDERER |
| simple_template | Template parsing and variable substitution | REPORT_TEMPLATE parsing |
| simple_cli | Command-line argument parsing | DATAREPORTER_CLI |
| simple_validation | Data schema validation | DATA_SOURCE.validate |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_email | Email report delivery | When --email flag used |
| simple_smtp | SMTP transport | When email delivery configured |
| simple_scheduler | Cron-style scheduling | When schedule command used |
| simple_cache | Template/data caching | Performance optimization |
| simple_http | Remote data fetching | When data source is URL |
| simple_logger | Execution logging | When --verbose or debugging |
| simple_config | Configuration management | Complex config scenarios |

## Integration Patterns

### simple_chart Integration

**Purpose:** Core visualization engine for all chart types

**Usage:**
```eiffel
render_chart (a_config: CHART_CONFIG; a_data: DATA_SOURCE): STRING_32
    -- Generate chart from configuration and data.
  local
    l_chart: SIMPLE_CHART
    l_labels: ARRAYED_LIST [STRING]
    l_values: ARRAYED_LIST [REAL_64]
  do
    create l_chart.make
    l_labels := a_data.column_as_strings (a_config.label_column)
    l_values := a_data.column_as_numbers (a_config.value_column)

    inspect a_config.chart_type
    when Bar_chart then
      Result := l_chart.bar_chart (l_labels, l_values)
    when Line_chart then
      Result := l_chart.line_chart (l_values)
    when Sparkline then
      Result := l_chart.sparkline (l_values)
    when Scatter then
      Result := l_chart.scatter (a_data.x_values, a_data.y_values)
    when Histogram then
      Result := l_chart.histogram (l_values)
    end
  end
```

**Data flow:** Template defines chart spec -> DATA_SOURCE provides data -> SIMPLE_CHART renders -> Output includes rendered chart

### simple_template Integration

**Purpose:** Template variable substitution and section rendering

**Usage:**
```eiffel
apply_template (a_template: REPORT_TEMPLATE; a_data: DATA_SOURCE): STRING
    -- Apply data to template, substituting variables.
  local
    l_engine: SIMPLE_TEMPLATE
    l_context: HASH_TABLE [ANY, STRING]
  do
    create l_engine.make
    create l_context.make (10)

    -- Populate context with data aggregates
    l_context.put (a_data.sum ("amount"), "total_amount")
    l_context.put (a_data.row_count, "record_count")
    l_context.put (current_date_formatted, "report_date")

    l_engine.set_template (a_template.content)
    l_engine.set_context (l_context)
    Result := l_engine.render
  end
```

**Data flow:** Template string with {variables} -> Context with values -> Rendered content

### simple_pdf Integration

**Purpose:** Professional PDF report generation

**Usage:**
```eiffel
render_to_pdf (a_report: RENDERED_REPORT; a_path: STRING)
    -- Generate PDF from rendered report.
  local
    l_pdf: SIMPLE_PDF
    l_html: STRING
  do
    create l_pdf.make
    l_pdf.use_chrome  -- Use Edge/Chrome headless

    -- Build HTML with embedded charts (SVG)
    l_html := build_html_report (a_report)

    l_pdf.set_html (l_html)
    l_pdf.set_page_size ("letter")
    l_pdf.set_margins (72, 72, 72, 72)  -- 1 inch
    l_pdf.generate (a_path)
  ensure
    pdf_created: file_exists (a_path)
  end
```

**Data flow:** Rendered sections + charts -> HTML assembly -> PDF via Chrome/Edge

### simple_csv Integration

**Purpose:** Load and query CSV data files

**Usage:**
```eiffel
load_data (a_path: STRING): DATA_SOURCE
    -- Load CSV file into queryable data source.
  local
    l_loader: CSV_DATA_LOADER
  do
    create l_loader.make
    l_loader.load_from_file (a_path)

    if l_loader.has_data then
      create Result.make_from_csv (l_loader)
    else
      create Result.make_empty
      Result.set_error ("Failed to load: " + a_path)
    end
  ensure
    result_attached: Result /= Void
  end
```

### simple_scheduler Integration

**Purpose:** Schedule recurring report generation

**Usage:**
```eiffel
schedule_report (a_template_path: STRING; a_cron: STRING; a_email: STRING)
    -- Schedule report generation on cron schedule.
  local
    l_scheduler: SIMPLE_SCHEDULER
    l_job: SCHEDULER_JOB
  do
    create l_scheduler.make
    create l_job.make (a_cron)
    l_job.set_callback (agent generate_and_send (a_template_path, a_email))
    l_scheduler.add_job (l_job)
    l_scheduler.start
  end
```

## Dependency Graph

```
datareporter
    ├── simple_chart (required)
    │   ├── simple_csv
    │   ├── simple_json
    │   ├── simple_file
    │   ├── simple_cairo
    │   ├── simple_pdf
    │   └── simple_encoding
    ├── simple_template (required)
    │   └── simple_file
    ├── simple_cli (required)
    │   └── simple_file
    ├── simple_validation (required)
    │   └── simple_regex
    ├── simple_email (optional)
    │   └── simple_smtp
    ├── simple_scheduler (optional)
    │   └── simple_datetime
    ├── simple_http (optional)
    │   └── simple_json
    └── ISE base (required)
```

## ECF Configuration

```xml
<system name="datareporter" uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX">
    <target name="datareporter">
        <root class="DATAREPORTER_CLI" feature="make"/>
        <option warning="warning">
            <assertions precondition="true" postcondition="true" check="true" invariant="true"/>
        </option>
        <capability>
            <concurrency support="scoop"/>
            <void_safety support="all"/>
        </capability>

        <!-- ISE base -->
        <library name="base" location="$ISE_LIBRARY/library/base/base.ecf"/>
        <library name="time" location="$ISE_LIBRARY/library/time/time.ecf"/>

        <!-- Required simple_* -->
        <library name="simple_chart" location="$SIMPLE_EIFFEL/simple_chart/simple_chart.ecf"/>
        <library name="simple_csv" location="$SIMPLE_EIFFEL/simple_csv/simple_csv.ecf"/>
        <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
        <library name="simple_pdf" location="$SIMPLE_EIFFEL/simple_pdf/simple_pdf.ecf"/>
        <library name="simple_template" location="$SIMPLE_EIFFEL/simple_template/simple_template.ecf"/>
        <library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
        <library name="simple_validation" location="$SIMPLE_EIFFEL/simple_validation/simple_validation.ecf"/>

        <!-- Optional simple_* (uncomment as needed) -->
        <!-- <library name="simple_email" location="$SIMPLE_EIFFEL/simple_email/simple_email.ecf"/> -->
        <!-- <library name="simple_smtp" location="$SIMPLE_EIFFEL/simple_smtp/simple_smtp.ecf"/> -->
        <!-- <library name="simple_scheduler" location="$SIMPLE_EIFFEL/simple_scheduler/simple_scheduler.ecf"/> -->
        <!-- <library name="simple_http" location="$SIMPLE_EIFFEL/simple_http/simple_http.ecf"/> -->

        <cluster name="src" location="./src/" recursive="true"/>
    </target>

    <target name="datareporter_tests" extends="datareporter">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <cluster name="tests" location="./testing/" recursive="true"/>
    </target>
</system>
```

## Data Flow Summary

```
┌──────────────────────────────────────────────────────────────────────┐
│                         DataReporter Flow                             │
├──────────────────────────────────────────────────────────────────────┤
│                                                                       │
│   CSV/JSON ──► simple_csv/json ──► DATA_SOURCE                       │
│                                         │                             │
│   Template ──► simple_template ──► REPORT_TEMPLATE                   │
│                                         │                             │
│                    ┌────────────────────┴────────────────────┐       │
│                    ▼                                         ▼       │
│              REPORT_ENGINE                           CHART_CONFIG    │
│                    │                                         │       │
│                    ├─────────────────────────────────────────┤       │
│                    │          simple_chart                    │       │
│                    │   (bar, line, sparkline, scatter, etc.) │       │
│                    ├─────────────────────────────────────────┤       │
│                    ▼                                                  │
│              RENDERED_REPORT                                         │
│                    │                                                  │
│         ┌─────────┼─────────┬─────────┐                              │
│         ▼         ▼         ▼         ▼                              │
│     Text/CLI   SVG File  PDF File   Email                            │
│                         (simple_pdf) (simple_email)                  │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```
