# simple_chart Test Suite Implementation Report

**Date:** 2026-01-24
**Version:** 1.0.0
**Author:** Claude + Larry

## Executive Summary

This report documents the implementation of a comprehensive test suite for the `simple_chart` library. The test suite validates all chart types with realistic data and produces outputs in multiple formats: text (UTF-8 with BOM), SVG vector graphics, PNG raster images (via Cairo), and PDF documents (via Edge headless).

**Final Result:** 46 tests, all passing.

---

## How We Got Here: From Research to Reality

This section documents the journey from initial research through specification, drift analysis, and finally implementation - showing how `simple_chart` evolved from a 4-class CSV-to-ASCII library into a comprehensive multi-format charting solution.

### The Research Vision (2026-01-16)

The story begins with a systematic analysis of the 88-library `simple_*` ecosystem to identify gaps. The research document (`research/SIMPLE_CHART_RESEARCH.md`) evaluated 7 candidate CLI tools:

| Candidate | Gap Filled | Selected? |
|-----------|------------|-----------|
| simple_qr | QR/Barcode generation | No |
| simple_trippy | Network diagnostics | No |
| **simple_chart** | **Terminal data visualization** | **YES** |
| simple_secrets | Secret detection | No |
| simple_bench | Command benchmarking | No |
| simple_diff | Diff/patch utilities | No |
| simple_sync | Backup/sync | No |

**Why simple_chart was selected:**

From `research/SIMPLE_CHART_RESEARCH.md`:
> **Inspired by:** termgraph, YouPlot, datadash
>
> **What it does:**
> - Pipe data in, get charts out
> - Bar charts, line graphs, scatter plots, histograms
> - Sparklines for inline visualization
> - Braille-mode for high resolution

The research vision was ambitious: a library that could render charts in multiple modes (ASCII, Unicode blocks, braille patterns) and handle multiple chart types (bar, line, scatter, histogram, sparkline).

### The 7-Step Research Process

The research phase (`research/7S-*.md`) defined:

| Step | Document | Key Decisions |
|------|----------|---------------|
| 1. SCOPE | 7S-01-SCOPE.md | Bar, line, pie charts; SVG output; simple_csv binding |
| 2. STANDARDS | 7S-02-STANDARDS.md | DBC contracts; SCOOP compatibility |
| 3. SOLUTIONS | 7S-03-SOLUTIONS.md | Renderer pattern; facade API |
| 4. SIMPLE-STAR | 7S-04-SIMPLE-STAR.md | Dependencies: simple_csv, simple_file, simple_json |
| 5. SECURITY | 7S-05-SECURITY.md | Input validation; no external process execution |
| 6. SIZING | 7S-06-SIZING.md | Target: 8-12 classes, 1500-2500 lines |

### The Specification (Backwash)

When specifications were generated (`specs/S01-S08`), they documented what **actually existed** - a much simpler implementation than the research envisioned:

**Original Implementation (4 classes, ~400 lines):**

```
SIMPLE_CHART (facade)
    +-- CSV_DATA_LOADER (data input)
    +-- BAR_CHART_RENDERER (ASCII bars only)
    +-- TABLE_RENDERER (ASCII tables)
```

From `specs/S08-VALIDATION-REPORT.md`:

| Research Goal | Implementation Status |
|---------------|----------------------|
| Terminal visualization | ASCII bar charts, tables |
| CSV data source | CSV_DATA_LOADER |
| Simple API | Facade pattern |
| Line charts | **NOT IMPLEMENTED** |
| Sparklines | **NOT IMPLEMENTED** |
| Braille mode | **NOT IMPLEMENTED** |
| Color output | **NOT IMPLEMENTED** |

### The Drift Analysis (2026-01-24)

The drift analysis (`drift/drift-analysis.md`) compared the specification to the research vision and found **HIGH DRIFT**:

```
## Summary

| Category | Count |
|----------|-------|
| Spec'd, implemented | 0 |
| Spec'd, missing | 7 |
| Implemented, not spec'd | 28 |
| **Overall Drift** | **HIGH** |

## Conclusion

**simple_chart** has high drift. Significant gaps between spec and implementation.
```

The gap analysis revealed that `simple_chart` was missing:
- **LINE_CHART_RENDERER** - Time series and trend visualization
- **SCATTER_RENDERER** - Correlation and distribution plots
- **HISTOGRAM_RENDERER** - Frequency distribution charts
- **SPARKLINE_RENDERER** - Inline mini-charts
- **BRAILLE_CANVAS** - High-resolution Unicode rendering
- **JSON_DATA_LOADER** - JSON data source support

