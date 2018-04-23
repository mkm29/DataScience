library(caret); library(ggplot2); library(kernlab); data(spam)

set.seed(32343)

inTrain <- createDataPartition(y=spam$type, p=0.75, list=F)
training <- spam[inTrain,]
testing <- spam[-inTrain,]

hist(training$capitalAve, main = "", xlab = "avg capital run length")

# preprocess technique: standardize the data (mean zero, sd 1)
trainCapAvg <- (training$capitalAve - mean(training$capitalAve))/sd(training$capitalAve)

# alternatively we can use the preprocess function in the caret package
preObj <- preProcess(training[,-58], method = c("center","scale"))
trainCapAvgS <- predict(preObj, training[,-58])$capitalAve
# this is the exact same as manually centering and scaling the variable, however it is easier to read
# will have mean ~ 0 and sd ~ 1 (they might not be these exact values but very close)
testcapAvgS <- predict(preObj, testing[,-58])$capitalAve

modelFit <- train(type ~., data = training, preProcess = c("center","scale"), method = "glm")
modelFit

# Box-Cox transforms
preObj <- preProcess(training[,-58], method = c("BoxCox"))
trainCapAvgS <- predict(preObj, training[,-58])$capitalAve
par(mfrow = c(1,2)); hist(trainCapAvgS); qqnorm(trainCapAvg)


# IMPUTE data
set.seed(13343)

# Make some values NA
training$capAve <- training$capitalAve
selectNA <- rbinom(dim(training)[1], size = 1, prob = 0.05)==1
# sum(selectNA)/length(training$capitalAve)
# so make about 4.9% of data NA
training$capAve[selectNA] <- NA

# Impute and standardize
preObj <- preProcess(training[,-58], method = "knnImpute")
capAve <- predict(preObj, training[,-58])$capAve

# Standardize true values
capAveTruth <- training$capitalAve
capAveTruth <- (capAveTruth-mean(capAveTruth))/sd(capAveTruth)
# lets take a look at how Imputing effects capitalAve
missing <- which(selectNA==TRUE)
df <- data.frame(old = training$capitalAve[missing], new = capAve[missing])

# lets look at the differences in the 2. They shoulld be very similar (hey thats the point of knn right?)
quantile(capAve - capAveTruth)
#            0%           25%           50%           75%          100% 
# -0.9293448161 -0.0022170127 -0.0009386278 -0.0003386729  0.2539600026
quantile((capAve - capAveTruth)[selectNA])
#            0%           25%           50%           75%          100% 
# -0.5105369133 -0.0149015960 -0.0007858974  0.0217213130  0.2539600026 
quantile((capAve - capAveTruth)[!selectNA])
#            0%           25%           50%           75%          100% 
# -0.9293448161 -0.0021587893 -0.0009411592 -0.0003741132  0.0001212082