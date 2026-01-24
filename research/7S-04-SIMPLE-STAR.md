# 7S-04: SIMPLE-STAR INTEGRATION - simple_chart

**Library**: simple_chart
**Date**: 2026-01-23
**Status**: RESEARCH

## Ecosystem Position

simple_chart is a **utility library** for data visualization.

## Dependencies (Inbound)

| Library | Usage |
|---------|-------|
| simple_csv | Data input from CSV files |
| simple_file | SVG file output |
| ISE time | Time-series axis formatting |

## Dependents (Outbound)

| Library | How It Uses simple_chart |
|---------|-------------------------|
| simple_report | Embed charts in reports |
| simple_dashboard | Visual components |

## Integration Patterns

### Data from CSV
```eiffel
local
    chart: SIMPLE_BAR_CHART
    csv: SIMPLE_CSV
do
    csv.load ("sales.csv")
    create chart.make_from_csv (csv, "Month", "Revenue")
    chart.save_svg ("sales_chart.svg")
end
```

### Ecosystem Conventions

1. **Naming**: SIMPLE_CHART prefix, chart type suffix
2. **Fluent API**: Builder pattern for configuration
3. **Contracts**: Validate data before rendering
