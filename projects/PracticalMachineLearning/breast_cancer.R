## Wisconsin breast cancer study (1995 I believe)
## https://archive.ics.uci.edu/ml/machine-learning-databases/breast-cancer-wisconsin
## https://rpubs.com/raviolli77/352956


library(RCurl); library(caret); library(ggplot2); library(gbm); library(randomForest)
library(gridExtra); library(VIM); library(parallel); library(doParallel)

UCI_data_URL <- getURL('https://archive.ics.uci.edu/ml/machine-learning-databases/breast-cancer-wisconsin/wdbc.data')
names <- c('id_number', 'diagnosis', 'radius_mean', 
           'texture_mean', 'perimeter_mean', 'area_mean', 
           'smoothness_mean', 'compactness_mean', 
           'concavity_mean','concave_points_mean', 
           'symmetry_mean', 'fractal_dimension_mean',
           'radius_se', 'texture_se', 'perimeter_se', 
           'area_se', 'smoothness_se', 'compactness_se', 
           'concavity_se', 'concave_points_se', 
           'symmetry_se', 'fractal_dimension_se', 
           'radius_worst', 'texture_worst', 
           'perimeter_worst', 'area_worst', 
           'smoothness_worst', 'compactness_worst', 
           'concavity_worst', 'concave_points_worst', 
           'symmetry_worst', 'fractal_dimension_worst')
breast_cancer <- read.table(textConnection(UCI_data_URL), sep = ',', col.names = names)
breast_cancer$id_number <- NULL

inTrain <- createDataPartition(y=breast_cancer$diagnosis, p=0.75, list = F)
training <- breast_cancer[inTrain,]; testing <- breast_cancer[-inTrain,]

cl <- makeCluster(detectCores() - 1)
registerDoParallel(cl)
myTrainControl <- trainControl(method="cv", 
                               number=3, 
                               allowParallel = TRUE)
modFit <- train(diagnosis ~ ., data=training, method="rf", trControl=myTrainControl)
stopCluster(cl)

prediction <- predict(modFit, newdata=testing)
confusionMatrix(testing$diagnosis, prediction)


var.importance <- varImp(modFit$finalModel)
var.importance$name <- rownames(var.importance)
var.importance <- var.importance[order(var.importance$Overall, decreasing = T),]
rownames(var.importance) <- NULL
print(var.importance)
qplot(data=training,x=perimeter_worst,y=area_worst,col=training$diagnosis)

plotPCAForVariable <- function(var, varname) {
  qplot(data=training_pc12,x=x,y=y,col=training[,c(as.numeric(var))]) + labs(colour = varname)
}

training.scaled <- scale(training[,-c(1)], center=T,scale=T)
pc <- prcomp(training.scaled) 
cumsum((pc$sdev^2 / sum(pc$sdev^2))) # First 2 principle components exlain ~ 64% of the variance 
training_pc12 <- as.matrix(training.scaled) %*% pc$rotation[,c(1,2)]
training_pc12 <- data.frame(x=training_pc12[,1],y=training_pc12[,2])

plotPCAForVariable(1, "Diagnosis")
