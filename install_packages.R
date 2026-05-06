# Disclaimer: Used AI to generate this package installer


# Run this once in the RStudio Console.
# Posit Cloud/web RStudio may ask to restart after installing packages.

packages <- c(
  "rmarkdown",
  "knitr",
  "keras3",
  "tensorflow",
  "tfdatasets",
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
library(tfdatasets)

cat("R packages are installed and loaded.\n")
cat("If Keras gives a Python/TensorFlow error when knitting, run this once:\n")
cat("keras3::install_keras()\n")
