# Results on the droplet case study

142 evaporated colloidal-droplet deposits, 32 experimental batches, 40-dimensional morphology vector, target
`log10` of the glycerol-adjusted concentration. The data are not distributed with this repository. All numbers are
from nested leave-one-batch-out runs unless stated.

## Accuracy
| Method | R^2 | 95% CI |
|---|---|---|
| Global mean | -0.066 | [-0.231, -0.064] |
| Best fixed setting (optimistic; k=9, beta=2) | 0.812 | [0.680, 0.881] |
| Retrieval, nested accuracy | 0.798 | [0.665, 0.871] |
| Retrieval, nested accuracy + 1-SE | 0.775 | [0.636, 0.850] |
| Retrieval, nested calibration | 0.742 | [0.597, 0.831] |
| Plain kNN | 0.790 | [0.649, 0.866] |
| Density-weighted kNN (log-space scoring) | 0.792 | [0.663, 0.866] |
| Density-weighted kNN (its own raw-space scoring) | 0.821 | [0.704, 0.883] |

Selection optimism (best fixed setting minus nested accuracy): +0.013. Paired differences between retrieval and the
density-weighted kNN: -0.022 [-0.073, +0.019] against its own scoring; +0.006 [-0.048, +0.058] against log-space scoring.

## Calibration
| Model | raw cov68 / cov95 | after one width factor | factor |
|---|---|---|---|
| Retrieval, accuracy setting | 0.54 / 0.75 | 0.87 / 0.94 | 3.1 |
| Retrieval, calibration setting | 0.69 / 0.93 | 0.67 / 0.93 | 1.0 |
| Plain kNN | 0.51 / 0.68 | 0.86 / 0.94 | 4.6 (near cap) |
| Density-weighted kNN | 0.49 / 0.74 | 0.85 / 0.95 | 4.7 (near cap) |

By `n_eff` quartile for the accuracy setting (mean `n_eff`; cov68 / cov95): Q1 (3.7) 0.42 / 0.61; Q2 (5.0) 0.46 / 0.71;
Q3 (7.4) 0.69 / 0.89; Q4 (14.3) 0.61 / 0.78.

## The `n_eff` bridge (grouped CV of predicting each diagnostic)
| Diagnostic | from `log n_eff` | from `(log k, log beta)` |
|---|---|---|
| R^2 | 0.78 | 0.52 |
| MAE | 0.83 | 0.63 |
| NLL | 0.93 | 0.82 |
| mean z^2 | 0.93 | 0.83 |
| cov68 | 0.97 | 0.96 |
| cov95 | 0.98 | 0.94 |

## One-dimensional selection
Target-`n_eff` policies match the (k, beta) grid on accuracy and calibration (paired differences -0.017 to +0.010, all CIs
containing 0). A fixed `n_eff = 35` gives coverage 0.70 / 0.94 with no correction; a fixed `n_eff = 7` gives R^2 0.805.
The fixed targets came from earlier analysis of the same data (mild optimism).

## Effect of training size
`n_eff/n` decays about exponentially in beta over the moderate range (c = 0.40 with the adaptive length scale, 0.27 with
a fixed one; R^2 0.80-0.86). `n_eff` at the accuracy optimum is about 7 with no detectable trend. A `ln n` law for the best
beta was not resolvable. Corrections fitted on fewer than ~50 training samples are unreliable; the calibration-tuned
setting stays calibrated (coverage 0.90-0.96) from about 40 samples up; R^2 is still rising at the largest size.

## Physical grounding
Batch-level isolation from the stored samples rises with concentration (rho = +0.78, 95% CI [0.57, 0.92], Holm p = 0.002), a
data-coverage effect (concentration is the target). No association with glycerol content (0-10%) was detectable; with 32
batches the minimum detectable |rho| is about 0.48. Peclet and Marangoni numbers and particle type were not tested.
