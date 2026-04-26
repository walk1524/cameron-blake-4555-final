ensure_directories <- function() {
  dirs <- c(RESULTS_DIR, PLOTS_DIR, MODELS_DIR)
  for (dir in dirs) {
    if (!dir.exists(dir)) {
      dir.create(dir, recursive = TRUE)
    }
  }
}

set_global_seed <- function(seed = RANDOM_SEED) {
  set.seed(seed)
  tensorflow::set_random_seed(seed)
}

format_percent <- function(value, digits = 2) {
  paste0(round(value * 100, digits), "%")
}

write_markdown_table <- function(df) {
  if (nrow(df) == 0) {
    return("No rows.")
  }
  text_df <- as.data.frame(lapply(df, as.character), stringsAsFactors = FALSE)
  headers <- names(text_df)
  widths <- integer(length(headers))
  for (i in seq_along(headers)) {
    widths[i] <- max(nchar(headers[i]), nchar(text_df[[i]]), na.rm = TRUE)
  }
  format_row <- function(values) {
    cells <- mapply(function(value, width) {
      sprintf(paste0("%-", width, "s"), value)
    }, values, widths, USE.NAMES = FALSE)
    paste0("| ", paste(cells, collapse = " | "), " |")
  }
  separator <- paste0("| ", paste(strrep("-", widths), collapse = " | "), " |")
  paste(c(format_row(headers), separator, apply(text_df, 1, format_row)), collapse = "\n")
}
