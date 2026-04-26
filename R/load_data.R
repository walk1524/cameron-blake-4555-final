find_dataset <- function(preferred_path = DATA_PATH) {
  fallback_path <- "f1_strategy_dataset_v4.csv"
  if (file.exists(preferred_path)) {
    return(preferred_path)
  }
  if (file.exists(fallback_path)) {
    return(fallback_path)
  }
  stop("Could not find f1_strategy_dataset_v4.csv in data/ or the project root.")
}

validate_columns <- function(df) {
  missing <- setdiff(REQUIRED_COLUMNS, names(df))
  if (length(missing) > 0) {
    stop(paste("The dataset is missing required columns:", paste(missing, collapse = ", ")))
  }
  accidental_inputs <- intersect(LEAKAGE_COLUMNS, CANDIDATE_FEATURES)
  if (length(accidental_inputs) > 0) {
    stop(paste("Leakage columns cannot be used as features:", paste(accidental_inputs, collapse = ", ")))
  }
}

load_dataset <- function(dataset_path = NULL) {
  path <- find_dataset(if (is.null(dataset_path)) DATA_PATH else dataset_path)
  df <- read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  validate_columns(df)
  df
}

missing_value_report <- function(df) {
  counts <- colSums(is.na(df[REQUIRED_COLUMNS]))
  sort(counts, decreasing = TRUE)
}
