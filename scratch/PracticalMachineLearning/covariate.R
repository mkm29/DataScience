library(caret); library(ISLR); data(Wage)

inTrain <- createDataPartition(y=Wage$wage, p=0.7, list=F)
training <- Wage[inTrain,]; testing <- Wage[-inTrain,]

# visualize the data in order to get insight in creating new covariates/features
table(training$jobclass)

# create some dummy variables
# take a variable (factor) and convert it to an integer for class
dummies <- dummyVars(wage ~ jobclass, data = training)
head(predict(dummies,newdata=training))

nsv <- nearZeroVar(training, saveMetrics = T)
nsv

# so remove the region covariate
table(training$race) # all white lol

# BASIS - instead of linear models we might want a curve
library(splines)
# bs() creates a polynomial variable; in this case a third degree polynomial
bsBasis <- bs(training$age, df=3)
head(bsBasis)

lm1 <- lm(wage ~ bsBasis,data = training)
par(mfrow=c(1,1))
plot(training$age, training$wage, pch = 19, cex=0.5)
points(training$age, predict(lm1, newdata=training), col = "red", pch = 19, cex = 0.5)

# now lets predict on the test set
# recall that these values will be the polynomial age covariates created in the training set (bs())
predict(bsBasis, age=testing$age)
