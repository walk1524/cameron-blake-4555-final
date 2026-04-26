RANDOM_SEED <- 42

DATA_PATH <- file.path("data", "f1_strategy_dataset_v4.csv")
RESULTS_DIR <- "results"
PLOTS_DIR <- file.path(RESULTS_DIR, "plots")
MODELS_DIR <- file.path(RESULTS_DIR, "models")
METRICS_PATH <- file.path(RESULTS_DIR, "metrics_summary.csv")
NOTES_PATH <- file.path(RESULTS_DIR, "experiment_notes.md")

LABEL_COLUMN <- "PitNextLap"
GROUP_COLUMNS <- c("Race", "Year")

CATEGORICAL_FEATURES <- c("Driver", "Compound", "Race")
NUMERIC_FEATURES <- c(
  "LapNumber",
  "Stint",
  "TyreLife",
  "Position",
  "LapTime (s)",
  "Year",
  "LapTime_Delta",
  "Cumulative_Degradation",
  "RaceProgress",
  "Normalized_TyreLife",
  "Position_Change"
)
CANDIDATE_FEATURES <- c(CATEGORICAL_FEATURES, NUMERIC_FEATURES)
LEAKAGE_COLUMNS <- c("PitNextLap", "PitStop")
REQUIRED_COLUMNS <- unique(c(CANDIDATE_FEATURES, LEAKAGE_COLUMNS))

MODEL_SPECS <- list(
  model1 = "Baseline shallow network: Dense(64, relu) -> Dense(1, sigmoid)",
  model2 = "Deeper network: Dense(128, relu) -> Dense(64, relu) -> Dense(1, sigmoid)",
  model3 = "Deeper network with dropout regularization: Dense(128) -> Dropout(0.3) -> Dense(64) -> Dropout(0.3) -> Dense(1)"
)