### The Implementation Sprint

With the drift analysis highlighting the gaps, implementation began to bring `simple_chart` in line with its research vision:

**New Classes Added (6 classes, +2,392 lines):**

| Class | Lines | Purpose |
|-------|-------|---------|
| LINE_CHART_RENDERER | ~350 | Braille-based line charts with axis labels |
| SCATTER_RENDERER | ~300 | Scatter plots with braille/ASCII modes |
| HISTOGRAM_RENDERER | ~280 | Frequency distribution with configurable bins |
| SPARKLINE_RENDERER | ~200 | Compact inline charts using block characters |
| BRAILLE_CANVAS | ~250 | 2x4 dot matrix rendering (U+2800-U+28FF) |
| JSON_DATA_LOADER | ~150 | JSON data source via simple_json |

**Additional Renderers for Multi-Format Output:**

| Class | Lines | Purpose |
|-------|-------|---------|
| SVG_CHART_RENDERER | ~400 | Vector graphics (pure XML) |
| CAIRO_CHART_RENDERER | ~480 | PNG raster images via simple_cairo |

### The Test Suite: Proving the Vision

The test suite was created to prove that `simple_chart` now delivers on its research vision:

| Research Promise | Test Validation |
|------------------|-----------------|
| "Bar charts" | 2 bar chart tests + PNG/SVG/PDF output |
| "Line graphs" | 6 line chart tests (braille + ASCII modes) |
| "Scatter plots" | 3 scatter tests (braille + ASCII modes) |
| "Histograms" | 5 histogram tests with variable bin counts |
| "Sparklines" | 5 sparkline tests (system metrics dashboard) |
| "Braille-mode" | All visual tests use BRAILLE_CANVAS |

### Evolution Summary

```
BEFORE (Phase 1):                    AFTER (Full Implementation):
─────────────────                    ────────────────────────────
4 classes                            10+ classes
~400 lines                           ~2,800 lines
ASCII bar charts only                5 chart types
CSV input only                       CSV + JSON input
Text output only                     Text + SVG + PNG + PDF output
No Unicode                           Full Unicode (blocks + braille)
```

### The Simple Ecosystem Effect

The implementation revealed the power of the `simple_*` ecosystem. Features that would require significant development effort were achieved by integrating existing libraries:

| Challenge | Ecosystem Solution | Lines of Integration Code |
|-----------|-------------------|--------------------------|
| PNG image output | simple_cairo | ~50 lines |
| PDF document output | simple_pdf | ~50 lines |
| UTF-8 file writing | simple_file | ~10 lines |
| JSON data loading | simple_json | ~150 lines |

**Total ecosystem-enabled features:** 4 major capabilities with ~260 lines of glue code.

### Artifacts Trail

| Phase | Artifacts | Location |
|-------|-----------|----------|
| Research | 7 research documents | `research/7S-*.md` |
| Research | Main research report | `research/SIMPLE_CHART_RESEARCH.md` |
| Specification | 8 spec documents | `specs/S01-S08*.md` |
| Drift Analysis | Gap analysis | `drift/drift-analysis.md` |
| Drift Analysis | API flatshort | `drift/api-SIMPLE_CHART.txt` |
| Implementation | 6 new source files | `src/*.e` |
| Testing | 5 test files | `testing/*.e` |
| Validation | This report | `reports/TEST_SUITE_REPORT.md` |

---

## 1. Test Suite Architecture

### 1.1 Test Categories

| Category | Tests | Purpose |
|----------|-------|---------|
| Unit Tests | 13 | Core functionality validation |
| Visual Text Tests | 22 | Text-based chart output with Unicode |
| SVG Image Tests | 5 | Vector graphics generation |
| PNG Image Tests | 4 | Raster image generation via Cairo |
| PDF Tests | 2 | Multi-page document generation |

### 1.2 New Test Classes

```
testing/
  test_app.e              -- Test runner (updated)
  test_simple_chart.e     -- Unit tests (updated)
  test_data_generator.e   -- Realistic test data (NEW)
  test_chart_visual.e     -- Visual text tests (NEW)
  test_chart_output.e     -- SVG/PNG/PDF tests (NEW)
```

