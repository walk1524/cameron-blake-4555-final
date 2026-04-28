#How to run

Use this in console to download needed packages:

install.packages(c("keras3", "tensorflow", "tfdatasets", "rmarkdown", "knitr"))

Run this just in case:

library(keras3)
install_keras()


Then click knit inside f1_pit_template_style.Rmd

# what data was used and what the model is trying to predict here

The NN uses a Formula 1 data set

this files is in the data folder called f1_strategy_dataset_v4.csv

The model is trying to predict when the driver
is going to take a PitNextLap

0 mean the driver does not pit on the next lap.
1 means the driver does pit on the next lap.

#Features used and the encoding

We use numeric features for our current model.

the input features are the following.

LapNumber
Stint
TyreLife
Position
LapTime.s
Year
LapTime_Delta
Cumulative_degradation
RaceProgress
Normalize_TyreLife
Position_Change

The ouput label is:
PitNextLap

The model uses the first 11 selected columns for input data.

We conver PitNextLap with to_categorical()

This means 0 becomes [1,0] and 1 becomes[0,1]

We do not use text columns yet. (Driver, Compound, Race)

currently no one-hot encoding but this is something we will add later

#Arcitecture

It has two dense layers.

Layer 1 is hidden.

11 input values
64 nodes.
ReLU activation

Layer 2 is the output layer.

2 output nodes
softmax Activation

There is two output nodes since there is not classes

0 = no pit next lap
1 = pit next lap

#What is accomplished
The project completes a basic neural network workflow.

It:
loads the Formula 1 dataset
shows basic dataframe information
selects numeric features
splits the data into training and testing sets
converts the target labels into categorical form
builds a simple neural network
trains the model
evaluates the model on testing data
prints prediction probabilities

This proves that the data can be loaded, run through a neural network, trained, and tested.

#What needs to be done

The project can imporve by adding one-hot encoding catergorical features

adding more than one nureal network architecture

adding regularization like dropout


Right now, most laps are not pit laps, so accuracy can be misleading because the model can get a high score by mostly predicting no pit next lap.