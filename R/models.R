build_model <- function(model_name, input_dim) {
  model <- keras3::keras_model_sequential(
    name = model_name,
    input_shape = c(input_dim)
  )
  
  if (model_name == "model1") {
    model |>
      keras3::layer_dense(units = 64, activation = "relu") |>
      keras3::layer_dense(units = 1, activation = "sigmoid")
    
  } else if (model_name == "model2") {
    model |>
      keras3::layer_dense(units = 128, activation = "relu") |>
      keras3::layer_dense(units = 64, activation = "relu") |>
      keras3::layer_dense(units = 1, activation = "sigmoid")
    
  } else if (model_name == "model3") {
    model |>
      keras3::layer_dense(units = 128, activation = "relu") |>
      keras3::layer_dropout(rate = 0.30) |>
      keras3::layer_dense(units = 64, activation = "relu") |>
      keras3::layer_dropout(rate = 0.30) |>
      keras3::layer_dense(units = 1, activation = "sigmoid")
    
  } else {
    stop(paste("Unknown model name:", model_name))
  }
  
  model |>
    keras3::compile(
      optimizer = keras3::optimizer_adam(),
      loss = "binary_crossentropy",
      metrics = c("accuracy")
    )
  
  model
}