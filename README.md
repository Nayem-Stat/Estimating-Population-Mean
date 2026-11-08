# Estimating Population Mean

**A Simulation Study on Some Confidence Intervals for Estimating the Population Mean Under Asymmetric and Symmetric Distribution Conditions**

HM Nayem & BM Golam Kibria, Department of Mathematics and Statistics, Florida International University

*Journal of Statistics Applications & Probability Letters* **11**(3), 123–144 (2024)
**DOI: [10.18576/jsapl/110303](https://doi.org/10.18576/jsapl/110303)**

![poster](docs/poster.png)

## Summary

Confidence intervals (CIs) for a population mean usually rely on the normal or Student-t approximation, which
breaks down when data are skewed or contain outliers. This study compares **24 interval estimators** in a Monte Carlo
simulation:

- **Classical:** Student t, Johnson t, Median t, Mad t, AADM t, Chen t, Yanagihara–Yuan t, DMSD t, S_ps t, Downton t
- **Transformation-based:** T1, T2, T3, Median T1–T3, MAD T1–T3 (Hall; Zhou & Dinh; Almonte & Kibria)
- **Proposed:** **Wizard t**, **Wizard t from median**, **Q1 t**, **Q3 t** and **Q1Q3 t**

The proposed estimators replace the SD in the t interval with an SD measured around a *wizard* (20 %-chopped)
mean or median, or around a quartile.

**Design:** Normal, Beta, Gamma and Lognormal populations with skewness from −5 to +6; n = 10, 20, 30, 50, 70, 100;
M = 2,500 replications; 95 % level. The criteria are coverage probability and mean interval width.

**Main findings**

| Situation | Recommended |
|---|---|
| Symmetric data, small n | **Student t**: nominal coverage, shortest width |
| Skewed data, moderate n (> 50) | Proposed **Wizard t, Wizard t from median, Q1 t, Q3 t, Q1Q3 t**: consistently higher coverage with competitive width |
| Skewed data, smaller n | Median t, AADM t, Median T1, Chen t, YY t |

Two real-life datasets, psychotropic-drug exposure (right-skewed) and long-jump distances (left-skewed), support the simulation results.

![Normal(10,7): coverage and width](docs/fig_normal.png)

## Code

| File | What it does |
|---|---|
| [`R/ci_estimators.R`](R/ci_estimators.R) | `ci_estimators(x)` returns all 24 CIs for a sample; `simulate_ci()` runs the Monte Carlo study |
| [`R/reproduce_paper.R`](R/reproduce_paper.R) | Reproduces the simulation tables (3.1–3.4) and the real-data tables (3.5, 3.6) |

```r
source("R/ci_estimators.R")
x <- read.csv("data/psychotropic_drug_exposure.csv")$users
ci_estimators(x, trim = "upper")          # 95 % CIs from all 24 estimators

# coverage and width for Gamma(0.5, 1) samples
set.seed(965)
simulate_ci(function(n) rgamma(n, 0.5, 1), mu = 0.5, trim = "upper")
```

```bash
Rscript R/reproduce_paper.R     # ~1 min, writes results/*.csv
```

The `trim` argument sets which tail the wizard estimators chop: `"upper"` for right-skewed data, `"lower"`
for left-skewed data, `"both"` for symmetric data. The code is base R, with no packages needed.
It is a condensed version of the original analysis scripts and gives **identical** results.

## Data

| File | n | Description | Shape |
|---|---|---|---|
| [`data/psychotropic_drug_exposure.csv`](data/psychotropic_drug_exposure.csv) | 20 | Number of psychotropic-drug users among non-antipsychotic drug users, across drug categories | right-skewed (skew 1.57); mean 42.37, SD 48.43 |
| [`data/long_jump_distance.csv`](data/long_jump_distance.csv) | 40 | Final long-jump distances (m) of 40 athletes | left-skewed (skew −1.16); mean 7.6745, SD 0.37 |
| [`data/psychiatric_disorders.csv`](data/psychiatric_disorders.csv) | 11 | Additional example (not in the paper) | right-skewed (skew 0.92) |

![Histograms of the real-life data](docs/fig_real_data_histograms.png)

Simulated populations (Table 2.1 of the paper):

| Distribution | Parameters | Skewness |
|---|---|---|
| Normal | μ = 10, σ = 7 | 0 |
| Gamma | (4, 1), (1, 1), (0.5, 1) | 1, 2, 4 |
| Beta | (10, 0.3), (6, 0.6), (6, 0.1) | −3, −2, −5 |
| Lognormal | (1, 0.6), (1, 0.8), (1, 1) | 2.2, 3.6, 6 |

## Notes

Rerunning the code shows three issues in the published tables. See [`docs/reproducibility.md`](docs/reproducibility.md).

1. **DMSD-t coverage** in Tables 3.1–3.4 repeats the MAD-T3 coverage, because of an index error in the original
   scripts. This code reports the correct values: for example, Normal at n = 10 gives 0.962, not 0.658.
2. Table 3.3's **Gamma (skewness 4)** block repeats the Beta (skewness −3) numbers.
3. Several cells of **Table 3.5** were mistyped, most by exactly 10.

## Citation

```bibtex
@article{nayem2024ci,
  author  = {Nayem, H. M. and Kibria, B. M. Golam},
  title   = {A Simulation Study on Some Confidence Intervals for Estimating the Population Mean
             Under Asymmetric and Symmetric Distribution Conditions},
  journal = {Journal of Statistics Applications \& Probability Letters},
  volume  = {11}, number = {3}, pages = {123--144}, year = {2024},
  doi     = {10.18576/jsapl/110303}
}
```

Contact: HM Nayem, hnaye001@fiu.edu
