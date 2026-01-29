# DataReporter CLI - Build Plan

## Phase Overview

| Phase | Deliverable | Dependencies |
|-------|-------------|--------------|
| Phase 1 | MVP CLI - CSV to text report | simple_chart, simple_csv, simple_cli, simple_file |
| Phase 2 | Full output formats + templates | Phase 1 + simple_pdf, simple_template |
| Phase 3 | Scheduling + email delivery | Phase 2 + simple_scheduler, simple_email, simple_smtp |

---

## Phase 1: MVP

### Objective

Demonstrate core value: take a CSV file and a simple template, generate a text report with embedded ASCII charts. User can run one command and see immediate results.

### Deliverables

1. **DATAREPORTER_CLI** - Command-line entry point with `generate` command
2. **REPORT_ENGINE** - Core report generation logic
3. **DATA_SOURCE** - CSV data loading and querying
4. **TEXT_RENDERER** - ASCII/text output generation
5. **Basic template support** - Simple YAML parsing for chart definitions

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure and ECF | Compiles with simple_chart, simple_csv, simple_cli |
| T1.2 | Implement DATAREPORTER_CLI | Parses `generate` command with --data and --template args |
| T1.3 | Implement DATA_SOURCE for CSV | Loads CSV, provides column_as_strings, column_as_numbers |
| T1.4 | Implement basic REPORT_TEMPLATE | Parses YAML template with chart definitions |
| T1.5 | Implement REPORT_ENGINE | Orchestrates data loading, chart generation, assembly |
| T1.6 | Implement TEXT_RENDERER | Outputs formatted text with charts |
| T1.7 | Create sample templates | sales-simple.yaml, kpi-basic.yaml |
| T1.8 | Write unit tests | 15+ tests covering core functionality |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Load CSV | sales.csv with 10 rows | DATA_SOURCE with 10 records |
| Parse template | valid YAML template | REPORT_TEMPLATE with sections |
| Generate bar chart | labels + values | ASCII bar chart string |
| Generate sparkline | numeric values | Unicode sparkline string |
| Full report | CSV + template | Formatted text with charts |
| Missing file | non-existent.csv | Clear error message |
| Invalid template | malformed YAML | Parse error with line number |

### Sample Usage (Phase 1)

```bash
# Generate text report
datareporter generate --template sales-simple.yaml --data sales.csv

# Output to file
datareporter generate --template sales-simple.yaml --data sales.csv > report.txt

# Verbose mode
datareporter generate --template sales-simple.yaml --data sales.csv --verbose
```

---

## Phase 2: Full Implementation

### Objective

Add professional output formats (PDF, SVG) and full template engine with variable substitution, enabling business-ready reports.

### Deliverables

1. **PDF_RENDERER** - PDF output via simple_pdf
2. **SVG_RENDERER** - SVG chart output
3. **Enhanced REPORT_TEMPLATE** - Variables, expressions, conditionals
4. **REPORT_CONFIG** - Configuration file support
5. **CHART_CONFIG** - Full chart customization options
6. **template command** - Create and validate templates

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Implement PDF_RENDERER | Generates PDF with charts via Chrome/Edge |
| T2.2 | Implement SVG_RENDERER | Outputs individual chart SVGs |
| T2.3 | Integrate simple_template | Variable substitution in templates |
| T2.4 | Add expression support | ${sum(column)}, ${max(column)}, etc. |
| T2.5 | Implement REPORT_CONFIG | ~/.datareporter.json configuration |
| T2.6 | Add template command | `template new`, `template validate` |
| T2.7 | Add branding support | Logo, colors in PDF output |
| T2.8 | Add table rendering | Formatted data tables in reports |
| T2.9 | Write integration tests | Full pipeline tests with all outputs |
| T2.10 | Create template library | 10+ reusable templates |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Generate PDF | CSV + template | Valid PDF file with charts |
| Generate SVG | Chart config | Valid SVG file |
| Variable substitution | ${total_sales} | Replaced with calculated value |
| Expression evaluation | ${sum(amount)} | Correct sum |
| Config loading | ~/.datareporter.json | Settings applied |
| Template validation | valid template | "Template OK" |
| Template validation | invalid template | Specific errors listed |

