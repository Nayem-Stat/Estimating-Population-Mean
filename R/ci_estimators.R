# =============================================================================
# ci_estimators.R
# 24 confidence intervals for the population mean
# Nayem & Kibria (2024), J. Stat. Appl. Pro. Lett. 11(3), 123-144
# https://doi.org/10.18576/jsapl/110303
#
# Condensed from the original analysis scripts. It reproduces their output
# exactly (same formulas and random-number order), except that DMSD-t coverage
# is computed correctly (see README, "Notes").
# =============================================================================

ESTIMATORS <- c("Student t", "Johnson t", "Median t", "Mad t", "AADM t",
                "Wizard t", "Wizard t from median", "T1", "T2", "T3",
                "Median T1", "Median T2", "Median T3", "MAD T1", "MAD T2", "MAD T3",
                "Chen t", "YY t", "DMSD t", "S_ps t", "Downton t",
                "Q1 t", "Q3 t", "Q1Q3 t")

#' All 24 intervals for one sample
#' @param x     numeric sample
#' @param alpha significance level (0.05 -> 95 % CIs)
#' @param trim  wizard trimming: "upper" drops the top 20 % (right-skewed data),
#'   "lower" drops the bottom 20 % (left-skewed), "both" keeps the middle
#'   values between the 20th and 80th percentiles
#' @param mu3_form "cubed" (third central moment); "sum" reproduces the
#'   Normal(10,7) script, where mu3 was computed from sum(x - mean)
#' @return data.frame: estimator, lower, upper, width
ci_estimators <- function(x, alpha = 0.05, trim = c("upper", "lower", "both"),
                          mu3_form = c("cubed", "sum")) {
  trim <- match.arg(trim); mu3_form <- match.arg(mu3_form)
  n <- length(x); m <- mean(x); s <- sd(x); md <- median(x)
  t <- qt(1 - alpha / 2, df = n - 1)
  se <- function(sd_) sd_ / sqrt(n)

  # spread measures
  mu3 <- if (mu3_form == "cubed") n * sum((x - m)^3) / ((n - 1) * (n - 2)) else n * sum(x - m) / ((n - 1) * (n - 2))
    s_med <- sqrt(sum((x - md)^2) / (n - 1))          # Median t
  s_mad <- sum(abs(x - m)) / n                      # Mad t
  s_aad <- sqrt(pi / 2) / n * sum(abs(x - md))      # AADM t

  # wizard mean / median (20 % of observations chopped)
  q <- quantile(x, c(0.2, 0.8))
  kept <- switch(trim, upper = x[x < q[2]], lower = x[x > q[1]], both = x[x > q[1] & x < q[2]])
  s_wiz <- sqrt(sum((x - mean(kept))^2) / (n + 3))
  s_wizm <- sqrt(sum((x - median(kept))^2) / (n + 3))

  # transformations T1, T2, T3 (Hall; Zhou & Dinh)
  g <- sum((x - m)^3) / s^3 / ((n - 1) * (n - 2))
  z <- qnorm(1 - alpha / 2) / sqrt(n)
  k <- z - g / (6 * n)
  T1 <- (3 / g) * (1 + g * k)^(1 / 3) - 3 / g
  T2 <- (3 * sqrt(n) / (2 * g)) * log10((2 * g / (3 * sqrt(n))) * k + 1)
  T3 <- (1 + 3 * k)^(1 / 3) - 1

  # Chen t, YY t
  gh <- mu3 / s^3
  chen <- (t + gh * (1 + 2 * t^2) / (6 * sqrt(n)) + gh^2 * (t + 2 * t^2) / (9 * n)) * se(s)
  k3 <- (sum((x - m)^3) / n) / (sum((x - m)^2) / n)^(3 / 2)
  yy_c <- m + s * k3 / (4 * n * (2 + 15 / n))

  # DMSD t (deciles), S_ps t (IQR), Downton t (Gini mean difference)
  d <- quantile(x, seq(0, 1, 0.1))
  s_dm <- sqrt(sum((d - mean(d))^2) / 8)
  s_ps <- IQR(x) / 1.349
  gmd <- 2 * sum(abs(outer(x, x, "-"))) / (n * (n - 1))
  s_dt <- 0.5 * gmd * sqrt(pi)

  # proposed quartile-based SDs
  Q <- quantile(x, c(0.25, 0.75))
  s1 <- sqrt(sum((x - Q[1])^2) / (n + 3))
  s3 <- sqrt(sum((x - Q[2])^2) / (n + 3))

  centre <- c(m, m + mu3 / (6 * s^2 * n), rep(m, 15), yy_c, m, md, md, m, m, m)
  moe <- c(t * se(s), t * se(s), t * se(s_med), t * se(s_mad), t * se(s_aad),
           t * se(s_wiz), t * se(s_wizm), T1 * s, T2 * s, T3 * s,
           T1 * s_med, T2 * s_med, T3 * s_med, T1 * s_mad, T2 * s_mad, T3 * s_mad,
           chen, t * se(s), t * se(s_dm), 1.253 * t * se(s_ps), 1.253 * t * se(s_dt),
           t * se(s1), t * se(s3), t * se((s1 + s3) / 2))
  data.frame(estimator = ESTIMATORS, lower = centre - moe, upper = centre + moe,
             width = 2 * moe, row.names = NULL)
  }

#' Monte Carlo coverage probability and mean width
#' @param rgen  function(n) returning a random sample
#' @param mu    true population mean
#' @param n     vector of sample sizes
#' @param M     replications per sample size
#' @return long data.frame: n, estimator, coverage, mean_width
simulate_ci <- function(rgen, mu, n = c(10, 20, 30, 50, 70, 100), M = 2500, ...) {
  do.call(rbind, lapply(n, function(nn) {
    hit <- wid <- numeric(length(ESTIMATORS))
    for (i in seq_len(M)) {
      ci <- ci_estimators(rgen(nn), ...)
      hit <- hit + ((ci$lower <= mu & ci$upper >= mu) %in% TRUE)
      wid <- wid + ci$width
      }
    data.frame(n = nn, estimator = ESTIMATORS, coverage = hit / M, mean_width = wid / M)
    }))
  }
