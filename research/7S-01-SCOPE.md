# 7S-01: SCOPE - simple_chart

**Library**: simple_chart
**Date**: 2026-01-23
**Status**: RESEARCH

## Problem Domain

Data visualization and charting for Eiffel applications - generating charts from data.

### What Problem Does This Solve?

1. **Data Visualization**: Create charts from numeric/categorical data
2. **Report Generation**: Charts for documents and reports
3. **Dashboard Components**: Visual elements for monitoring
4. **Export Formats**: SVG, PNG output for embedding

### Target Users

- Eiffel developers building data analysis tools
- Report generation applications
- Dashboard and monitoring systems
- Scientific visualization needs

### Use Cases

1. Generate bar charts from CSV data
2. Create line graphs for time series
3. Produce pie charts for categorical data
4. Export charts as SVG for web display

## Boundaries

### In Scope

- Bar charts (vertical, horizontal, stacked)
- Line charts (single, multi-series)
- Pie/donut charts
- SVG output format
- Data binding from simple_csv
- Basic styling (colors, labels, legends)

### Out of Scope

- Interactive charts (hover, click) - use web charting
- 3D charts
- Real-time streaming charts
- Complex statistical visualizations
- Animation

## Domain Vocabulary

| Term | Definition |
|------|------------|
| Series | A set of data points to plot |
| Axis | X or Y dimension of a chart |
| Legend | Key explaining chart colors/symbols |
| SVG | Scalable Vector Graphics output format |
