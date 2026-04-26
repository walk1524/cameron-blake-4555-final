# F1 Pit Strategy Neural Network Project - RStudio Version

This project trains TensorFlow/Keras neural networks in **RStudio** to predict whether a Formula 1 driver will pit on the next lap.

## Main Goal

The binary target is `PitNextLap`:

- `0`: driver will not pit on the next lap
- `1`: driver will pit on the next lap

The project uses grouped train/validation/test splitting by `Race + Year` so the same race-year context does not appear in more than one split.

## Dataset

Expected dataset location:

```text
data/f1_strategy_dataset_v4.csv
```

Expected columns:

```text
Driver, LapNumber, Compound, Stint, TyreLife, Position, LapTime (s),
Race, Year, LapTime_Delta, Cumulative_Degradation, PitStop,
PitNextLap, RaceProgress, Normalized_TyreLife, Position_Change
```

## Feature Selection

The candidate input features are:

```text
Driver, LapNumber, Compound, Stint, TyreLife, Position, LapTime (s),
Race, Year, LapTime_Delta, Cumulative_Degradation, RaceProgress,
Normalized_TyreLife, Position_Change
```

`PitNextLap` is excluded because it is the label. `PitStop` is excluded because it is too close to the event being predicted and risks leakage or near-leakage.

## Setup in Web RStudio / Posit Cloud

1. Open the `.Rproj` file.
2. Run this once in the RStudio Console:

```r
source("install_packages.R")
```

3. Run a quick test:

```r
source("scripts/run_experiments.R")
run_experiments(mode = "quick")
```

4. Run the full experiment:

```r
run_experiments(mode = "full")
```

5. Optional context comparison:

```r
run_experiments(mode = "full", include_context_comparison = TRUE)
```

## Preprocessing

The preprocessing logic is fit on the training split only and reused for validation/test data.

- Missing `Compound` values are filled with `UNKNOWN`.
- Other categorical features are filled with the most frequent training value.
- Numeric features are median-imputed.
- `Driver`, `Compound`, and `Race` are one-hot encoded.
- Numeric features are standardized using the training mean and standard deviation.
- The fitted preprocessor is saved to `results/models/preprocessor.rds`.

## Models

The main experiment trains three neural networks:

- `model1`: Dense(64, relu) -> Dense(1, sigmoid)
- `model2`: Dense(128, relu) -> Dense(64, relu) -> Dense(1, sigmoid)
- `model3`: Dense(128, relu) -> Dropout(0.3) -> Dense(64, relu) -> Dropout(0.3) -> Dense(1, sigmoid)

All models use Adam, binary crossentropy, early stopping on validation loss, and class weights based on the training split.

## Results

After running experiments, inspect:

```text
results/metrics_summary.csv
results/experiment_notes.md
results/models/preprocessor.rds
results/models/model1_best.keras
results/models/model2_best.keras
results/models/model3_best.keras
results/plots/model1_loss.png
results/plots/model1_accuracy.png
results/plots/model2_loss.png
results/plots/model2_accuracy.png
results/plots/model3_loss.png
results/plots/model3_accuracy.png
results/plots/best_model_confusion_matrix.png
```

## Project Structure

```text
.
├── 4555-Final-Project.Rproj
├── README.md
├── install_packages.R
├── data/
│   └── f1_strategy_dataset_v4.csv
├── R/
│   ├── config.R
│   ├── evaluate.R
│   ├── load_data.R
│   ├── models.R
│   ├── preprocess.R
│   ├── split_data.R
│   ├── train.R
│   └── utils.R
├── scripts/
│   └── run_experiments.R
├── results/
│   ├── models/
│   └── plots/
└── report/
    └── report_template.md
```
