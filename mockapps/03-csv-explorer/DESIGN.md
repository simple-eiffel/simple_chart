# CSVExplorer CLI - Technical Design

## Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      CSVExplorer CLI                         │
├─────────────────────────────────────────────────────────────┤
│  CLI Interface Layer                                         │
│    - Argument parsing (simple_cli)                          │
│    - Command routing (info, stats, chart, filter, export)   │
│    - Output formatting (table, json, csv)                   │
├─────────────────────────────────────────────────────────────┤
│  Analysis Engine Layer                                       │
│    - Type inference and detection                            │
│    - Statistical calculations                                │
│    - Data profiling                                          │
│    - Pattern recognition                                     │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                  │
│    - CSV parsing (simple_csv)                                │
│    - Streaming for large files                               │
│    - Filtering and sorting                                   │
│    - Sampling                                                │
├─────────────────────────────────────────────────────────────┤
│  Output Layer                                                │
│    - Terminal rendering (tables, charts)                     │
│    - PDF export                                              │
│    - JSON/CSV output                                         │
└─────────────────────────────────────────────────────────────┘
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| CSVEXPLORER_CLI | Command-line entry point | parse_args, execute, format_output |
| CSV_ANALYZER | Core analysis engine | analyze, profile, suggest_charts |
| TYPE_INFERRER | Column type detection | infer_type, validate_type |
| STATS_CALCULATOR | Statistical computations | mean, median, stddev, quartiles, mode |
| DATA_PROFILER | Quality and pattern analysis | completeness, uniqueness, patterns |
| DATA_FILTER | Query and filter operations | where, sort, limit, select |
| TABLE_FORMATTER | Terminal table output | auto_width, truncate, align |
| CHART_SUGGESTER | Recommend appropriate charts | based on data types and cardinality |
| PDF_EXPORTER | Report generation | summary with charts |

### Command Structure

```bash
csvexplorer <command> [options] <file>

Commands:
  info         Quick overview (rows, columns, types, size)
  stats        Statistical summary for numeric columns
  profile      Data quality profile (nulls, uniques, patterns)
  chart        Generate visualization
  filter       Query and filter data
  head         First N rows (like head but formatted)
  tail         Last N rows
  sample       Random sample of rows
  columns      List columns with types
  values       Unique values for a column
  export       Export filtered data or report

Global Options:
  --format FORMAT   Output format: table|json|csv|pdf (default: table)
  --columns COLS    Comma-separated column names or indices
  --no-header       File has no header row
  --delimiter CHAR  Field delimiter (default: ,)
  --quiet           Minimal output
  --help            Show help

Examples:
  csvexplorer info data.csv                    # Quick overview
  csvexplorer stats data.csv                   # Statistics for all numeric
  csvexplorer stats data.csv --columns sales   # Specific column
  csvexplorer chart data.csv --type bar --x name --y value
  csvexplorer filter data.csv "sales > 1000"   # Filter rows
  csvexplorer filter data.csv "region = 'West'" --sort sales
  csvexplorer profile data.csv --format pdf    # Quality report
```

### Data Flow

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  CSV File   │───>│   Parser    │───>│  Analyzer   │───>│  Formatter  │
│             │    │ (simple_csv)│    │  (stats,    │    │  (table,    │
│             │    │             │    │   types)    │    │   chart)    │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
                          │                  │
                          ▼                  ▼
                   ┌─────────────┐    ┌─────────────┐
                   │  Streaming  │    │  Type       │
                   │  (large     │    │  Inference  │
                   │   files)    │    │             │
                   └─────────────┘    └─────────────┘
```

### Type Inference

```
┌─────────────────────────────────────────────────────────────┐
│                    Type Detection                            │
├─────────────────────────────────────────────────────────────┤
│  INTEGER    - All values match ^\d+$                        │
│  DECIMAL    - All values match ^\d+\.\d+$                   │
│  DATE       - ISO format, common date patterns              │
│  DATETIME   - Date + time patterns                          │
│  BOOLEAN    - true/false, yes/no, 1/0                       │
│  EMAIL      - Email pattern                                  │
│  URL        - HTTP/HTTPS pattern                            │
│  CATEGORY   - Low cardinality (<20 unique in sample)        │
│  TEXT       - Everything else                               │
└─────────────────────────────────────────────────────────────┘
```

### Statistical Summary Output

```
╔══════════════════════════════════════════════════════════════╗
║  Column: sales (DECIMAL)                                      ║
╠══════════════════════════════════════════════════════════════╣
║  Count:        1,234        Missing:      12 (0.97%)         ║
║  Unique:       892          Duplicates:   342                ║
╠══════════════════════════════════════════════════════════════╣
║  Mean:         $1,234.56    Std Dev:      $456.78            ║
║  Median:       $1,100.00    Mode:         $999.00            ║
║  Min:          $12.50       Max:          $9,876.00          ║
╠══════════════════════════════════════════════════════════════╣
║  Quartiles:    Q1=$650  Q2=$1,100  Q3=$1,800                 ║
╠══════════════════════════════════════════════════════════════╣
║  Distribution:  ▂▄▆█▇▅▃▂▁▁                                   ║
║                 $0   $2k  $4k  $6k  $8k  $10k                ║
╚══════════════════════════════════════════════════════════════╝
```

### Profile Output

```
╔══════════════════════════════════════════════════════════════╗
║  Data Quality Profile: sales_data.csv                         ║
║  Rows: 1,234 | Columns: 8 | Size: 156 KB                     ║
╠══════════════════════════════════════════════════════════════╣
║  Column          Type       Complete   Unique    Pattern      ║
╠══════════════════════════════════════════════════════════════╣
║  id              INTEGER    100%       100%      Sequential   ║
║  name            TEXT       100%       89%       -            ║
║  email           EMAIL      98%        100%      Valid        ║
║  sales           DECIMAL    99%        72%       -            ║
║  region          CATEGORY   100%       5 values  -            ║
║  date            DATE       95%        34%       YYYY-MM-DD   ║
║  active          BOOLEAN    100%       2 values  true/false   ║
║  notes           TEXT       45%        23%       -            ║
╠══════════════════════════════════════════════════════════════╣
║  Quality Score: 87%                                           ║
║  Warnings:                                                    ║
║    - 'notes' column 55% empty                                 ║
║    - 'date' has 5% missing values                             ║
╚══════════════════════════════════════════════════════════════╝
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| File not found | Abort | "File not found: {path}" |
| Invalid CSV | Show parse error | "Parse error at line {n}: {detail}" |
| Invalid column | Suggest similar | "Column 'salse' not found. Did you mean 'sales'?" |
| Invalid filter | Show syntax help | "Filter syntax error: {detail}. Example: column > 100" |
| Large file | Offer sampling | "File is 2GB. Use --sample 10000 for faster analysis." |
| Out of memory | Stream mode | "Switching to streaming mode for large file." |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **TUI Browser** - Interactive navigation with vim-like keys
   - Shared: CSV_ANALYZER, DATA_FILTER, all formatters
   - New: simple_tui integration, cursor navigation

2. **Web Interface** - Browser-based exploration
   - Shared: Entire analysis engine
   - New: simple_http server, HTML/JS frontend

3. **Jupyter Integration** - Notebook-friendly output
   - Shared: Analysis engine, JSON output
   - New: IPython magic commands

**Separation of concerns ensures:**
- Analysis logic is completely decoupled from display
- Same statistics in any frontend
- Export formats work everywhere
