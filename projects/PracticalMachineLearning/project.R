library(caret); library(ggplot2); library(gbm); library(randomForest); library(doMC); library(gridExtra); library(VIM)

setwd("~/Desktop/coursera/DataScience/projects/PracticalMachineLearning/")
# load data
originalTraining <- read.csv("pml-training.csv")
testing <- read.csv("pml-testing.csv")

table(complete.cases(originalTraining))
# the original training data only contains ~ 2% complete cases, so find the root cause!
# there are a lot of statisticall variablles that we will ignore, which hopefully eliminates the missing observations
varsToIgnore <- "^(X|user_name|raw_timestamp_part_1|raw_timestamp_part_2|cvtd_timestamp|new_window|num_window|kurtosis|skewness|min|max|stddev|total|var|avg|ampl)"
colsToIgnore <- grep(varsToIgnore, names(originalTraining))
originalTraining <- originalTraining[,-colsToIgnore]
testing <- testing[,-colsToIgnore]

table(complete.cases(originalTraining))
table(complete.cases(testing))
# perfect, now we do not have any missing observations!
# I would like to create an elapses time variable from the raw_timestamps but I do not know the meaning of these, same
# with window so lets ignore these as well
# I would like to ignore the user_name variable but lets build some models first 

# due to the large discrepancy in the sizes of the training and test sets, we will split the train set into 80/20 partitions
inTrain <- createDataPartition(y=originalTraining$classe, p=0.8, list=F)
# training on training set :)
training <- originalTraining[inTrain,]; validation <- originalTraining[-inTrain,]

# plot PC1 vs. PC2 and color by variable var
plotPCAForVariable <- function(var, varname) {
  qplot(data=training_pc12,x=x,y=y,col=training[,c(as.numeric(var))]) + labs(colour = varname)
}

### PCA - since variables are on much different scales, lets first center and scale everything
training.scaled <- scale(training[,-c(49)], center=T,scale=T)
pc <- prcomp(training.scaled) 
cumsum((pc$sdev^2 / sum(pc$sdev^2))) # First 2 principle components exlain ~ 47% of the variance 
training_pc12 <- as.matrix(training.scaled) %*% pc$rotation[,c(1,2)]
training_pc12 <- data.frame(x=training_pc12[,1],y=training_pc12[,2])
plotPCAForVariable(49)
# this figure does not tell us too much, except at first glance it appears that activity E is prevalent across the board


## roll_belt
plotPCAForVariable(1,"roll_belt")
# this figure simply shows that there are roughly 2 distict clusters/groups present in the data: 
# when the second PC is negative, roll_belt will either be in group 1 or group 2 (so reduce this variable to a factor 
# variable with only 2 levels)

## pitch_belt
plotPCAForVariable(2)
# this plot shows something similar: when the first PC is > ~2.5 pitch_belt can be collapsed into a factor variable with 2 levels

## yaw_belt
plotPCAForVariable(3)
# this variable is a little trickier: we observe roughly 3 groups:
# 1: PC1 < ~2.5 AND PC2 is positive
# 2: PC2 is negative
# 3: PC1 > ~2.5 and PC1 is positive

# We can continue with this PCA in an effort to reduce the space of features

## Dimensionality Reduction / Clustering
# based on the above PCA lets cluster a few variables (reduce their domain)
cm <- cor(training[,-c(49)])
# from the correlation matrix lets identify variables to cluster on
# 1 and 3,7:9 (roll_belt, accel_belt_x, accel_belt_y, accel_belt_z)
colsToCombine <- c(1,3,8,9,17)
dist1 <- dist(training[,colsToCombine])
clust1 <- hclust(dist1)
#plot(clust1)
# so from the dendrogram, it looks like we might be able to reduce 5 variables into 1 (cluster), 
# where a good cut might be at k=180 (so the new variable is between 1 and 180)
kmeans1 <- kmeans(training[,colsToCombine], centers = 180)
training$new_belt <- kmeans1$cluster

# now add this to our vallidation and test sets
kmeans.val <- kmeans(validation[,colsToCombine], centers = 180)
validation$new_belt <- kmeans.val$cluster

## This clustering process can be continued for all variables



### Build Model
# random forests appear to perform the best so we will go with that here
myTrainControl <- trainControl(method="cv", number=3, verboseIter=T)
modFit <- train(classe ~ ., data=training[,-c(50)], method="rf", trControl=myTrainControl)

print(modFit$finalModel)

prediction <- predict(modFit, newdata=validation)
cm1 <- confusionMatrix(validation$classe, prediction)
## So accuracy of the full model is 99.29%



# lets see what happens to the accuracy when we collapse 5 variables into 1 cluster
modFit2 <- train(classe ~., data = training[,-colsToCombine], method="rf", trControl=myTrainControl)
prediction2 <- predict(modFit2, newdata=validation)
cm2 <- confusionMatrix(validation$classe, prediction2)
## The accuracy of the simpler model (merged 5 vars into 1) only decreased to 98.5%


# lets compute the importance of each variable
var.importance <- varImp(modFit$finalModel)
var.importance$name <- rownames(var.importance)
var.importance <- var.importance[order(var.importance$Overall, decreasing = T),]
rownames(var.importance) <- NULL
print(var.importance)

var.importance2 <- varImp(modFit2$finalModel)
var.importance2$name <- rownames(var.importance2)
var.importance2 <- var.importance2[order(var.importance2$Overall, decreasing = T),]
rownames(var.importance2) <- NULL
print(var.importance2)

## So the cluster new_belt ranks 31st in variable importance. 
# The following figure is intended to visualize any correlation that may exist in the most important variables. 
# From this plot it appears that the combination of roll_belt and yaw_belt are easily seperable (based on outcome activity).
# This indicates these two variables are candidates for clustering (dimensionallity reduction). However, magnet_dumbbell_z
# and magnet_dumbbell_y are not nearly as easilly seperable, implying that these 2 features would not make good candidates 
# to cluser (by themselves).
p1 <- qplot(data=training,x=roll_belt,y=pitch_forearm,col=training$classe)
p2 <- qplot(data=training,x=magnet_dumbbell_z,y=magnet_dumbbell_y,col=training$classe)
grid.arrange(p1,p2)



## Conclusions
# Lastly, we make predictions on the test set using our random-forest model.
test.pred <- predict(modFit, newdata = testing)