### Sample Usage (Phase 2)

```bash
# Generate PDF report
datareporter generate --template sales-weekly.yaml --data sales.csv --output pdf

# Generate SVG charts
datareporter generate --template charts-only.yaml --data metrics.csv --output svg

# Create new template
datareporter template new monthly-kpi --type sales

# Validate template
datareporter validate sales-weekly.yaml
```

---

## Phase 3: Production Polish

### Objective

Add scheduling, email delivery, and production hardening for automated report workflows.

### Deliverables

1. **REPORT_SCHEDULER** - Cron-style scheduling
2. **EMAIL_DELIVERY** - SMTP delivery with attachments
3. **Error handling hardening** - Graceful failures, retries
4. **Logging integration** - Detailed execution logs
5. **Help documentation** - --help for all commands
6. **Configuration validation** - Full config schema checking

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement REPORT_SCHEDULER | Cron syntax, persistent jobs |
| T3.2 | Implement EMAIL_DELIVERY | Send with PDF attachment |
| T3.3 | Add retry logic | 3 retries on transient failures |
| T3.4 | Integrate simple_logger | Debug/info/error logging |
| T3.5 | Implement schedule command | `schedule add`, `schedule list`, `schedule remove` |
| T3.6 | Implement send command | Manual email send |
| T3.7 | Add config validation | Schema checking on load |
| T3.8 | Write man page / help | Comprehensive documentation |
| T3.9 | Performance optimization | Cache templates, batch operations |
| T3.10 | Security hardening | Sanitize inputs, secure credentials |

### Sample Usage (Phase 3)

```bash
# Schedule weekly report
datareporter schedule add --template sales-weekly.yaml --data /data/sales.csv \
  --cron "0 9 * * MON" --email "team@company.com" --output pdf

# List scheduled reports
datareporter schedule list

# Remove scheduled report
datareporter schedule remove sales-weekly

# Manual email send
datareporter send report.pdf --to "boss@company.com" --subject "Weekly Sales"
```

---

## ECF Target Structure

```xml
<!-- Library target (reusable core) -->
<target name="datareporter_lib">
    <root all_classes="true"/>
    <library name="simple_chart" location="..."/>
    <library name="simple_csv" location="..."/>
    <library name="simple_template" location="..."/>
    <!-- ... other libs ... -->
    <cluster name="src" location="./src/" recursive="true">
        <file_rule>
            <exclude>/cli$</exclude>
        </file_rule>
    </cluster>
</target>

<!-- CLI executable target -->
<target name="datareporter" extends="datareporter_lib">
    <root class="DATAREPORTER_CLI" feature="make"/>
    <library name="simple_cli" location="..."/>
    <cluster name="cli" location="./src/cli/" recursive="true"/>
</target>

<!-- Test target -->
<target name="datareporter_tests" extends="datareporter_lib">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="..."/>
    <cluster name="tests" location="./testing/" recursive="true"/>
</target>
```

## Build Commands

```bash
# Compile CLI (workbench for development)
ec.exe -batch -config datareporter.ecf -target datareporter -c_compile

# Compile CLI (finalized for release)
ec.exe -batch -config datareporter.ecf -target datareporter -finalize -c_compile

# Run tests
ec.exe -batch -config datareporter.ecf -target datareporter_tests -c_compile
./EIFGENs/datareporter_tests/W_code/datareporter.exe

# Install (copy to PATH)
cp ./EIFGENs/datareporter/F_code/datareporter.exe /usr/local/bin/
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All tests | 100% |
| CLI works | All commands functional | Yes |
| PDF output | Valid, viewable PDFs | Yes |
| Performance | Report generation < 5s | Yes |
| Documentation | README complete | Yes |
| Templates | 10+ included | Yes |

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| PDF quality issues | Use Chrome/Edge headless (proven path) |
| Template complexity | Start simple, add features incrementally |
| Schedule persistence | Use simple_file for JSON job storage |
| Email deliverability | Support SMTP auth, TLS |
