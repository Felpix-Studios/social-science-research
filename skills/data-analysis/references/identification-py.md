# Identification Diagnostics — Python Track

Run the design-specific diagnostics referees expect to see *for the design being claimed*. Mandatory for any analysis with a causal interpretation.

Detect the design from the analysis goal and the model call:
- `PanelOLS(..., entity_effects=True, time_effects=True)` with treatment timing → **DiD / event study**
- `rdrobust` Python port → **RDD**
- `IV2SLS(...)` → **IV**
- `pysyncon` → **Synthetic control**
- Random assignment or experiment data → **RCT / OLS with exogenous treatment**
- `causalinference`, propensity-score weighting → **Matching / propensity score**

Ask once if ambiguous. Multiple designs → run all relevant blocks.

Save diagnostic figures to `output/diagnostics/` and numerical results to `.pkl` or `.parquet`.

## DiD / event study

- Event-study coefficients with 95% CI from `linearmodels.PanelOLS` interaction terms — plot leads and lags
- Staggered timing: `differences::ATTgt` (Callaway-Sant'Anna port) or `pyfixest` Sun-Abraham; compare to the TWFE headline
- Manual Goodman-Bacon decomposition when TWFE is headline
- Placebo outcome / placebo period

## RDD

- `rdrobust` Python port: `rdrobust.rddensity(X, c=cutoff)` — report McCrary-type t and p
- `rdrobust.rdbwselect(...)` for bandwidth; re-estimate at 0.5×, 1×, 2×
- Donut-hole sensitivity
- Covariate balance at cutoff

## IV

- `linearmodels.IV2SLS(...).fit()` — first-stage F via `results.first_stage` / `results.diagnostics`
- Anderson-Rubin weak-IV-robust CI when F < 100 (manual or via `linearmodels` Wald tools)
- Over-identification: Sargan/Hansen J from the results object
- Reduced form alongside 2SLS

## Synthetic control

- `pysyncon` for in-space placebo permutation
- Pre-period RMSPE comparison
- In-time placebo
- Donor weights

## RCT / OLS with exogenous treatment

- Balance table per covariate (t-tests via `scipy.stats.ttest_ind` or `stargazer`)
- Randomization inference via `numpy.random.permutation` loop
- Attrition summary if relevant

## Matching

- Standardized mean differences pre/post via `causalinference` or manual computation
- Common support plot
- Sensitivity to caliper