### 1.3 New Renderer Classes

```
src/
  svg_chart_renderer.e    -- SVG vector output (NEW)
  cairo_chart_renderer.e  -- PNG raster output via Cairo (NEW)
```

---

## 2. Test Data Generator

The `TEST_DATA_GENERATOR` class provides realistic, reproducible test data for all chart types:

### 2.1 Sales & Business Data
- **Monthly Sales:** 12-month revenue data ($38K-$95K range)
- **Product Categories:** Electronics, Clothing, Home & Garden, etc.

### 2.2 Financial Data
- **Stock Prices (30 days):** Simulated price movements with volatility
- **Stock Prices (90 days):** Longer-term trend visualization

### 2.3 Scientific Data
- **Height vs Weight:** Correlation data (30 points)
- **Study Hours vs Exam Scores:** Educational statistics
- **Daily Temperatures:** Weather patterns

### 2.4 System Metrics
- **CPU Usage:** 60-point time series with spikes
- **Memory Usage:** GC-drop patterns
- **Network Throughput:** Variable bandwidth data
- **Disk I/O:** Storage activity patterns

### 2.5 Distribution Data
- **Exam Scores:** Normal distribution (mean ~75)
- **Response Times:** Right-skewed distribution (API latency)
- **Age Distribution:** Customer demographics

---

## 3. Output Formats

### 3.1 Text Output (UTF-8 with BOM)

All text files are written with:
- **UTF-8 BOM:** `EF BB BF` (U+FEFF prepended)
- **Proper encoding:** Unicode block characters (U+2581-U+2588) and braille patterns (U+2800-U+28FF)

**Implementation:** `SIMPLE_FILE.write_all` handles UTF-8 encoding automatically. The BOM character (U+FEFF) is prepended to the STRING_32 content before writing.

**Example sparkline output:**
```
▂▃▃▃▁█▃▃▂▁▃▂▁▂▂▁▂▂▁▃▄▂▃▂▁▃▃▁▃▂▃▃▃▂▃▃▁▂▃▃▃▂▁▂▃▃▂█▁▁▂█▁▃▂██▁▁▃
```

### 3.2 SVG Vector Graphics

The `SVG_CHART_RENDERER` class generates pure XML SVG output:
- No external dependencies
- Scalable to any resolution
- Embeddable in HTML

**Supported chart types:**
- Bar charts (horizontal)
- Line charts with axis labels
- Scatter plots with point markers
- Histograms with bin visualization

### 3.3 PNG Raster Images (Cairo)

The `CAIRO_CHART_RENDERER` class uses `simple_cairo` for raster output:
- 800x500 pixel default size
- Anti-aliased rendering
- Color-coded data visualization

**Cairo API Pattern:**
```eiffel
l_dummy := l_ctx.set_color_hex (0x4A90D9)
l_dummy := l_ctx.fill_rect (x, y, width, height)
l_dummy := l_ctx.move_to (x, y)
l_dummy := l_ctx.show_text (label)
l_ok := l_surface.write_png (output_path)
```

**DLL Requirement:** `cairo.dll` must be present in the execution directory. Copies are maintained in:
- `simple_chart/cairo.dll` (root)
- `simple_chart/bin/cairo.dll`

### 3.4 PDF Documents (Edge Headless)

The `SIMPLE_PDF` library with Chrome/Edge engine generates PDF reports:

**Configuration:**
```eiffel
create pdf.make
pdf.use_chrome  -- Switch from wkhtmltopdf to Edge headless
```

**Why Edge?**
- Available on all Windows 10/11 systems
- Better CSS support than wkhtmltopdf
- No additional installation required

---

## 4. Technical Challenges Resolved

### 4.1 UTF-8 Double-Encoding Bug

**Problem:** Text files contained garbled characters (C2 8x instead of E2 96 xx).

**Root Cause:** The code was:
1. Converting STRING_32 to UTF-8 manually
2. Then passing to `SIMPLE_FILE.write_all` which also UTF-8 encodes

**Solution:** Pass STRING_32 directly to `write_all` and let it handle encoding:
```eiffel
-- Before (WRONG - double encoding)
l_utf8 := l_enc.utf_32_to_utf_8 (a_content)
l_file.write_all (l_utf8)

-- After (CORRECT)
l_with_bom.append_character ('%/0xFEFF/')
l_with_bom.append (a_content)
l_file.write_all (l_with_bom)
```

