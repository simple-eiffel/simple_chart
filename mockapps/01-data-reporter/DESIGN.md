# DataReporter CLI - Technical Design

## Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      DataReporter CLI                        │
├─────────────────────────────────────────────────────────────┤
│  CLI Interface Layer                                         │
│    - Argument parsing (simple_cli)                          │
│    - Command routing (generate, template, validate)         │
│    - Output formatting (text, json, quiet modes)            │
├─────────────────────────────────────────────────────────────┤
│  Report Engine Layer                                         │
│    - Template loading and parsing                            │
│    - Data binding and transformation                         │
│    - Chart generation orchestration                          │
│    - Section assembly                                        │
├─────────────────────────────────────────────────────────────┤
│  Output Layer                                                │
│    - Text/ASCII renderer                                     │
│    - SVG renderer                                            │
│    - PDF renderer                                            │
│    - Email delivery                                          │
├─────────────────────────────────────────────────────────────┤
│  Integration Layer                                           │
│    - simple_chart (all chart types)                         │
│    - simple_csv / simple_json (data loading)                │
│    - simple_template (template engine)                       │
│    - simple_pdf (PDF generation)                             │
│    - simple_email / simple_smtp (delivery)                   │
└─────────────────────────────────────────────────────────────┘
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| DATAREPORTER_CLI | Command-line interface | parse_args, execute, format_output |
| REPORT_ENGINE | Core report generation | load_template, bind_data, generate |
| REPORT_TEMPLATE | Template structure | sections, charts, metadata |
| REPORT_SECTION | Single report section | title, content, charts |
| DATA_SOURCE | Data abstraction | load, query, transform |
| CHART_CONFIG | Chart specification | type, columns, options |
| TEXT_RENDERER | ASCII/text output | render_to_string |
| SVG_RENDERER | Vector output | render_to_file |
| PDF_RENDERER | Document output | render_to_file |
| REPORT_SCHEDULER | Timed execution | schedule, run |
| EMAIL_DELIVERY | Report distribution | send, attach |

### Command Structure

```bash
datareporter <command> [options] [arguments]

Commands:
  generate     Generate report from template and data
  template     Create, edit, or validate templates
  schedule     Schedule recurring report generation
  send         Email a generated report
  validate     Validate data file against template requirements

Global Options:
  --config FILE     Configuration file (default: ~/.datareporter.json)
  --output FORMAT   Output format: text|svg|pdf (default: text)
  --quiet           Suppress progress output
  --verbose         Show detailed progress
  --help            Show help

Examples:
  datareporter generate sales-weekly.yaml --data sales.csv --output pdf
  datareporter template new monthly-kpi --type sales
  datareporter schedule sales-weekly.yaml --cron "0 9 * * MON" --email team@company.com
  datareporter validate quarterly.csv --template quarterly-report.yaml
```

### Data Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Data File  │───>│ Data Source │───>│   Report    │───>│   Output    │
│ (CSV/JSON)  │    │   Loader    │    │   Engine    │    │  Renderer   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                          │                  │                   │
                          ▼                  ▼                   ▼
                   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
                   │  Validate   │    │   Template  │    │  PDF/SVG/   │
                   │   Schema    │    │   + Charts  │    │    Text     │
                   └─────────────┘    └─────────────┘    └─────────────┘
```

### Template Schema

Templates define report structure in YAML:

```yaml
# sales-weekly.yaml
name: "Weekly Sales Report"
version: "1.0"

metadata:
  title: "Sales Performance - Week {week_number}"
  author: "Sales Team"
  date_format: "%B %d, %Y"

data_sources:
  sales:
    type: csv
    path: "{data_dir}/sales.csv"
    required_columns: [date, rep, amount, region]

sections:
  - title: "Executive Summary"
    type: text
    content: |
      Total sales this week: ${sum(sales.amount)}
      Top performer: ${max_by(sales, 'amount').rep}

  - title: "Sales by Representative"
    type: chart
    chart:
      type: bar
      data: sales
      labels: rep
      values: amount
      options:
        width: 60
        show_values: true

  - title: "Daily Trend"
    type: chart
    chart:
      type: line
      data: sales
      group_by: date
      aggregate: sum
      values: amount

  - title: "Regional Breakdown"
    type: table
    data: sales
    group_by: region
    columns: [region, count, total_amount, average]

output:
  pdf:
    page_size: letter
    margins: [1in, 1in, 1in, 1in]
  text:
    width: 80
  svg:
    width: 800
    height: 600
```

### Configuration Schema

```json
{
  "datareporter": {
    "default_output": "pdf",
    "data_dir": "./data",
    "template_dir": "./templates",
    "output_dir": "./reports",
    "branding": {
      "company_name": "Acme Corp",
      "logo_path": "./assets/logo.png",
      "primary_color": "#4a90d9"
    },
    "email": {
      "smtp_host": "smtp.company.com",
      "smtp_port": 587,
      "from_address": "reports@company.com"
    },
    "schedule": {
      "timezone": "America/New_York"
    }
  }
}
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| Missing data file | Abort with clear path | "Data file not found: {path}" |
| Invalid template | Validate before run | "Template error at line {n}: {detail}" |
| Missing required column | List required vs found | "Missing columns: {list}. Found: {found}" |
| Chart generation failure | Skip with warning | "Warning: Could not generate chart '{name}': {reason}" |
| Output write failure | Abort with suggestion | "Cannot write to {path}. Check permissions." |
| Email delivery failure | Retry, then report | "Email delivery failed after 3 attempts: {error}" |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **TUI Template Editor** - Interactive template creation with preview
   - Shared: REPORT_TEMPLATE, CHART_CONFIG classes
   - New: TUI navigation, live preview rendering

2. **Web Preview Interface** - Browser-based report preview
   - Shared: REPORT_ENGINE, all renderers
   - New: HTTP server, HTML wrapper

3. **Desktop Application** - Full GUI report builder
   - Shared: Entire engine layer
   - New: GUI framework integration

**Separation of concerns ensures:**
- Engine logic is 100% reusable
- Renderers work identically in any UI
- Templates are portable across interfaces
