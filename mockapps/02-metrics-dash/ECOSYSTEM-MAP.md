# MetricsDash CLI - Ecosystem Integration

## simple_* Dependencies

### Required Libraries

| Library | Purpose | Integration Point |
|---------|---------|-------------------|
| simple_chart | Metric visualization (sparklines, bars, trends) | DASHBOARD_RENDERER |
| simple_json | API response parsing, config files | All connectors, config |
| simple_http | CI/CD API communication | CI_CONNECTOR subclasses |
| simple_cli | Command-line argument parsing | METRICSDASH_CLI |
| simple_file | Config and cache file operations | METRICS_CACHE, config |
| simple_cache | API response caching | Reduce API calls |
| simple_sql | Local metrics storage (SQLite) | METRICS_CACHE persistence |

### Optional Libraries

| Library | Purpose | When Needed |
|---------|---------|-------------|
| simple_pdf | PDF report generation | When --format pdf used |
| simple_email | Alert notifications | When email alerts configured |
| simple_scheduler | Periodic sync jobs | For background data collection |
| simple_logger | Execution logging | When --verbose or debugging |
| simple_datetime | Time calculations | DORA metric periods |
| simple_math | Statistical calculations | Trend analysis, averages |

## Integration Patterns

### simple_chart Integration

**Purpose:** Visualize metrics as terminal charts and sparklines

**Usage:**
```eiffel
render_trend_sparkline (a_values: ARRAYED_LIST [REAL_64]): STRING_32
    -- Render metric trend as inline sparkline.
  local
    l_chart: SIMPLE_CHART
  do
    create l_chart.make
    Result := l_chart.sparkline (a_values)
  ensure
    result_attached: Result /= Void
  end

render_metric_bar (a_value, a_max: REAL_64; a_width: INTEGER): STRING
    -- Render single metric as progress bar.
  local
    l_chart: SIMPLE_CHART
    l_labels: ARRAYED_LIST [STRING]
    l_values: ARRAYED_LIST [REAL_64]
  do
    create l_chart.make
    l_chart.bar_renderer.set_bar_width (a_width)
    create l_labels.make (1)
    l_labels.extend ("")
    create l_values.make (1)
    l_values.extend (a_value)
    Result := l_chart.bar_chart (l_labels, l_values)
  end

render_build_duration_trend (a_builds: LIST [BUILD_RECORD]): STRING_32
    -- Render build duration as line chart.
  local
    l_chart: SIMPLE_CHART
    l_durations: ARRAYED_LIST [REAL_64]
  do
    create l_chart.make
    l_chart.set_braille_mode (True)
    create l_durations.make (a_builds.count)
    across a_builds as b loop
      l_durations.extend (b.duration_seconds)
    end
    Result := l_chart.line_chart (l_durations)
  end
```

**Data flow:** CI API -> Normalized metrics -> Chart rendering -> Terminal display

### simple_http Integration

**Purpose:** Fetch data from CI/CD platform APIs

**Usage:**
```eiffel
fetch_github_workflows (a_owner, a_repo: STRING): JSON_ARRAY
    -- Fetch workflow runs from GitHub Actions API.
  local
    l_http: SIMPLE_HTTP
    l_response: HTTP_RESPONSE
    l_url: STRING
  do
    create l_http.make
    l_http.set_header ("Authorization", "Bearer " + github_token)
    l_http.set_header ("Accept", "application/vnd.github.v3+json")

    l_url := "https://api.github.com/repos/" + a_owner + "/" + a_repo + "/actions/runs"
    l_response := l_http.get (l_url)

    if l_response.is_success then
      Result := parse_workflow_runs (l_response.body)
    else
      create Result.make_empty
      last_error := "GitHub API error: " + l_response.status_code.out
    end
  end
```

**Data flow:** API URL -> HTTP GET -> JSON response -> Parsed data

### simple_sql Integration

**Purpose:** Persistent local cache of metrics data

**Usage:**
```eiffel
cache_build_metrics (a_project: STRING; a_builds: LIST [BUILD_RECORD])
    -- Store build metrics in local SQLite database.
  local
    l_db: SIMPLE_SQL
    l_stmt: STRING
  do
    create l_db.make ("~/.metricsdash/cache.db")

    across a_builds as b loop
      l_stmt := "INSERT OR REPLACE INTO builds (project, build_id, started_at, duration, status) VALUES (?, ?, ?, ?, ?)"
      l_db.execute_with_params (l_stmt, <<a_project, b.id, b.started_at, b.duration, b.status>>)
    end

    l_db.close
  end

query_build_history (a_project: STRING; a_days: INTEGER): LIST [BUILD_RECORD]
    -- Retrieve cached build data for project.
  local
    l_db: SIMPLE_SQL
    l_cutoff: DATE_TIME
  do
    create l_db.make ("~/.metricsdash/cache.db")
    l_cutoff := now - a_days.days

    Result := l_db.query_as (
      "SELECT * FROM builds WHERE project = ? AND started_at > ? ORDER BY started_at",
      <<a_project, l_cutoff>>,
      agent build_from_row
    )

    l_db.close
  end
```