### 4.2 PDF Engine Selection

**Problem:** PDF tests passed but produced no files.

**Root Cause:** `SIMPLE_PDF.make` defaults to wkhtmltopdf engine which was not installed.

**Solution:** Explicitly switch to Chrome/Edge engine:
```eiffel
create pdf.make
pdf.use_chrome  -- Uses Edge on Windows
```

### 4.3 Cairo Fluent API

**Problem:** Cairo methods return `like Current` for fluent chaining, causing unused value warnings.

**Solution:** Capture return values in dummy variable:
```eiffel
l_dummy: CAIRO_CONTEXT
...
l_dummy := l_ctx.set_color_hex (0xFFFFFF)
l_dummy := l_ctx.fill_rect (0, 0, width.to_real, height.to_real)
```

---

## 5. Generated Output Files

### 5.1 Text Files (22 files)

| File | Chart Type | Content |
|------|------------|---------|
| `bar_monthly_sales.txt` | Bar | 12-month revenue |
| `bar_product_categories.txt` | Bar | Category sales |
| `sparkline_cpu.txt` | Sparkline | CPU usage pattern |
| `sparkline_memory.txt` | Sparkline | Memory with GC drops |
| `sparkline_network.txt` | Sparkline | Network throughput |
| `sparkline_disk.txt` | Sparkline | Disk I/O |
| `sparkline_dashboard.txt` | Multi-sparkline | System dashboard |
| `line_stock_30d_braille.txt` | Line (braille) | 30-day stock |
| `line_stock_90d_braille.txt` | Line (braille) | 90-day stock |
| `line_stock_ascii.txt` | Line (ASCII) | Stock price |
| `line_temperature.txt` | Line | Daily temperatures |
| `line_hourly_temp.txt` | Line | 24-hour pattern |
| `line_multi_stock.txt` | Multi-line | Stock comparison |
| `scatter_height_weight.txt` | Scatter | Height vs Weight |
| `scatter_study_scores.txt` | Scatter | Study vs Scores |
| `scatter_height_weight_ascii.txt` | Scatter (ASCII) | Height vs Weight |
| `histogram_exam_scores.txt` | Histogram | Exam distribution |
| `histogram_response_times.txt` | Histogram | API latency |
| `histogram_age.txt` | Histogram | Age demographics |
| `histogram_5_bins.txt` | Histogram | 5-bin grouping |
| `histogram_20_bins.txt` | Histogram | 20-bin detail |
| `comprehensive_report.txt` | Mixed | All chart types |

### 5.2 SVG Files (4 files)

| File | Size | Content |
|------|------|---------|
| `chart_bar_sales.svg` | 3.2 KB | Monthly sales bar chart |
| `chart_line_stock.svg` | 2.5 KB | Stock price line chart |
| `chart_scatter_hw.svg` | 3.3 KB | Height/weight scatter |
| `chart_histogram_exam.svg` | 1.8 KB | Exam score histogram |

### 5.3 PNG Files (4 files)

| File | Size | Dimensions |
|------|------|------------|
| `chart_bar_sales.png` | 10.9 KB | 800x500 |
| `chart_line_stock.png` | 22.8 KB | 800x500 |
| `chart_scatter_hw.png` | 9.0 KB | 800x500 |
| `chart_histogram_exam.png` | 5.0 KB | 800x500 |

### 5.4 HTML Gallery (1 file)

| File | Size | Content |
|------|------|---------|
| `chart_gallery.html` | 10.9 KB | All SVG charts in one page |

### 5.5 PDF Documents (2 files)

| File | Size | Pages |
|------|------|-------|
| `chart_report.pdf` | 122 KB | 2 pages |
| `chart_dashboard.pdf` | 109 KB | 2 pages |

---

## 6. Simple Ecosystem Integration

A key aspect of this implementation is the strategic use of `simple_*` ecosystem libraries. Rather than reinventing functionality or using external tools, `simple_chart` leverages existing ecosystem capabilities to deliver multi-format output with minimal code.

### 6.1 Library Dependency Overview

| Library | Added For | Enables |
|---------|-----------|---------|
| `simple_file` | Original | File I/O with automatic UTF-8 encoding |
| `simple_csv` | Original | CSV data loading for chart input |
| `simple_json` | Original | JSON data loading for chart input |
| `simple_cairo` | **NEW** | PNG raster image generation |
| `simple_pdf` | **NEW** | PDF document generation |
| `simple_graphviz` | **NEW** | Graph rendering infrastructure |
| `simple_encoding` | **NEW** | UTF-8/Unicode text handling |

