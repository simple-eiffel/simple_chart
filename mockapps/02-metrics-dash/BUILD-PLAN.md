# MetricsDash CLI - Build Plan

## Phase Overview

| Phase | Deliverable | Dependencies |
|-------|-------------|--------------|
| Phase 1 | MVP - GitHub Actions metrics display | simple_chart, simple_http, simple_json, simple_cli |
| Phase 2 | Multi-platform + DORA + caching | Phase 1 + simple_sql, simple_cache, simple_datetime |
| Phase 3 | Alerts, PDF export, scheduling | Phase 2 + simple_pdf, simple_email, simple_scheduler |

---

## Phase 1: MVP

### Objective

Connect to GitHub Actions API, fetch workflow runs for a repository, calculate basic metrics (build duration, success rate), and display as terminal charts.

### Deliverables

1. **METRICSDASH_CLI** - Entry point with `show` command
2. **GITHUB_CONNECTOR** - GitHub Actions API integration
3. **METRICS_ENGINE** - Basic metric calculations
4. **DASHBOARD_RENDERER** - Terminal output with simple_chart
5. **Configuration loading** - API token from config file

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T1.1 | Create project structure and ECF | Compiles with all required libraries |
| T1.2 | Implement config file loading | Reads ~/.metricsdash.json, extracts GitHub token |
| T1.3 | Implement GITHUB_CONNECTOR | Fetches /actions/runs, parses response |
| T1.4 | Implement BUILD_RECORD normalization | Creates typed records from API JSON |
| T1.5 | Implement METRICS_ENGINE basics | Calculates avg duration, success rate |
| T1.6 | Implement DASHBOARD_RENDERER | Formats metrics table with sparklines |
| T1.7 | Implement METRICSDASH_CLI | Parses `show --project NAME` command |
| T1.8 | Handle API errors gracefully | Auth failures, rate limits, network errors |
| T1.9 | Write unit tests | Mock API responses, test calculations |

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| Config loading | Valid config file | Token extracted |
| GitHub API call | Valid token + repo | JSON array of runs |
| Metric calculation | 10 builds, 8 success | 80% success rate |
| Duration average | [60, 120, 90, 150] | 105 seconds |
| Sparkline render | 7 days of durations | Unicode sparkline |
| Invalid token | Bad token | Clear error message |
| No builds | Empty repo | "No builds found" message |

### Sample Usage (Phase 1)

```bash
# Configure GitHub token
metricsdash config set github.token ghp_xxxxx

# Add a project
metricsdash config add-project myorg/myrepo --alias myapp

# Show metrics
metricsdash show --project myapp

# Show with chart
metricsdash show --project myapp --format chart
```

---

## Phase 2: Full Implementation

### Objective

Add multi-platform support (GitLab, Jenkins), implement full DORA metrics, add persistent caching, and enable historical trend analysis.

### Deliverables

1. **GITLAB_CONNECTOR** - GitLab CI API integration
2. **JENKINS_CONNECTOR** - Jenkins API integration
3. **DORA_CALCULATOR** - Four DORA metrics computation
4. **METRICS_CACHE** - SQLite-based persistence
5. **TREND_ANALYZER** - Historical trend calculations
6. **`trend` command** - Historical visualization
7. **`compare` command** - Project/branch comparison

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T2.1 | Implement GITLAB_CONNECTOR | Fetches pipelines and jobs |
| T2.2 | Implement JENKINS_CONNECTOR | Fetches builds and queue |
| T2.3 | Implement DEPLOYMENT_RECORD | Track deployment events |
| T2.4 | Implement DORA_CALCULATOR | All 4 metrics calculated correctly |
| T2.5 | Create SQLite schema | builds, deployments, metrics tables |
| T2.6 | Implement METRICS_CACHE | Store and retrieve historical data |
| T2.7 | Implement TREND_ANALYZER | Moving averages, anomaly detection |
| T2.8 | Implement `trend` command | Line charts of metric history |
| T2.9 | Implement `compare` command | Side-by-side metrics comparison |
| T2.10 | Add `--period` option | Filter by time range |
| T2.11 | Implement response caching | Reduce API calls with TTL cache |
| T2.12 | Write integration tests | Full flow with cached data |

### DORA Metric Calculations

```
Deployment Frequency = deployments_count / period_days
Lead Time for Changes = avg(deploy_time - commit_time)
Change Failure Rate = failed_deploys / total_deploys
Mean Time to Recovery = avg(recovery_time - incident_start)
```

### Test Cases

