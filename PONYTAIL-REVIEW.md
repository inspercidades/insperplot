# Ponytail review log

Review date: 2026-10-04

| Finding | Issue | Resolution |
| --- | --- | --- |
| Default density plots build an empty layer because `bw = NULL` overrides ggplot2's default. | [#23](https://github.com/inspercidades/insperplot/issues/23) | Use `"nrd0"` by default and build the layer in tests. |
| Horizontal bar labels format the categorical `y` variable. | [#24](https://github.com/inspercidades/insperplot/issues/24) | Label the detected numeric value axis. |
| Filled bars display raw values instead of normalized shares. | [#22](https://github.com/inspercidades/insperplot/issues/22) | Calculate labels from the shares used by `position_fill()`. |
| Matrix heatmaps rely on base `%||%`, which requires R 4.4. | [#25](https://github.com/inspercidades/insperplot/issues/25) | Use explicit `NULL` fallbacks compatible with R 4.1. |
| Histogram and density plots advertise continuous fill mappings that ggplot2 drops. | [#26](https://github.com/inspercidades/insperplot/issues/26) | Reject continuous fill and keep discrete grouping. |
