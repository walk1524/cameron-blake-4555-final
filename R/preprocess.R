median_impute <- function(values, replacement = NULL) {
  if (is.null(replacement)) {
    replacement <- median(values, na.rm = TRUE)
  }
  values[is.na(values)] <- replacement
  values
}

mode_value <- function(values) {
  values <- values[!is.na(values) & values != ""]
  if (length(values) == 0) {
    return("UNKNOWN")
  }
  names(sort(table(values), decreasing = TRUE))[1]
}

fit_preprocessor <- function(train_df, feature_columns = CANDIDATE_FEATURES) {
  categorical_features <- intersect(CATEGORICAL_FEATURES, feature_columns)
  numeric_features <- intersect(NUMERIC_FEATURES, feature_columns)
  
  category_fill_values <- list()
  factor_levels <- list()
  
  for (feature in categorical_features) {
    if (feature == "Compound") {
      fill_value <- "UNKNOWN"
    } else {
      fill_value <- mode_value(train_df[[feature]])
    }
    
    filled <- as.character(train_df[[feature]])
    filled[is.na(filled) | filled == ""] <- fill_value
    
    category_fill_values[[feature]] <- fill_value
    
    factor_levels[[feature]] <- sort(unique(c(
      filled,
      fill_value,
      "OTHER"
    )))
  }
  
  numeric_medians <- sapply(numeric_features, function(feature) {
    median(train_df[[feature]], na.rm = TRUE)
  })
  
  numeric_means <- sapply(numeric_features, function(feature) {
    values <- median_impute(train_df[[feature]], numeric_medians[[feature]])
    mean(values)
  })
  
  numeric_sds <- sapply(numeric_features, function(feature) {
    values <- median_impute(train_df[[feature]], numeric_medians[[feature]])
    sd_value <- sd(values)
    ifelse(is.na(sd_value) || sd_value == 0, 1, sd_value)
  })
  
  list(
    feature_columns = feature_columns,
    categorical_features = categorical_features,
    numeric_features = numeric_features,
    category_fill_values = category_fill_values,
    factor_levels = factor_levels,
    numeric_medians = numeric_medians,
    numeric_means = numeric_means,
    numeric_sds = numeric_sds
  )
}

transform_with_preprocessor <- function(df, preprocessor) {
  categorical_parts <- list()
  
  for (feature in preprocessor$categorical_features) {
    values <- as.character(df[[feature]])
    fill_value <- preprocessor$category_fill_values[[feature]]
    levels <- preprocessor$factor_levels[[feature]]
    
    values[is.na(values) | values == ""] <- fill_value
    values[!values %in% levels] <- "OTHER"
    
    values <- factor(values, levels = levels)
    
    encoded <- model.matrix(~ values - 1, na.action = na.pass)
    colnames(encoded) <- paste(feature, levels, sep = "_")
    
    categorical_parts[[feature]] <- encoded
  }
  
  numeric_part <- NULL
  
  if (length(preprocessor$numeric_features) > 0) {
    numeric_part <- as.matrix(df[preprocessor$numeric_features])
    
    for (feature in preprocessor$numeric_features) {
      numeric_part[, feature] <- median_impute(
        numeric_part[, feature],
        preprocessor$numeric_medians[[feature]]
      )
      
      numeric_part[, feature] <- (
        numeric_part[, feature] - preprocessor$numeric_means[[feature]]
      ) / preprocessor$numeric_sds[[feature]]
    }
  }
  
  x <- do.call(cbind, c(categorical_parts, list(numeric_part)))
  storage.mode(x) <- "double"
  x
}


prepare_data <- function(train_df, validation_df, test_df, feature_columns = CANDIDATE_FEATURES) {
  preprocessor <- fit_preprocessor(train_df, feature_columns)
  x_train <- transform_with_preprocessor(train_df, preprocessor)
  x_validation <- transform_with_preprocessor(validation_df, preprocessor)
  x_test <- transform_with_preprocessor(test_df, preprocessor)
  saveRDS(preprocessor, file.path(MODELS_DIR, "preprocessor.rds"))
  list(
    x_train = x_train,
    y_train = as.numeric(train_df[[LABEL_COLUMN]]),
    x_validation = x_validation,
    y_validation = as.numeric(validation_df[[LABEL_COLUMN]]),
    x_test = x_test,
    y_test = as.numeric(test_df[[LABEL_COLUMN]]),
    preprocessor = preprocessor,
    feature_names = colnames(x_train)
  )
}