### simple_cache Integration

**Purpose:** Short-term API response caching to reduce API calls

**Usage:**
```eiffel
cached_api_call (a_url: STRING; a_ttl_minutes: INTEGER): STRING
    -- Execute API call with caching.
  local
    l_cache: SIMPLE_CACHE
    l_key: STRING
  do
    create l_cache.make
    l_key := hash_url (a_url)

    if l_cache.has (l_key) and not l_cache.is_expired (l_key, a_ttl_minutes) then
      Result := l_cache.get (l_key)
    else
      Result := execute_http_get (a_url)
      l_cache.put (l_key, Result, a_ttl_minutes)
    end
  end
```

## Dependency Graph

```
metricsdash
    ├── simple_chart (required)
    │   ├── simple_csv
    │   ├── simple_json
    │   └── simple_file
    ├── simple_http (required)
    │   └── simple_json
    ├── simple_cli (required)
    │   └── simple_file
    ├── simple_sql (required)
    │   └── simple_file
    ├── simple_cache (required)
    │   └── simple_file
    ├── simple_json (required)
    ├── simple_datetime (required)
    ├── simple_pdf (optional)
    │   └── simple_file
    ├── simple_email (optional)
    │   └── simple_smtp
    ├── simple_math (optional)
    └── ISE base (required)
```

## ECF Configuration

```xml
<system name="metricsdash" uuid="XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX">
    <target name="metricsdash">
        <root class="METRICSDASH_CLI" feature="make"/>
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
        <library name="simple_http" location="$SIMPLE_EIFFEL/simple_http/simple_http.ecf"/>
        <library name="simple_json" location="$SIMPLE_EIFFEL/simple_json/simple_json.ecf"/>
        <library name="simple_cli" location="$SIMPLE_EIFFEL/simple_cli/simple_cli.ecf"/>
        <library name="simple_sql" location="$SIMPLE_EIFFEL/simple_sql/simple_sql.ecf"/>
        <library name="simple_cache" location="$SIMPLE_EIFFEL/simple_cache/simple_cache.ecf"/>
        <library name="simple_file" location="$SIMPLE_EIFFEL/simple_file/simple_file.ecf"/>
        <library name="simple_datetime" location="$SIMPLE_EIFFEL/simple_datetime/simple_datetime.ecf"/>

        <!-- Optional simple_* -->
        <!-- <library name="simple_pdf" location="$SIMPLE_EIFFEL/simple_pdf/simple_pdf.ecf"/> -->
        <!-- <library name="simple_email" location="$SIMPLE_EIFFEL/simple_email/simple_email.ecf"/> -->
        <!-- <library name="simple_math" location="$SIMPLE_EIFFEL/simple_math/simple_math.ecf"/> -->

        <cluster name="src" location="./src/" recursive="true"/>
    </target>

    <target name="metricsdash_tests" extends="metricsdash">
        <root class="TEST_APP" feature="make"/>
        <library name="simple_testing" location="$SIMPLE_EIFFEL/simple_testing/simple_testing.ecf"/>
        <library name="simple_mock" location="$SIMPLE_EIFFEL/simple_mock/simple_mock.ecf"/>
        <cluster name="tests" location="./testing/" recursive="true"/>
    </target>
</system>
```

## API Integration Summary

### Supported Platforms

| Platform | API Version | Auth Method | Key Endpoints |
|----------|-------------|-------------|---------------|
| GitHub Actions | v3 | Bearer token | /actions/runs, /actions/workflows |
| GitLab CI | v4 | Private token | /projects/:id/pipelines, /projects/:id/jobs |
| Jenkins | Latest | Basic auth | /job/:name/api/json, /queue/api/json |
| CircleCI | v2 | Bearer token | /project/:slug/pipeline, /pipeline/:id/workflow |
| Azure DevOps | 6.0 | PAT | /_apis/build/builds, /_apis/release/releases |

### Data Normalization

All CI platforms normalize to common structures:

```eiffel
class BUILD_RECORD
feature
    id: STRING
    project: STRING
    branch: STRING
    commit_sha: STRING
    started_at: DATE_TIME
    finished_at: detachable DATE_TIME
    duration_seconds: REAL_64
    status: BUILD_STATUS  -- success, failed, canceled, running
    trigger: BUILD_TRIGGER  -- push, pr, schedule, manual
end

class DEPLOYMENT_RECORD
feature
    id: STRING
    project: STRING
    environment: STRING  -- production, staging, etc.
    deployed_at: DATE_TIME
    build_id: STRING
    status: DEPLOYMENT_STATUS
    rolled_back: BOOLEAN
end
```
