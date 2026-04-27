# Simple R Markdown Version

Open `f1_pit_strategy_simple.Rmd` in RStudio and click **Knit**, or run each chunk from top to bottom.

The file expects this dataset path:

```text
data/f1_strategy_dataset_v4.csv
```

Start with:

```r
quick_mode <- TRUE
```

That makes the file run faster while testing.

For the final version, change it to:

```r
quick_mode <- FALSE
```

The R Markdown file trains three models:

1. `baseline`
2. `deeper`
3. `dropout_regularized`

It saves a simple metrics table here:

```text
results/simple_rmd_metrics_summary.csv
```
