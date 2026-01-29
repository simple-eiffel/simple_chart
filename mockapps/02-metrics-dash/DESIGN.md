# MetricsDash CLI - Technical Design

## Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      MetricsDash CLI                         │
├─────────────────────────────────────────────────────────────┤
│  CLI Interface Layer                                         │
│    - Argument parsing (simple_cli)                          │
│    - Command routing (show, trend, compare, alert)          │
│    - Output formatting (table, chart, json, pdf)            │
├─────────────────────────────────────────────────────────────┤
│  Metrics Engine Layer                                        │
│    - Metric collection and aggregation                       │
│    - DORA metric calculations                                │
│    - Trend analysis                                          │
│    - Threshold alerting                                      │
├─────────────────────────────────────────────────────────────┤
│  Data Layer                                                  │
│    - CI/CD platform connectors                               │
│    - Local cache (SQLite via simple_sql)                    │
│    - Data normalization                                      │
├─────────────────────────────────────────────────────────────┤
│  Integration Layer                                           │
│    - simple_chart (visualization)                            │
│    - simple_http (API calls)                                 │
│    - simple_json (response parsing)                          │
│    - simple_cache (response caching)                         │
└─────────────────────────────────────────────────────────────┘
```

### Class Design

| Class | Responsibility | Key Features |
|-------|----------------|--------------|
| METRICSDASH_CLI | Command-line entry point | parse_args, execute, format_output |
| METRICS_ENGINE | Core aggregation logic | collect, aggregate, calculate_dora |
| CI_CONNECTOR | Abstract CI platform interface | fetch_builds, fetch_deployments |
| GITHUB_CONNECTOR | GitHub Actions integration | API calls, response parsing |
| GITLAB_CONNECTOR | GitLab CI integration | API calls, response parsing |
| JENKINS_CONNECTOR | Jenkins integration | API calls, response parsing |
| METRICS_CACHE | Local data storage | store, retrieve, expire |
| DORA_CALCULATOR | DORA metrics computation | deployment_freq, lead_time, mttr, cfr |
| TREND_ANALYZER | Historical analysis | moving_average, regression, anomaly |
| ALERT_MANAGER | Threshold monitoring | check, notify, history |
| DASHBOARD_RENDERER | Terminal visualization | render_summary, render_chart |
| PDF_EXPORTER | Report generation | export_report |

### Command Structure

```bash
metricsdash <command> [options] [arguments]

Commands:
  show         Display current metrics for project(s)
  trend        Show historical trends
  compare      Compare metrics between projects/branches
  alert        Manage alerting thresholds
  config       Configure CI connections
  sync         Force sync data from CI platforms

Global Options:
  --config FILE     Configuration file (default: ~/.metricsdash.json)
  --project NAME    Filter to specific project
  --format FORMAT   Output format: table|chart|json|pdf (default: table)
  --period DAYS     Time period for analysis (default: 7)
  --quiet           Minimal output
  --verbose         Detailed output
  --help            Show help

Examples:
  metricsdash show                           # Summary of all projects
  metricsdash show --project myapp           # Single project metrics
  metricsdash trend --project myapp --period 30   # 30-day trend
  metricsdash compare myapp-main myapp-staging    # Branch comparison
  metricsdash alert set build_time --threshold 300 --project myapp
```

### Metric Types

```
┌─────────────────────────────────────────────────────────────┐
│                      DORA Metrics                            │
├─────────────────────────────────────────────────────────────┤
│  Deployment Frequency  - How often code reaches production  │
│  Lead Time for Changes - Time from commit to production     │
│  Mean Time to Recovery - Time to restore from incidents     │
│  Change Failure Rate   - % of deployments causing failures  │
├─────────────────────────────────────────────────────────────┤
│                    Build Metrics                             │
├─────────────────────────────────────────────────────────────┤
│  Build Duration        - Average build time                  │
│  Build Success Rate    - % of builds that pass               │
│  Queue Time            - Time waiting before build starts    │
│  Test Coverage         - Code coverage % (if reported)       │
├─────────────────────────────────────────────────────────────┤
│                   Pipeline Metrics                           │
├─────────────────────────────────────────────────────────────┤
│  Stage Duration        - Time per pipeline stage             │
│  Retry Rate            - % of jobs requiring retry           │
│  Flaky Test Rate       - Tests that intermittently fail      │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

