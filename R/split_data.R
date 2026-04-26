add_group_key <- function(df) {
  df$`_race_year_group` <- paste(df[[GROUP_COLUMNS[1]]], df[[GROUP_COLUMNS[2]]], sep = "_")
  df
}

choose_group_slices <- function(groups, seed = RANDOM_SEED) {
  set.seed(seed)
  shuffled <- sample(groups)
  n_groups <- length(shuffled)
  train_end <- max(1, round(n_groups * 0.70))
  validation_end <- min(n_groups - 1, train_end + max(1, round(n_groups * 0.15)))
  list(
    train_groups = shuffled[seq_len(train_end)],
    validation_groups = shuffled[(train_end + 1):validation_end],
    test_groups = shuffled[(validation_end + 1):n_groups]
  )
}

build_split_summary <- function(train, validation, test) {
  total_rows <- nrow(train) + nrow(validation) + nrow(test)
  make_row <- function(name, split) {
    data.frame(
      split = name,
      rows = nrow(split),
      row_percent = ifelse(total_rows == 0, 0, nrow(split) / total_rows),
      race_year_groups = length(unique(split$`_race_year_group`)),
      pit_next_lap_rate = ifelse(nrow(split) == 0, 0, mean(split[[LABEL_COLUMN]])),
      stringsAsFactors = FALSE
    )
  }
  rbind(
    make_row("train", train),
    make_row("validation", validation),
    make_row("test", test)
  )
}

split_by_race_year <- function(df, seed = RANDOM_SEED) {
  grouped <- add_group_key(df)
  unique_groups <- unique(grouped$`_race_year_group`)
  if (length(unique_groups) < 3) {
    stop("Need at least three Race-Year groups for train/validation/test splitting.")
  }
  slices <- choose_group_slices(unique_groups, seed)
  train <- grouped[grouped$`_race_year_group` %in% slices$train_groups, ]
  validation <- grouped[grouped$`_race_year_group` %in% slices$validation_groups, ]
  test <- grouped[grouped$`_race_year_group` %in% slices$test_groups, ]
  list(
    train = train,
    validation = validation,
    test = test,
    split_summary = build_split_summary(train, validation, test)
  )
}

reduce_to_quick_mode_groups <- function(df, max_groups = 24, seed = RANDOM_SEED) {
  grouped <- add_group_key(df)
  unique_groups <- unique(grouped$`_race_year_group`)
  if (max_groups <= 0 || max_groups >= length(unique_groups)) {
    return(df)
  }
  set.seed(seed)
  selected <- sample(unique_groups, size = max_groups, replace = FALSE)
  reduced <- grouped[grouped$`_race_year_group` %in% selected, ]
  reduced$`_race_year_group` <- NULL
  reduced
}