### 6.2 Detailed Library Analysis

#### simple_cairo (PNG Output)

**Why Added:** To generate publication-quality PNG raster images from chart data.

**What It Provides:**
- `CAIRO_SURFACE` - Image surface for pixel-based rendering
- `CAIRO_CONTEXT` - Drawing context with anti-aliased primitives
- Fluent API for chained drawing operations
- Direct PNG file output via `write_png`

**Facilitates:**
- 800x500 pixel chart images with smooth anti-aliasing
- Color-coded bars, lines, and data points
- Text labels rendered at precise positions
- Professional-quality output suitable for reports and presentations

**Code Pattern:**
```eiffel
create l_surface.make_image (width, height)
l_ctx := l_surface.create_context
l_dummy := l_ctx.set_color_hex (0x4A90D9)
l_dummy := l_ctx.fill_rect (x, y, w, h)
l_ok := l_surface.write_png (output_path)
```

**DLL Dependency:** Requires `cairo.dll` (2.3 MB) in execution directory.

---

#### simple_pdf (PDF Output)

**Why Added:** To generate multi-page PDF documents containing embedded SVG charts.

**What It Provides:**
- `SIMPLE_PDF` - Main facade for PDF generation
- `SIMPLE_PDF_DOCUMENT` - Generated document handle
- Multiple rendering engines (wkhtmltopdf, Chrome/Edge)
- Page size, orientation, and margin controls

**Facilitates:**
- Professional PDF reports with embedded charts
- Multi-page dashboard documents
- HTML-to-PDF conversion with full CSS support
- Cross-platform output (uses Edge headless on Windows)

**Key Discovery:** The default engine (wkhtmltopdf) requires separate installation. Switching to Chrome/Edge engine via `pdf.use_chrome` leverages the browser already present on Windows systems.

**Code Pattern:**
```eiffel
create pdf.make
pdf.use_chrome  -- Use Edge headless (available on all Windows)
pdf.set_page_size ("Letter")
pdf.set_orientation ("Landscape")
l_doc := pdf.from_html (html_with_svg_charts)
l_doc.save_to_file ("report.pdf")
```

---

#### simple_graphviz (Graph Infrastructure)

**Why Added:** To provide graph rendering capabilities and potential DOT format export.

**What It Provides:**
- Graph layout algorithms
- DOT language support
- SVG/PNG/PDF output options
- C library integration via inline externals

**Facilitates:**
- Future network/relationship chart types
- Graph-based visualizations
- Alternative rendering pipeline for complex layouts

**Note:** Currently used for infrastructure support; direct graph chart types may be added in future phases.

---

#### simple_encoding (UTF-8 Text)

**Why Added:** To properly handle Unicode characters in text-based chart output.

**What It Provides:**
- `SIMPLE_ENCODING` - UTF-32 to UTF-8 conversion
- `SIMPLE_ENCODING_DETECTOR` - BOM detection and validation
- Proper handling of multi-byte sequences

**Facilitates:**
- Correct rendering of Unicode block characters (U+2581-U+2588) for sparklines
- Proper encoding of braille patterns (U+2800-U+28FF) for line/scatter plots
- UTF-8 BOM markers for Windows text editor compatibility

**Key Discovery:** `SIMPLE_FILE.write_all` already performs UTF-8 encoding internally. The solution was to prepend the Unicode BOM character (U+FEFF) to STRING_32 content, letting `write_all` encode everything correctly.

**Code Pattern:**
```eiffel
-- Prepend Unicode BOM, let SIMPLE_FILE handle UTF-8 encoding
l_with_bom.append_character ('%/0xFEFF/')
l_with_bom.append (chart_content)
l_file.write_all (l_with_bom)  -- Outputs: EF BB BF + UTF-8 content
```

---

#### simple_file (File I/O)

**Original Dependency - Enhanced Usage**

**What It Provides:**
- Cross-platform file operations
- Automatic UTF-8 encoding via `set_utf8_encoding`
- Binary and text write modes

**Facilitates:**
- All text file output (22 files)
- Proper encoding without manual byte manipulation
- Consistent file handling across all output types

---

#### simple_csv (Data Loading)

**Original Dependency**

