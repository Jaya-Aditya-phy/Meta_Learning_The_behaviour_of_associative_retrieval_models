# Methods

## Model
Features are median-imputed and standardised on the training set. Optionally, features whose |Pearson correlation|
with the target (training rows only) is below a threshold are dropped, and survivors are weighted equally.
Retrieval weights over the `k` nearest stored samples are

    w_i = exp(-beta * d_i / s) / sum_j exp(-beta * d_j / s)

with `d_i` the Euclidean distance in the processed space and `s` the median nearest-neighbour distance of the
training set (so `beta` is dimensionless). The prediction is `yhat = sum_i w_i y_i` and the uncertainty is the
weighted spread `sigma = sqrt(sum_i w_i (y_i - yhat)^2)`, floored at a fraction (default 5%) of the training label spread.
`beta -> infinity` recovers 1-NN and `beta = 0` the global mean.

## Effective sample size
`n_eff = 1 / sum_i w_i^2 = Z(1)^2 / Z(2)`, with `Z(b) = sum_i exp(b * l_i)` and `l_i = -beta d_i / s`. It satisfies
`1 <= n_eff <= k`: `k` for equal votes, 1 when a single sample takes all the weight. This is Kish's effective sample size
for normalised weights. It equals `exp(H_2)`, where `H_2` is the order-2 Renyi entropy of the weights; since
`H_2 <= H_1` (Shannon), `ln n_eff <= H`, so the entropy-`n_eff` relationship is close to definitional and is not
treated as independent evidence.

## Metrics
`R^2` and MAE on the (log) target, pooled over held-out groups. `z = (yhat - y) / sigma`. Coverage-68/95 is the share of
true values with `|z| <= 1` or `<= 1.96`. Gaussian NLL is `mean(0.5 ln(2 pi sigma^2) + (yhat - y)^2 / (2 sigma^2))`
and depends on the uncertainty floor, so coverage is reported first.

## Validation
Leave-one-group-out (outer). Tuned settings are chosen by an inner GroupKFold on the outer-training groups only.
Confidence intervals resample whole groups (1000 resamples); paired differences resample the same groups for both models.

## Selection policies (`nested`)
`accuracy`: lowest inner MSE. `accuracy_1se`: among settings within one standard error of the best inner MSE, the one
with the largest `n_eff`. `calibration`: lowest inner NLL. `legacy_raw`: inner MSE computed on the raw (un-logged)
scale while the outer score is on the log scale, kept as an explicit record of a scoring-mismatch bug.

## Target-n_eff policy (`neff-policy`)
For each training set the mean `n_eff` is computed on an 80-point grid of `ln beta`, querying every training sample
against samples of **other groups only** (no labels, no test data). For a target `t` in {3, 5, 7, 10, 15, 25, 35, 50} the
`beta` giving `n_eff = t` is interpolated. All voters are allowed (`k` unrestricted).

## Corrections (`recalibrate`)
Fitted on inner out-of-fold predictions of the chosen setting. *Sigma:* one factor `s = sqrt(mean z^2)` clipped to
[0.5, 5] multiplies every `sigma`. *Bias:* a line `y ~ a + b * yhat`.

## Scaling (`scaling`, `correction-scaling`)
Training groups are subsampled to 20-100%. `n_eff/n` is fitted as `A exp(-c beta)` over points with `n_eff >= 2`.
Two length scales are compared: *adaptive* (the training set's own nearest-neighbour distance, which shrinks with
`n`) and *fixed* (that distance measured on a fixed-size reference sample).

## Grounding (`grounding`)
Per-sample behaviours (n_eff at an accuracy and a calibration setting, the local decay constant, isolation from the
stored samples, error, |z|) are averaged per group and rank-correlated with group-level physical variables. 95% CIs
resample groups, permutation p-values use 5000 permutations, and Holm correction is applied across all pairs. The
minimum detectable |rho| at 80% power is `tanh((z_{0.975} + z_{0.8}) / sqrt(n - 3))`, about 0.48 for 32 groups.

## References to credit
- L. Kish (1965), *Survey Sampling*: design effect and effective sample size.
- Nadaraya (1964) and Watson (1964): kernel regression; softmax-weighted retrieval is a Nadaraya-Watson estimator.
- Ramsauer et al. (2020), *Hopfield Networks is All You Need*: modern Hopfield retrieval as softmax attention.