| Test | Input | Expected Output |
|------|-------|-----------------|
| GitLab connector | Valid project ID | Pipeline data |
| Jenkins connector | Valid job name | Build data |
| DORA: Deploy freq | 7 deploys in 7 days | 1.0/day |
| DORA: Lead time | Commits + deploys | Hours/minutes |
| Cache storage | 100 builds | All stored in SQLite |
| Cache retrieval | Query last 30 days | Filtered results |
| Trend analysis | 30 days of data | Moving average line |
| Compare projects | 2 projects | Side-by-side table |

### Sample Usage (Phase 2)

```bash
# Show full DORA metrics
metricsdash show --project myapp --dora

# Historical trend
metricsdash trend --project myapp --metric build_duration --period 30

# Compare branches
metricsdash compare myapp:main myapp:develop

# Add GitLab project
metricsdash config add-project gitlab:123 --platform gitlab --alias backend
```

---

## Phase 3: Production Polish

### Objective

Add alerting, PDF report export, email notifications, and production hardening.

### Deliverables

1. **ALERT_MANAGER** - Threshold monitoring and notifications
2. **PDF_EXPORTER** - Professional PDF reports
3. **EMAIL_NOTIFIER** - Alert delivery via email
4. **Background sync** - Periodic data collection
5. **Comprehensive help** - Full documentation

### Tasks

| Task | Description | Acceptance Criteria |
|------|-------------|---------------------|
| T3.1 | Implement ALERT_MANAGER | Define thresholds, check violations |
| T3.2 | Implement `alert` command | Set, list, remove alerts |
| T3.3 | Implement alert checking | Run on every sync/show |
| T3.4 | Implement PDF_EXPORTER | Generate report with charts |
| T3.5 | Implement EMAIL_NOTIFIER | Send alert emails |
| T3.6 | Implement background sync | Optional daemon mode |
| T3.7 | Add rate limit handling | Exponential backoff |
| T3.8 | Improve error messages | Actionable suggestions |
| T3.9 | Write man page / --help | Complete documentation |
| T3.10 | Performance optimization | Parallel API calls |

### Sample Usage (Phase 3)

```bash
# Set alert threshold
metricsdash alert set build_time --threshold 300 --project myapp

# Set DORA alert
metricsdash alert set deployment_frequency --threshold 1 --operator "<" --period week

# List alerts
metricsdash alert list

# Generate PDF report
metricsdash show --project myapp --period 30 --format pdf --output report.pdf

# Configure email notifications
metricsdash config set alerts.email ops@company.com

# Start background sync (daemon mode)
metricsdash sync --daemon --interval 15
```

---

## ECF Target Structure

```xml
<!-- Library target (reusable core) -->
<target name="metricsdash_lib">
    <root all_classes="true"/>
    <library name="simple_chart" location="..."/>
    <library name="simple_http" location="..."/>
    <library name="simple_json" location="..."/>
    <library name="simple_sql" location="..."/>
    <library name="simple_cache" location="..."/>
    <cluster name="src" location="./src/" recursive="true">
        <file_rule>
            <exclude>/cli$</exclude>
        </file_rule>
    </cluster>
</target>

<!-- CLI executable target -->
<target name="metricsdash" extends="metricsdash_lib">
    <root class="METRICSDASH_CLI" feature="make"/>
    <library name="simple_cli" location="..."/>
    <cluster name="cli" location="./src/cli/" recursive="true"/>
</target>

<!-- Test target -->
<target name="metricsdash_tests" extends="metricsdash_lib">
    <root class="TEST_APP" feature="make"/>
    <library name="simple_testing" location="..."/>
    <library name="simple_mock" location="..."/>
    <cluster name="tests" location="./testing/" recursive="true"/>
</target>
```

## Build Commands

```bash
# Compile CLI
ec.exe -batch -config metricsdash.ecf -target metricsdash -c_compile

# Compile CLI (finalized)
ec.exe -batch -config metricsdash.ecf -target metricsdash -finalize -c_compile

# Run tests (with mock HTTP)
ec.exe -batch -config metricsdash.ecf -target metricsdash_tests -c_compile
./EIFGENs/metricsdash_tests/W_code/metricsdash.exe
```

## Success Criteria

| Criterion | Measure | Target |
|-----------|---------|--------|
| Compiles | Zero errors | 100% |
| Tests pass | All tests | 100% |
| API coverage | Platforms supported | GitHub, GitLab, Jenkins |
| DORA accuracy | Correct calculations | Verified against manual |
| Response time | Cached query | < 500ms |
| Response time | Fresh API call | < 3s |
| Documentation | README + man page | Complete |

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| API rate limits | Aggressive caching, backoff |
| API changes | Abstract connector layer, version pinning |
| Large data volumes | Pagination, incremental sync |
| Token security | Store in OS keychain (future) |
