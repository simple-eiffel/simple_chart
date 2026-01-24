# Drift Analysis: simple_chart

Generated: 2026-01-24
Method: `ec.exe -flatshort` vs `specs/*.md` + `research/*.md`

## Specification Sources

| Source | Files | Lines |
|--------|-------|-------|
| specs/*.md | 8 | 1437 |
| research/*.md | 7 | 574 |

## Classes Analyzed

| Class | Spec'd Features | Actual Features | Drift |
|-------|-----------------|-----------------|-------|
| SIMPLE_CHART | 7 | 28 | +21 |

## Feature-Level Drift

### Specified, Implemented ✓
- (none matched)

### Specified, NOT Implemented ✗
- `simple_bench` ✗
- `simple_chart` ✗
- `simple_diff` ✗
- `simple_qr` ✗
- `simple_secrets` ✗
- `simple_sync` ✗
- `simple_trippy` ✗

### Implemented, NOT Specified
- `Io`
- `Operating_environment`
- `author`
- `bar_renderer`
- `components_initialized`
- `conforms_to`
- `copy`
- `data_loader`
- `date`
- `default_rescue`
- ... and 18 more

## Summary

| Category | Count |
|----------|-------|
| Spec'd, implemented | 0 |
| Spec'd, missing | 7 |
| Implemented, not spec'd | 28 |
| **Overall Drift** | **HIGH** |

## Conclusion

**simple_chart** has high drift. Significant gaps between spec and implementation.
