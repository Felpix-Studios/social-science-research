# Identification Diagnostics — R Track

Run the design-specific diagnostics referees expect to see *for the design being claimed*. Mandatory for any analysis with a causal interpretation.

Detect the design from the analysis goal and the model call:
- `feols(... | id + t)` with treatment-timing → **DiD / event study**
- `rdrobust(...)` → **RDD**
- `feols(y ~ ... | 0 | endog ~ instr)` → **IV**
- `tidysynth::synthetic_control(...)` → **Synthetic control**
- Random assignment or experiment data → **RCT / OLS with exogenous treatment**
- `MatchIt`, `cobalt`, propensity-score weighting → **Matching / propensity score**

Ask once with AskUserQuestion only if the design is genuinely ambiguous. Multiple designs (e.g., DiD with IV robustness) → run all relevant blocks.

Save every diagnostic figure to `output/diagnostics/` and every numerical result to RDS for `/quality-gate` and `/write-paper` to consume.

## DiD / event study

- Pre-trends event-study coefficients with 95% CI via `fixest::iplot()` (or `ggiplot::ggiplot()`)
- If staggered timing: re-estimate with `fixest::feols(y ~ sunab(g, t) | id + t)`, `did::att_gt()` (Callaway-Sant'Anna), or `DIDmultiplegt::did_multiplegt_dyn()` (de Chaisemartin); compare to TWFE headline
- `bacondecomp::bacon()` when TWFE is the headline estimate
- Placebo outcome and/or placebo period when available

## RDD

- `rddensity::rddensity(X, c = cutoff)` for the McCrary-type density discontinuity test — report t-stat and p-value
- `rdrobust::rdbwselect(y, x, c)` for optimal bandwidth; re-estimate at 0.5×, 1×, 2× the optimal
- Donut-hole sensitivity: drop observations within ε of the cutoff and re-estimate
- Covariate balance at the cutoff using `rdrobust::rdrobust(z, x, c)` for each covariate z

## IV

- `fixest::feols(y ~ controls | fe | endog ~ instr)` — report the effective F via `fitstat(., "ivf1")`; Olea-Pflueger via `ivDiag::ivDiag()`
- Anderson-Rubin weak-IV-robust CI when F < 100 — `ivDiag::AR_test()` or `ivmodel::AR.test()`
- Over-identification (Hansen J) via `fixest::wald()` when instruments > 1
- Report the reduced-form coefficient alongside the 2SLS estimate

## Synthetic control

- `tidysynth::generate_placebos()` for in-space placebo permutation; plot treatment-vs-donor effect paths
- Pre-period RMSPE for treated unit vs distribution across donors
- In-time placebo if a clear pre-treatment cutoff exists
- Donor weights table

## RCT / OLS with exogenous treatment

- Balance table on pre-treatment covariates via `modelsummary::datasummary_balance(~ treat, data = df)`
- Randomization inference via `ri2::conduct_ri()` for the primary outcome
- CONSORT-style attrition summary if attrition > 5%

## Matching / propensity score

- Pre/post balance with standardized mean differences via `cobalt::bal.tab()`
- Common support plot
- Sensitivity to caliper width
