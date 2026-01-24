# 7S-03: SOLUTIONS - simple_chart

**Library**: simple_chart
**Date**: 2026-01-23
**Status**: RESEARCH

## Existing Solutions Comparison

### JavaScript Libraries

| Library | Strengths | Weaknesses | Relevance |
|---------|-----------|------------|-----------|
| D3.js | Extremely flexible | Complex API | Reference |
| Chart.js | Simple, balanced | Limited customization | Pattern |
| ECharts | High performance | Heavy | Reference |
| Highcharts | Easy to use | Commercial license | Pattern |

### Desktop Libraries

| Library | Platform | Notes |
|---------|----------|-------|
| matplotlib | Python | Industry standard |
| gnuplot | C/CLI | Scriptable |
| JFreeChart | Java | Mature |

### Eiffel Ecosystem

- No dedicated chart library exists
- simple_svg could be foundation (doesn't exist yet)
- EiffelVision2 has basic drawing but no charts

## Why simple_chart?

1. **No Eiffel alternative**: Gap in ecosystem
2. **SVG output**: Universal, scalable
3. **simple_csv integration**: Natural data source
4. **Contracts**: Self-documenting API

## Architecture Choice

Direct SVG generation:
- No external dependencies
- Portable output
- Simple implementation
- Easy to debug
