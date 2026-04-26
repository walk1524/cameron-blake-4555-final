# Run this once in the RStudio Console.
# Posit Cloud/web RStudio may ask to restart after installing packages.

packages <- c(
  "keras3",
  "tensorflow",
  "tidyverse",
  "caret",
  "pROC",
  "here"
)

missing_packages <- packages[!packages %in% rownames(installed.packages())]
if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}

library(keras3)
library(tensorflow)

# Installs the Python environment used behind R Keras.
# If your professor already has TensorFlow configured on the server,
# this may say it is already installed.
keras3::install_keras()
