calculate_metrics <- function(actual, predicted) {
  actual <- as.integer(actual)
  predicted <- as.integer(predicted)
  tp <- sum(actual == 1 & predicted == 1)
  tn <- sum(actual == 0 & predicted == 0)
  fp <- sum(actual == 0 & predicted == 1)
  fn <- sum(actual == 1 & predicted == 0)
  accuracy <- (tp + tn) / length(actual)
  precision <- ifelse(tp + fp == 0, 0, tp / (tp + fp))
  recall <- ifelse(tp + fn == 0, 0, tp / (tp + fn))
  f1 <- ifelse(precision + recall == 0, 0, 2 * precision * recall / (precision + recall))
  list(
    accuracy = accuracy,
    precision = precision,
    recall = recall,
    f1 = f1,
    confusion_matrix = matrix(c(tn, fp, fn, tp), nrow = 2, byrow = TRUE)
  )
}

evaluate_model <- function(
  model_name,
  model,
  x_train,
  y_train,
  x_validation,
  y_validation,
  x_test,
  y_test
) {
  train_eval <- keras3::evaluate(model, x_train, y_train, verbose = 0)
  validation_eval <- keras3::evaluate(model, x_validation, y_validation, verbose = 0)
  test_eval <- keras3::evaluate(model, x_test, y_test, verbose = 0)

  probabilities <- as.numeric(keras3::predict(model, x_test, verbose = 0))
  predictions <- ifelse(probabilities >= 0.5, 1, 0)
  metrics <- calculate_metrics(y_test, predictions)

  data.frame(
    model = model_name,
    train_loss = as.numeric(train_eval[["loss"]]),
    validation_loss = as.numeric(validation_eval[["loss"]]),
    test_loss = as.numeric(test_eval[["loss"]]),
    train_accuracy = as.numeric(train_eval[["accuracy"]]),
    validation_accuracy = as.numeric(validation_eval[["accuracy"]]),
    test_accuracy = as.numeric(test_eval[["accuracy"]]),
    precision = metrics$precision,
    recall = metrics$recall,
    f1 = metrics$f1,
    confusion_matrix = paste(as.vector(metrics$confusion_matrix), collapse = ";"),
    stringsAsFactors = FALSE
  )
}

plot_history <- function(model_name, history) {
  history_df <- as.data.frame(history$metrics)
  history_df$epoch <- seq_len(nrow(history_df))

  png(file.path(PLOTS_DIR, paste0(model_name, "_loss.png")), width = 900, height = 600)
  plot(history_df$epoch, history_df$loss, type = "l", xlab = "Epoch", ylab = "Binary crossentropy", main = paste(model_name, "Loss"))
  lines(history_df$epoch, history_df$val_loss, lty = 2)
  legend("topright", legend = c("train", "validation"), lty = c(1, 2))
  dev.off()

  png(file.path(PLOTS_DIR, paste0(model_name, "_accuracy.png")), width = 900, height = 600)
  plot(history_df$epoch, history_df$accuracy, type = "l", xlab = "Epoch", ylab = "Accuracy", main = paste(model_name, "Accuracy"))
  lines(history_df$epoch, history_df$val_accuracy, lty = 2)
  legend("bottomright", legend = c("train", "validation"), lty = c(1, 2))
  dev.off()
}

plot_confusion_matrix_for_best_model <- function(model, x_test, y_test) {
  probabilities <- as.numeric(keras3::predict(model, x_test, verbose = 0))
  predictions <- ifelse(probabilities >= 0.5, 1, 0)
  matrix_values <- calculate_metrics(y_test, predictions)$confusion_matrix

  png(file.path(PLOTS_DIR, "best_model_confusion_matrix.png"), width = 800, height = 700)
  image(t(matrix_values[nrow(matrix_values):1, ]), axes = FALSE, main = "Best Model Confusion Matrix")
  axis(1, at = c(0, 1), labels = c("No pit next lap", "Pit next lap"))
  axis(2, at = c(0, 1), labels = rev(c("No pit next lap", "Pit next lap")))
  text(expand.grid(x = c(0, 1), y = c(0, 1)), labels = as.vector(t(matrix_values[2:1, ])), cex = 2)
  mtext("Predicted", side = 1, line = 3)
  mtext("Actual", side = 2, line = 3)
  dev.off()
}