```
┌────────────┐    ┌────────────┐    ┌────────────┐    ┌────────────┐
│  CI/CD API │───>│ Connector  │───>│   Cache    │───>│   Engine   │
│  (GitHub,  │    │  (fetch,   │    │  (SQLite)  │    │ (aggregate │
│   GitLab)  │    │  normalize)│    │            │    │  analyze)  │
└────────────┘    └────────────┘    └────────────┘    └────────────┘
                                                            │
                                                            ▼
                                                     ┌────────────┐
                                                     │  Renderer  │
                                                     │ (chart,    │
                                                     │  table,    │
                                                     │  pdf)      │
                                                     └────────────┘
```

### Configuration Schema

```json
{
  "metricsdash": {
    "default_period": 7,
    "cache_ttl_minutes": 15,
    "platforms": {
      "github": {
        "token": "ghp_xxxx",
        "projects": [
          {"owner": "myorg", "repo": "myapp", "alias": "myapp"}
        ]
      },
      "gitlab": {
        "url": "https://gitlab.company.com",
        "token": "glpat-xxxx",
        "projects": [
          {"id": 123, "alias": "backend"}
        ]
      }
    },
    "alerts": {
      "build_time": {"threshold": 300, "operator": ">"},
      "success_rate": {"threshold": 0.95, "operator": "<"},
      "deployment_freq": {"threshold": 1, "operator": "<", "period": "week"}
    },
    "output": {
      "default_format": "table",
      "chart_width": 60,
      "use_braille": true
    }
  }
}
```

### Terminal Output Example

```
╔══════════════════════════════════════════════════════════════╗
║                    MetricsDash Summary                        ║
║                    Period: Last 7 days                        ║
╠══════════════════════════════════════════════════════════════╣
║ Project: myapp                                                ║
╠══════════════════════════════════════════════════════════════╣
║ DORA Metrics                                                  ║
║   Deployment Frequency:  3.4/day      [████████░░]  ELITE    ║
║   Lead Time for Changes: 2.1 hours    [█████████░]  ELITE    ║
║   Change Failure Rate:   4.2%         [████████░░]  HIGH     ║
║   Mean Time to Recovery: 45 min       [███████░░░]  HIGH     ║
╠══════════════════════════════════════════════════════════════╣
║ Build Metrics                                                 ║
║   Average Duration:      4m 32s       ▂▃▄▅▆▅▄▃▂▃ (trend)     ║
║   Success Rate:          96.2%        [█████████░]           ║
║   Queue Time:            12s avg                              ║
╠══════════════════════════════════════════════════════════════╣
║ Alerts: 1 active                                              ║
║   ⚠ build_time exceeded threshold (was 312s, limit 300s)     ║
╚══════════════════════════════════════════════════════════════╝
```

### Error Handling

| Error Type | Handling | User Message |
|------------|----------|--------------|
| API authentication failure | Clear credential prompt | "GitHub token invalid or expired. Run: metricsdash config" |
| API rate limiting | Exponential backoff + cache | "Rate limited. Using cached data (15 min old)" |
| Network timeout | Retry with backoff | "Connection timeout. Retrying..." |
| No data for period | Informative message | "No builds found in last 7 days for 'myapp'" |
| Invalid project | Suggest corrections | "Project 'myap' not found. Did you mean 'myapp'?" |
| Cache corruption | Rebuild cache | "Cache corrupted. Rebuilding..." |

## GUI/TUI Future Path

**CLI foundation enables:**

1. **TUI Dashboard** - Live-updating terminal dashboard
   - Shared: All connectors, METRICS_ENGINE, DORA_CALCULATOR
   - New: simple_tui integration, live refresh loop

2. **Web Dashboard** - Browser-based metrics view
   - Shared: Entire engine and connector layer
   - New: simple_http server, HTML/JS frontend

3. **Slack/Teams Integration** - Chat-based metrics
   - Shared: Engine, formatters
   - New: Webhook handlers, message formatting

**Separation of concerns ensures:**
- API connectors are reusable across any UI
- Cache layer provides consistent data regardless of frontend
- Metric calculations are identical everywhere
