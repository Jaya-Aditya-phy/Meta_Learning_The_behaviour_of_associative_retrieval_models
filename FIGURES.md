# Figure guide

Each command writes its figures to `outputs/<command>/`. The demo gallery in the README shows what they look like on the
synthetic benchmark. A page-per-figure explanation (purpose, how it was made, how to read it, numbers, caveats) is in
[`figure_report/figure_report.tex`](figure_report/figure_report.tex); compile it with `pdflatex` after copying the PNGs from
`outputs/` into a `figs/` folder next to it.

| Figure | Command | What it shows | Suggested use |
|---|---|---|---|
| 1 `fig1_neff_heatmap` | `bridge` | `n_eff` over the (k, beta) grid | supporting |
| 2 `fig2_collapse` | `bridge` | accuracy, calibration, entropy against `n_eff` | main / hero |
| 3 `fig3_entropy_vs_neff` | `bridge` | entropy vs `n_eff` (near-definitional) | appendix |
| 4 `fig4_variance_law` | `bridge` | a failed MSE = b + c/`n_eff` law | negative result |
| 5 `fig5_nested_cv` | `nested` | honest vs optimistic accuracy; which settings were chosen | main |
| 6 `fig6_scaling_law` | `scaling` | `n_eff` and the best beta vs training size | optional |
| 7 `fig7_recalibration` | `recalibrate` | where the uncertainty fails; corrections | main |
| 8 `fig8_correction_scaling` | `correction-scaling` | corrections vs training size | supporting |
| 9 `fig9_neff_policy` | `neff-policy` | target-`n_eff` vs grid search | supporting |
| 10 `fig10_density_landscape` | `landscape` | density, prediction, `n_eff`, energy maps | supporting |
| 11 `fig11_energy_surface_3d` | `landscape` | 3-D energy surface | illustrative |
| 12 `fig12_physical_grounding` | `grounding` | behaviour vs physical variables | limitation |
