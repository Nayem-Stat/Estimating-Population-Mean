# Reproducibility check

The original analysis scripts were rerun (R 4.x, seed 965, M = 2,500 replications), and their output was
compared with the published paper. `R/ci_estimators.R` reproduces that output exactly.

## What reproduces exactly

| Paper item | Result |
|---|---|
| Table 3.1: Normal(10, 7) | ✅ every coverage and width matches |
| Table 3.2: Beta(10, 0.3), skewness −3 | ✅ matches |
| Table 3.4: Lognormal(1, 0.8), skewness 3.6 | ✅ matches |
| Table 3.6: long-jump data | ✅ all 23 intervals match |
| Table 3.5: psychotropic-drug data | ⚠️ the code is correct, but some table cells were mistyped (see below) |
| Data summaries (Section 3.5) | ✅ psychotropic: mean 42.37, SD 48.43, skew 1.57; long jump: mean 7.6745, SD 0.37, skew −1.16 |

## Issues found in the published tables (possible erratum)

### 1. DMSD-t coverage reports MAD-T3 coverage

In the original simulation scripts, the returned table has `CP_DMSD_t = coverage_probability16`, which is the index
of **MAD T3**; the correct index is 19. So the DMSD-t *coverage* rows in Tables 3.1–3.4 repeat the MAD-T3 coverage.
The DMSD-t widths are correct. You can see the error in the paper's own numbers: DMSD-t intervals are wider than
Student-t intervals, so their coverage cannot be lower, yet Normal(10, 7) at n = 10 reports 0.658 for DMSD-t.

Corrected DMSD-t coverage:

| Distribution | n = 10 | 20 | 30 | 50 | 70 | 100 |
|---|---|---|---|---|---|---|
| Normal(10, 7) | 0.962 | 0.981 | 0.987 | 0.990 | 0.994 | 0.997 |
| Beta(10, 0.3), skew −3 | 0.854 | 0.916 | 0.952 | 0.978 | 0.984 | 0.992 |
| Gamma(0.5, 1), skew 4 | 0.868 | 0.938 | 0.963 | 0.977 | 0.986 | 0.995 |
| Lognormal(1, 0.8), skew 3.6 | 0.890 | 0.938 | 0.962 | 0.978 | 0.986 | 0.992 |

### 2. Table 3.3 "Gamma (Skewness 4)" repeats the Beta (skewness −3) numbers

The Gamma-skewness-4 block of Table 3.3 is identical, digit for digit, to the Beta-skewness-−3 block of Table 3.2
(for example, Student t coverage 0.836, 0.880, 0.895, 0.917, 0.920, 0.935). The actual Gamma(0.5, 1) simulation
gives, for example, Student t coverage 0.853, 0.896, 0.913, 0.931, 0.930, 0.944. Run `R/reproduce_paper.R` to get the full table.

### 3. Table 3.5 (psychotropic data): mistyped cells

In 13 of the 23 rows, the published upper limit and/or width differs from the code's output. Most differ by exactly 10.

| Statistic | Published (lower, upper, width) | Code output |
|---|---|---|
| Mad t | 25.66, **69.08**, **43.43** | 25.66, 59.08, 33.43 |
| AADM t | 22.66, 62.08, **44.42** | 22.66, 62.08, 39.42 |
| Wizard from Median t | 19.46, 65.28, **45.12** | 19.46, 65.28, 45.82 |
| T1 | 21.41, 63.33, **44.91** | 21.41, 63.33, 41.91 |
| T2 | **23.19**, **61.55**, **44.36** | 33.19, 51.55, 18.36 |
| T3 | 26.75, 57.99, **41.23** | 26.75, 57.99, 31.23 |
| Median T2 | **22.85**, **61.89**, **45.04** | 32.85, 51.89, 19.04 |
| Median T3 | 26.17, **68.57**, **42.39** | 26.17, 58.57, 32.39 |
| MAD T1 | 26.92, **67.82**, **40.90** | 26.92, 57.82, 30.90 |
| MAD T2 | **25.60**, **69.14**, **43.54** | 35.60, 49.14, 13.54 |
| MAD T3 | **20.85**, **63.89**, **45.03** | 30.86, 53.89, 23.03 |
| Q1 t | 16.13, 68.61, **42.47** | 16.13, 68.61, 52.47 |
| Q1Q3 t | 18.05, 66.69, **44.63** | 18.05, 66.69, 48.63 |

With the code's values, the shortest interval is **MAD T2** (13.54), then T2 (18.36) and Median T2 (19.04). The paper's
text names MAD-T1 as shortest. All intervals still cover the hypothesised mean of 42.37, so that conclusion stands.
