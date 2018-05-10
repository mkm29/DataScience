library(caret); library(ggplot2); library(gbm); library(randomForest); library(doMC); library(gridExtra); library(VIM); library(parallel)

setwd("~/Desktop/coursera/DataScience/projects/PracticalMachineLearning/")
registerDoMC(cores=detectCores())
# load data
originalTraining <- read.csv("pml-training.csv")
testing <- read.csv("pml-testing.csv")
table(complete.cases(originalTraining))

varsToIgnore <- "^(X|user_name|raw_timestamp_part_1|raw_timestamp_part_2|cvtd_timestamp|new_window|num_window|kurtosis|skewness|min|max|stddev|total|var|avg|ampl)"
colsToIgnore <- grep(varsToIgnore, names(originalTraining))
originalTraining <- originalTraining[,-colsToIgnore]
testing <- testing[,-colsToIgnore]
table(complete.cases(originalTraining))

inTrain <- createDataPartition(y=originalTraining$classe, p=0.8, list=F)
# training on training set :)
training <- originalTraining[inTrain,]; validation <- originalTraining[-inTrain,]

myTrainControl <- trainControl(method="cv", number=3, verboseIter=T, allowParallel = T)
modFit <- train(classe ~ ., data=training, method="rf", trControl=myTrainControl)
print(modFit$finalModel)

prediction <- predict(modFit, newdata=validation)
confusionMatrix(validation$classe, prediction)