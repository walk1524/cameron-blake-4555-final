# F1 Pit Strategy Neural Network Report Template

## 1. Data Description
- Dataset file: `data/f1_strategy_dataset_v4.csv`
- Number of rows: `[fill in]`
- Number of race-year groups: `[fill in]`
- Target variable: `PitNextLap`
- Target meaning:
  - `0`: driver will not pit on the next lap
  - `1`: driver will pit on the next lap
- Class balance:
  - `0`: `[fill in]`
  - `1`: `[fill in]`

## 2. Goal and Hypotheses
Goal: train a neural network to predict whether a Formula 1 driver will pit on the next lap.

Hypotheses:
- Tire age, stint number, lap number, and race progress should help predict pit timing.
- Position and lap-time degradation may signal strategy pressure or tire wear.
- Driver and race context may improve performance, but may also make the model rely on context-specific patterns.

## 3. Feature Selection Rationale
Candidate input features:
`Driver`, `LapNumber`, `Compound`, `Stint`, `TyreLife`, `Position`, `LapTime (s)`, `Race`, `Year`, `LapTime_Delta`, `Cumulative_Degradation`, `RaceProgress`, `Normalized_TyreLife`, `Position_Change`.

Excluded columns:
- `PitNextLap`: target label, so including it would leak the answer.
- `PitStop`: too directly connected to the pit event and could create near-leakage.

Rationale to fill in:
`[Explain why tire, timing, race progress, and position features are reasonable predictors.]`

## 4. Data Preprocessing and Encoding
- Missing values are detected before training.
- Missing `Compound` values are filled with `UNKNOWN`.
- Other categorical values are imputed with the most frequent value.
- Numeric values are imputed with the median.
- `Driver`, `Compound`, and `Race` are one-hot encoded.
- Numeric features are scaled with `StandardScaler`.
- The fitted preprocessor is saved to `results/models/preprocessor.joblib`.

## 5. Neural-Network Architecture Choices
Model 1 baseline:
- Dense(64, relu)
- Dense(1, sigmoid)

Model 2 deeper network:
- Dense(128, relu)
- Dense(64, relu)
- Dense(1, sigmoid)

Model 3 deeper network with regularization:
- Dense(128, relu)
- Dropout(0.3)
- Dense(64, relu)
- Dropout(0.3)
- Dense(1, sigmoid)

## 6. Training Setup
- Loss: binary crossentropy
- Optimizer: Adam
- Validation method: grouped validation split by `Race + Year`
- Test method: held-out race-year groups
- Early stopping: validation loss
- Random seed: `[fill in]`
- Epoch limit: `[fill in]`
- Batch size: `[fill in]`

## 7. Regularization
Model 3 uses dropout with a rate of 0.3 after each hidden layer.

Discussion placeholder:
`[Compare Model 3 against Model 2. Did dropout reduce overfitting? Use train/validation/test metrics.]`

## 8. Model Variations
Required models:
- Model 1: `[fill in result summary]`
- Model 2: `[fill in result summary]`
- Model 3: `[fill in result summary]`

Optional comparison:
- Model 3 without `Driver` and `Race`: `[fill in if run]`
- Interpretation: `[Does removing context hurt performance? Does it suggest memorization?]`

## 9. Results and Discussion
Use `results/metrics_summary.csv` and `results/experiment_notes.md`.

| Model | Train Acc | Val Acc | Test Acc | Precision | Recall | F1 |
|---|---:|---:|---:|---:|---:|---:|
| model1 | `[fill in]` | `[fill in]` | `[fill in]` | `[fill in]` | `[fill in]` | `[fill in]` |
| model2 | `[fill in]` | `[fill in]` | `[fill in]` | `[fill in]` | `[fill in]` | `[fill in]` |
| model3 | `[fill in]` | `[fill in]` | `[fill in]` | `[fill in]` | `[fill in]` | `[fill in]` |

Discussion prompts:
- Which model had the best validation loss?
- Did the best model also perform best on test data?
- Was precision or recall more important for this problem?
- What does the confusion matrix show?
- How did class imbalance affect the results?

## 10. Conclusions and Potential Improvements
Conclusion placeholder:
`[Summarize which architecture worked best and why.]`

Potential improvements:
- Add more race context, such as safety-car periods or weather, if available.
- Tune the probability threshold instead of using 0.5.
- Try sequence models if the assignment allows treating laps as time series.
- Try stronger regularization or hyperparameter search.

## 11. Running Instructions
Install dependencies:

```bash
pip install -r requirements.txt
```

Run a quick smoke test:

```bash
python -m src.run_experiments --mode quick
```

Run the full experiment:

```bash
python -m src.run_experiments --mode full
```

Run the optional context comparison:

```bash
python -m src.run_experiments --mode full --include-context-comparison
```

## 12. Sources / Dataset Citation
- Dataset: `data/f1_strategy_dataset_v4.csv`
- Citation or source link: `[fill in source, author, or course-provided dataset note]`