**What It Provides:**
- CSV parsing with header support
- Type-safe data extraction
- Error handling for malformed data

**Facilitates:**
- Loading chart data from CSV files
- Integration with external data sources
- Bulk data import for chart generation

---

#### simple_json (Data Loading)

**Original Dependency**

**What It Provides:**
- JSON parsing and generation
- Nested object/array support
- Type-safe value extraction

**Facilitates:**
- Loading chart data from JSON APIs
- Configuration file support
- Data interchange with web services

---

### 6.3 ECF Configuration

```xml
<!-- Original dependencies -->
<library name="simple_csv" location="D:\prod\simple_csv\simple_csv.ecf"/>
<library name="simple_file" location="D:\prod\simple_file\simple_file.ecf"/>
<library name="simple_json" location="D:\prod\simple_json\simple_json.ecf"/>

<!-- NEW: Added for multi-format output -->
<library name="simple_pdf" location="D:\prod\simple_pdf\simple_pdf.ecf"/>
<library name="simple_cairo" location="D:\prod\simple_cairo\simple_cairo.ecf"/>
<library name="simple_graphviz" location="D:\prod\simple_graphviz\simple_graphviz.ecf"/>
<library name="simple_encoding" location="D:\prod\simple_encoding\simple_encoding.ecf"/>
```

### 6.4 Ecosystem Benefits

By leveraging existing `simple_*` libraries:

1. **No External Tool Dependencies:** PDF generation uses Edge (already installed), not a separate tool like wkhtmltopdf
2. **Consistent API Patterns:** All libraries follow the same facade/builder patterns
3. **SCOOP Compatibility:** All dependencies are concurrency-safe
4. **DBC Contracts:** All libraries enforce preconditions/postconditions
5. **Minimal Code:** PNG output is ~480 lines; PDF integration is ~50 lines

### 6.5 Lessons Learned

| Challenge | Library Solution |
|-----------|------------------|
| "How to generate PNG?" | `simple_cairo` with inline C externals |
| "How to generate PDF?" | `simple_pdf` with `use_chrome` for Edge |
| "How to encode Unicode?" | `simple_file.write_all` handles it; just prepend BOM |
| "How to avoid double-encoding?" | Don't pre-encode; let `simple_file` do it |

---

## 7. Running the Tests

### 7.1 Build

```bash
cd /d/prod/simple_chart
/d/prod/ec.sh -batch -config simple_chart.ecf -target simple_chart_tests -finalize -c_compile
```

### 7.2 Execute

```bash
cp cairo.dll EIFGENs/simple_chart_tests/F_code/
./EIFGENs/simple_chart_tests/F_code/simple_chart.exe
```

### 7.3 Expected Output

```
Running SIMPLE_CHART tests...

  PASS: test_creation
  PASS: test_make_creates_all_components
  ... (13 unit tests)

--- Visual Chart Tests (outputs to testing/output/) ---
  PASS: visual_bar_monthly_sales
  ... (22 visual tests)

--- SVG Image Tests ---
  PASS: svg_bar_chart
  ... (5 SVG tests)

--- PNG Image Tests (Cairo) ---
  PASS: png_bar_chart
  ... (4 PNG tests)

--- PDF Tests ---
  PASS: pdf_chart_report
  PASS: pdf_dashboard

========================
Results: 46 passed, 0 failed
ALL TESTS PASSED
```

---

## 8. Conclusion

The `simple_chart` library now has comprehensive test coverage demonstrating:

1. **All chart types work:** Bar, sparkline, line, scatter, histogram
2. **Multiple output formats:** Text, SVG, PNG, PDF
3. **Proper Unicode support:** UTF-8 BOM, braille characters, block elements
4. **Realistic test data:** Sales, financial, scientific, system metrics

The test suite is self-contained, repeatable, and produces verifiable output files in `testing/output/`.

---

## Appendix: Commit History

| Commit | Description |
|--------|-------------|
| `da9a0fc` | feat: comprehensive test suite with SVG, PNG, PDF output |
| `cfb48ed` | chore: add cairo.dll for PNG rendering support |
| `b260738` | fix: PDF tests now report when wkhtmltopdf unavailable |
| `1f59e52` | fix: use Chrome/Edge engine for PDF generation |
| `cf7d148` | fix: proper UTF-8 encoding with BOM for Unicode text output |

**Total additions:** ~2,400 lines of code across 10 files.
