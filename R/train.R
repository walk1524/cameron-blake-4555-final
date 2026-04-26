compute_balanced_class_weights <- function(y_train) {
  counts <- table(factor(y_train, levels = c(0, 1)))
  total <- sum(counts)
  weights <- total / (length(counts) * as.numeric(counts))
  names(weights) <- c("0", "1")
  as.list(weights)
}

train_model <- function(
  model_name,
  x_train,
  y_train,
  x_validation,
  y_validation,
  epochs,
  batch_size,
  patience,
  class_weight = NULL
) {
  model <- build_model(model_name, input_dim = ncol(x_train))
  model_path <- file.path(MODELS_DIR, paste0(model_name, "_best.keras"))

  callbacks <- list(
    keras3::callback_early_stopping(
      monitor = "val_loss",
      patience = patience,
      restore_best_weights = TRUE
    ),
    keras3::callback_model_checkpoint(
      filepath = model_path,
      monitor = "val_loss",
      save_best_only = TRUE
    )
  )

  history <- keras3::fit(
    model,
    x = x_train,
    y = y_train,
    validation_data = list(x_validation, y_validation),
    epochs = epochs,
    batch_size = batch_size,
    callbacks = callbacks,
    class_weight = class_weight,
    verbose = 2
  )

  list(model = model, history = history, model_path = model_path)
}
