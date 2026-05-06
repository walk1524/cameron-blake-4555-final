# How to Run

Open the project in RStudio using:

```text
4555-Final-Project.Rproj
```

Then run this in the RStudio Console to install and load the needed packages:

```r
source("install_packages.R")
```

After that, open:

```text
f1_pit_template_style.Rmd
```

Then click **Knit** in RStudio.

You can also knit from the Console with:

```r
rmarkdown::render("f1_pit_template_style.Rmd")
```

If Keras gives a Python or TensorFlow error while knitting, run this once:

```r
keras3::install_keras()
```

Then restart RStudio and knit again.

# What Data Was Used

The neural network uses a Formula 1 pit strategy dataset.

The file is stored locally in the data folder:

```text
data/f1_strategy_dataset_v4.csv
```

The model is trying to predict:

```text
PitNextLap
```

The label means:

```text
0 = the driver does not pit on the next lap
1 = the driver does pit on the next lap
```

# Features and Preprocessing

The model uses numeric race and tire features, plus one-hot encoded tire compound features.

The numeric features include:

```text
LapNumber
Stint
TyreLife
Position
LapTime
Year
LapTime_Delta
Cumulative_Degradation
RaceProgress
Normalized_TyreLife
Position_Change
```

The tire compound column is one-hot encoded into columns such as:

```text
Compound_HARD
Compound_MEDIUM
Compound_SOFT
Compound_WET
```

The model does not use `PitStop` as an input feature because that would leak information related to the answer.

The numeric input features are scaled before training so columns with larger numbers do not dominate the neural network.

The output label `PitNextLap` is converted with:

```r
to_categorical()
```

This changes the target values into a format that works with the softmax output layer.

# Model Architectures

The project compares two neural network approaches.

Model 1 is the simpler baseline model:

```text
Input layer based on the design matrix
Hidden layer: 64 nodes, ReLU activation
Output layer: softmax activation
```

Model 2 is the deeper regularized model:

```text
Input layer based on the design matrix
Hidden layer: 128 nodes, ReLU activation
Dropout: 0.2
Hidden layer: 64 nodes, ReLU activation
Dropout: 0.2
Output layer: softmax activation
```

Model 2 uses dropout regularization to help reduce overfitting.

# Training and Evaluation

The project uses:

```text
8,000 rows for training
2,000 rows for testing
20% validation split during training
30 training epochs
```

The report evaluates the models using:

```text
accuracy
loss
confusion matrices
```

The confusion matrices are important because most laps are not pit laps, so accuracy alone can be misleading.

# What Is Accomplished

The project completes a neural network workflow.

It:

```text
loads the Formula 1 dataset
selects useful features
one-hot encodes tire compound
scales numeric inputs
splits the data into training and testing sets
converts the target labels into categorical form
builds two neural network models
adds dropout regularization to the second model
trains both models
evaluates both models on testing data
compares results with accuracy, loss, and confusion matrices
```

# What Changed

The project started as a simple neural network using only numeric features and one model.

The updated version now includes:

```text
one-hot encoding for Compound
numeric feature scaling
more training epochs
validation during training
a second neural network architecture
dropout regularization
confusion matrices
cleaner report sections
results interpretation
conclusions
challenges and future improvements
```

These changes help the project better match the assignment requirements and make the knitted report easier to read.
