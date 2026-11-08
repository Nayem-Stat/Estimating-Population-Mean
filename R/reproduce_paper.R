# =============================================================================
# reproduce_paper.R  -  simulation tables and real-data examples of the paper
#   Rscript R/reproduce_paper.R      (about 1 minute; writes results/*.csv)
# =============================================================================
source("R/ci_estimators.R")
dir.create("results", showWarnings = FALSE)

# One scenario = one distribution. set.seed(965) each time, as in the original scripts.
run <- function(name, rgen, mu, trim, mu3_form = "cubed") {
  set.seed(965)
  res <- simulate_ci(rgen, mu, trim = trim, mu3_form = mu3_form)
  write.csv(res, file.path("results", paste0("sim_", name, ".csv")), row.names = FALSE)
  message("done: ", name)
}

run("normal_10_7",     function(n) rnorm(n, 10, 7),           mu = 10,                trim = "both", mu3_form = "sum")  # Table 3.1
run("beta_10_0.3",     function(n) rbeta(n, 10, 0.3),         mu = 10 / 10.3,         trim = "lower")  # Table 3.2
run("gamma_0.5_1",     function(n) rgamma(n, 0.5, scale = 1), mu = 0.5,               trim = "upper")  # Table 3.3
run("lognormal_1_0.8", function(n) rlnorm(n, 1, 0.8),         mu = exp(1 + 0.8^2 / 2), trim = "upper")  # Table 3.4

# Real-life examples (Section 3.5)
psychotropic <- read.csv("data/psychotropic_drug_exposure.csv")$users
long_jump    <- read.csv("data/long_jump_distance.csv")$distance_m
write.csv(ci_estimators(psychotropic, trim = "upper"), "results/table3.5_psychotropic.csv", row.names = FALSE)
write.csv(ci_estimators(long_jump,    trim = "upper"), "results/table3.6_long_jump.csv",    row.names = FALSE)
print(ci_estimators(psychotropic, trim = "upper"), digits = 4)
