# Main RStudio entry point.
# Example quick run:
# source("scripts/run_experiments.R")
# run_experiments(mode = "quick")

library(keras3)
library(tensorflow)

source("R/config.R")
source("R/utils.R")
source("R/load_data.R")
source("R/split_data.R")
source("R/preprocess.R")
source("R/models.R")
source("R/train.R")
source("R/evaluate.R")

run_experiments <- function(
  mode = "full",
  epochs = NULL,
  batch_size = 256,
  patience = NULL,
  quick_max_groups = 24,
  include_context_comparison = FALSE,
  data_path = NULL
) {
  if (!mode %in% c("quick", "full")) {
    stop("mode must be either 'quick' or 'full'.")
  }

  set_global_seed(RANDOM_SEED)
  ensure_directories()

  if (is.null(epochs)) {
    epochs <- ifelse(mode == "quick", 5, 60)
  }
  if (is.null(patience)) {
    patience <- ifelse(mode == "quick", 2, 8)
  }

  df <- load_dataset(data_path)
  if (mode == "quick") {
    df <- reduce_to_quick_mode_groups(df, max_groups = quick_max_groups, seed = RANDOM_SEED)
  }

  split_result <- split_by_race_year(df, seed = RANDOM_SEED)
  prepared <- prepare_data(split_result$train, split_result$validation, split_result$test)
  class_weights <- compute_balanced_class_weights(prepared$y_train)

  metrics_list <- list()
  trained_models <- list()

  for (model_name in c("model1", "model2", "model3")) {
    trained <- train_model(
      model_name = model_name,
      x_train = prepared$x_train,
      y_train = prepared$y_train,
      x_validation = prepared$x_validation,
      y_validation = prepared$y_validation,
      epochs = epochs,
      batch_size = batch_size,
      patience = patience,
      class_weight = class_weights
    )

    metrics_list[[model_name]] <- evaluate_model(
      model_name,
      trained$model,
      prepared$x_train,
      prepared$y_train,
      prepared$x_validation,
      prepared$y_validation,
      prepared$x_test,
      prepared$y_test
    )

    plot_history(model_name, trained$history)
    trained_models[[model_name]] <- trained$model
  }

  context_comparison_note <- "Not run. Use include_context_comparison = TRUE to run this optional check."
  comparison_model <- NULL

  if (include_context_comparison) {
    comparison_features <- setdiff(CANDIDATE_FEATURES, c("Driver", "Race"))
    comparison_data <- prepare_data(
      split_result$train,
      split_result$validation,
      split_result$test,
      feature_columns = comparison_features
    )

    trained <- train_model(
      model_name = "model3",
      x_train = comparison_data$x_train,
      y_train = comparison_data$y_train,
      x_validation = comparison_data$x_validation,
      y_validation = comparison_data$y_validation,
      epochs = epochs,
      batch_size = batch_size,
      patience = patience,
      class_weight = class_weights
    )

    metrics_list[["model3_without_driver_race"]] <- evaluate_model(
      "model3_without_driver_race",
      trained$model,
      comparison_data$x_train,
      comparison_data$y_train,
      comparison_data$x_validation,
      comparison_data$y_validation,
      comparison_data$x_test,
      comparison_data$y_test
    )

    plot_history("model3_without_driver_race", trained$history)
    comparison_model <- trained$model
    context_comparison_note <- paste(
      "Run as model3_without_driver_race. Compare its metrics with model3 to judge",
      "whether Driver/Race context improves performance or encourages memorization."
    )
  }

  metrics_df <- do.call(rbind, metrics_list)
  rownames(metrics_df) <- NULL
  write.csv(metrics_df, METRICS_PATH, row.names = FALSE)

  best_index <- which.min(metrics_df$validation_loss)
  best_model_name <- metrics_df$model[best_index]
  best_model <- if (best_model_name == "model3_without_driver_race") comparison_model else trained_models[[best_model_name]]
  plot_confusion_matrix_for_best_model(best_model, prepared$x_test, prepared$y_test)

  write_experiment_notes(
    df = df,
    split_summary = split_result$split_summary,
    metrics_df = metrics_df,
    missing_report = missing_value_report(df),
    class_weights = class_weights,
    mode = mode,
    epochs = epochs,
    batch_size = batch_size,
    patience = patience,
    context_comparison_note = context_comparison_note
  )

  message("Done. Results saved in the results/ folder.")
  invisible(metrics_df)
}

write_experiment_notes <- function(
  df,
  split_summary,
  metrics_df,
  missing_report,
  class_weights,
  mode,
  epochs,
  batch_size,
  patience,
  context_comparison_note
) {
  class_counts <- table(factor(df[[LABEL_COLUMN]], levels = c(0, 1)))
  class_balance_lines <- paste0(
    "- `", names(class_counts), "`: ", as.integer(class_counts),
    " rows (", format_percent(as.integer(class_counts) / nrow(df)), ")"
  )

  notes <- paste0(
    "# Experiment Notes\n\n",
    "## Run Configuration\n",
    "- Mode: `", mode, "`\n",
    "- Random seed: `", RANDOM_SEED, "`\n",
    "- Epoch limit: `", epochs, "`\n",
    "- Batch size: `", batch_size, "`\n",
    "- Early stopping patience: `", patience, "`\n",
    "- Best model selection: lowest validation loss\n\n",
    "## Task\n",
    "Predict `", LABEL_COLUMN, "`:\n",
    "- `0`: driver will not pit on the next lap\n",
    "- `1`: driver will pit on the next lap\n\n",
    "## Feature Selection Rationale\n",
    "Inputs are limited to race state, tire state, lap timing, driver identity, race identity, and year:\n",
    "`", paste(CANDIDATE_FEATURES, collapse = ", "), "`.\n\n",
    "`PitNextLap` is the label and is never used as an input. `PitStop` is also excluded because it is too close to the target event and would create leakage or near-leakage.\n\n",
    "Categorical features one-hot encoded: `", paste(CATEGORICAL_FEATURES, collapse = ", "), "`.\n",
    "Numeric features median-imputed and scaled: `", paste(NUMERIC_FEATURES, collapse = ", "), "`.\n\n",
    "## Missing Values\n",
    "`Compound` missing values are filled with `UNKNOWN`. Other categorical missing values use most-frequent imputation, and numeric missing values use median imputation.\n\n",
    "```\n", paste(capture.output(print(missing_report)), collapse = "\n"), "\n```\n\n",
    "## Grouped Splits\n",
    "Splits are grouped by `Race + Year`; no race-year group appears in more than one split.\n\n",
    write_markdown_table(split_summary), "\n\n",
    "## Class Balance\n",
    paste(class_balance_lines, collapse = "\n"), "\n\n",
    "Balanced class weights used during training: `", paste(names(class_weights), unlist(class_weights), sep = "=", collapse = ", "), "`.\n\n",
    "## Models\n",
    paste(paste0("- `", names(MODEL_SPECS), "`: ", unlist(MODEL_SPECS)), collapse = "\n"), "\n\n",
    "## Optional Context Comparison\n",
    context_comparison_note, "\n\n",
    "## Metrics Summary\n",
    write_markdown_table(metrics_df), "\n\n",
    "## Saved Artifacts\n",
    "- Metrics: `results/metrics_summary.csv`\n",
    "- Preprocessor: `results/models/preprocessor.rds`\n",
    "- Model files: `results/models/`\n",
    "- Plots: `results/plots/`\n"
  )

  writeLines(notes, NOTES_PATH)
}

# Run quick mode automatically only when this file is sourced interactively and you uncomment this line:
# run_experiments(mode = "quick")
