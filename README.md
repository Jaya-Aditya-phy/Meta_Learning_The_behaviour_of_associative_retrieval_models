# neff-retrieval

**Effective sample size as a control variable for accuracy and calibration in retrieval-based inverse inference.**

[![tests](https://github.com/YOUR_USERNAME/neff-retrieval/actions/workflows/tests.yml/badge.svg)](https://github.com/YOUR_USERNAME/neff-retrieval/actions/workflows/tests.yml)
![python](https://img.shields.io/badge/python-3.10%2B-blue)
![status](https://img.shields.io/badge/status-research%20prototype-orange)

Many inverse problems are **many-to-one**: several causes produce similar observations, so a point estimate hides
ambiguity, and the reliability of any stated uncertainty is rarely examined. This repository studies a simple
retrieval regressor (a kNN-type estimator with a sharpness parameter β and a neighbour cutoff k) and asks one
question: *what is it doing inside when it answers, and can one number summarise that?*

The one number is the **effective sample size** `n_eff = 1 / Σ wᵢ²` (Kish's effective sample size, applied to the
retrieval weights). On the case study below, accuracy, error and interval coverage are better described as functions
of `n_eff` than of the two tuning knobs, and the accuracy optimum and the calibration optimum sit at very different
`n_eff`.

> **Status.** Research prototype. The empirical claims rest on **one dataset** (142 samples in 32 batches), and several
> intervals are wide. Negative and inconclusive results are reported alongside the positive ones
> (see [Limitations](#limitations-and-negative-results)).

## Install and try it in two minutes

```bash
git clone https://github.com/Jaya-Aditya-phy/Meta_Learning_The_behaviour_of_associative_retrieval_models
cd Meta_Learning_The_behaviour_of_associative_retrieval_models
pip install -e ".[dev]"
pytest                      # 14 tests, including a label-leakage check
neffretrieval demo          # runs the first two analyses on a synthetic benchmark (no data needed)
python examples/quickstart.py
```

## Use it on your own data

One row per sample; a numeric target, a grouping column (batch, subject, site, ...) and numeric feature columns:

```bash
neffretrieval bridge   --csv data.csv --target y --group batch              # n_eff as the bridge variable
neffretrieval nested   --csv data.csv --target conc --group batch --log10-target
neffretrieval recalibrate --csv data.csv --target y --group batch --features f1,f2,f3
neffretrieval grounding --csv data.csv --target y --group batch --physics-cols pe,ma --category-col material
```

The grouping column matters: every evaluation holds out **whole groups**, because that is the unit you want the
model to generalise across.

## The analysis layers

| Command | Question it answers | Main output |
|---|---|---|
| `bridge` | Do accuracy, calibration and entropy collapse onto `n_eff`? | `fig1`, `fig2` (hero), `fig3`, `fig4` |
| `nested` | How accurate is it, honestly, once the tuning is nested? | `fig5` |
| `recalibrate` | Where does the stated uncertainty fail, and do simple fixes work? Compared with plain and density-weighted kNN | `fig7` |
| `scaling` | How do `n_eff` and the best sharpness depend on training size? | `fig6` |
| `correction-scaling` | How much data do the corrections need? | `fig8` |
| `neff-policy` | Can one target `n_eff` replace the (k, β) grid search? | `fig9` |
| `landscape` | What does the model's density / energy landscape look like? | `fig10`, `fig11` |
| `grounding` | Does model behaviour track physical variables, or just data coverage? | `fig12` |

Definitions, formulas and validation details are in [`docs/METHODS.md`](docs/METHODS.md); a page-per-figure guide is
in [`docs/FIGURES.md`](docs/FIGURES.md) and [`docs/figure_report/`](docs/figure_report/).

## Results on the droplet case study

*Reported from the author's runs on 142 evaporated colloidal-droplet deposits from 32 experimental batches (a
40-dimensional morphology vector per deposit; target is log₁₀ of the glycerol-adjusted concentration). The
experimental data are **not distributed with this repository**; the demo reproduces the procedures on synthetic data.*

Nested leave-one-batch-out, settings chosen by an inner cross-validation on training batches only:

| Model | R² (95% CI, batch bootstrap) | Coverage of nominal 68% / 95% intervals |
|---|---|---|
| Global mean (floor) | −0.07 | 0.50 / 0.97 |
| Plain kNN | 0.79 [0.65, 0.87] | 0.51 / 0.68 |
| Density-weighted kNN | 0.79 [0.66, 0.87] | 0.49 / 0.74 |
| **Retrieval, accuracy setting** | **0.80** [0.67, 0.87] | 0.54 / 0.75 |
| **Retrieval, calibration setting** | 0.74 [0.60, 0.83] | **0.69 / 0.93** |

- **Accuracy is a tie.** Every paired R² difference between retrieval and the density-weighted kNN baseline has a
  confidence interval containing 0.
- **`n_eff` organises behaviour.** Predicting each diagnostic on held-out settings from `log n_eff` alone beats the
  two-knob `(log k, log β)` description despite using fewer parameters (accuracy 0.78 vs 0.52; coverage 0.97–0.98 vs 0.94–0.96).
- **Different optima.** Accuracy is best near `n_eff ≈ 6–7`; calibration near `n_eff ≈ 35–50`.
- **Overconfidence is concentrated at low `n_eff`** (95% coverage 0.61 and 0.71 in the two lowest `n_eff` quartiles, against 0.89 in the third).
- **Honest selection costs little.** Nested selection is within 0.013 R² of the optimistic best-of-grid value, and a
  one-dimensional search over a target `n_eff` matches the (k, β) grid.
- **Corrections need data.** Bias and width corrections fitted on fewer than about 50 training samples are unreliable
  and can make predictions worse; the calibration-tuned setting stays calibrated at every training size tested.

## Demo gallery (synthetic data)

*These figures come from `neffretrieval <command>` on the built-in synthetic benchmark, to show what each command
produces. They are not the case-study results above.*

| | |
|---|---|
| ![collapse](docs/figures/fig2_collapse.png) | ![nested](docs/figures/fig5_nested_cv.png) |
| `bridge`: diagnostics against `n_eff` | `nested`: honest vs optimistic accuracy |
| ![recalibration](docs/figures/fig7_recalibration.png) | ![policy](docs/figures/fig9_neff_policy.png) |
| `recalibrate`: where the uncertainty fails | `neff-policy`: one target instead of two knobs |

<details><summary>More demo figures</summary>

![scaling](docs/figures/fig6_scaling_law.png)
![correction scaling](docs/figures/fig8_correction_scaling.png)
![landscape](docs/figures/fig10_density_landscape.png)
![grounding](docs/figures/fig12_physical_grounding.png)
</details>

## Validation protocol

- **Group-level nested cross-validation.** The outer loop holds out one whole group; any tuned setting is chosen by an
  inner GroupKFold on the remaining groups only.
- **Everything data-dependent is fitted on training rows only**: scaling, median imputation, feature selection and the
  length scale. A unit test checks that corrupting a held-out group's labels leaves its predictions unchanged.
- **Uncertainty is judged by coverage**, not only by likelihood, because Gaussian NLL depends on the uncertainty floor.
- **Confidence intervals resample whole groups.** Differences between models use paired resampling.
- **Settings that were fixed after looking at the data are labelled** where they appear (for example the target `n_eff`
  values 7 and 35).

## Limitations and negative results

- **One dataset.** Generality is untested. A second case study (for example leaf-spectra retrieval of biochemistry) is the obvious next step.
- **Retrieval here is kNN-like**, so parity with kNN on accuracy is expected; the contribution is the analysis of its
  internal behaviour and the validation protocol, not a new predictor. `n_eff` itself is Kish's effective sample size.
- **Not supported:** a simple `MSE = b + c/n_eff` law; a `ln n` law for the best β as data grow (not resolvable with 32 batches).
- **The decay constant of `n_eff/n` depends on how distances are normalised**, so it is not a universal number.
- **Physical grounding is unresolved.** Only data coverage along the target was detectable; with 32 batches, associations
  below |ρ| ≈ 0.5 could not be resolved, and Péclet/Marangoni numbers were not tested.
- Corrected kNN interval coverage is a lower bound (the width factor is capped at 5).

## Repository layout

```
src/neffretrieval/
  retrieval.py          the retrieval model, leave-one-group-out helper
  bridge.py             n_eff as a bridge variable                    (command: bridge)
  nested.py             nested-CV selection policies                  (nested)
  recalibration.py      uncertainty diagnostics, corrections, baselines (recalibrate)
  scaling.py            n_eff law and best sharpness vs data size      (scaling)
  correction_scaling.py corrections vs data size                       (correction-scaling)
  neff_policy.py        target-n_eff selection                         (neff-policy)
  landscape.py          density / energy landscape maps                (landscape)
  grounding.py          model behaviour vs physical variables          (grounding)
  data.py, cli.py       synthetic benchmark, CSV loader, command line
tests/                  pytest suite (14 tests)
examples/quickstart.py  minimal usage
docs/                   methods, results, figure guide, LaTeX figure report
```

## Citation

If you use this code, please cite it (see [`CITATION.cff`](CITATION.cff)).

## Data and acknowledgements

The case-study data come from an ongoing experimental project and are not included. Kish's effective sample size and
the kNN / kernel-regression literature on which this builds are credited in [`docs/METHODS.md`](docs/METHODS.md).

