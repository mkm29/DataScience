library(ISLR); library(caret); library(ggplot2)
data(Wage); Wage <- subset(Wage, select=-c(logwage))
summary(Wage)


inTrain <- createDataPartition(y=Wage$wage, p=0.7, list=F)
training <- Wage[inTrain, ]; testing <- Wage[-inTrain,]
dim(training); dim(testing)

featurePlot(x=training[,c("age","education","jobclass")], y = training$wage, plot = "pairs")
# from this we can see that there appears to be 2 groups for age -> y

qplot(age,wage,colour=jobclass, data = training)
abline(h=230)

jobs <- unique(Wage$jobclass)
industrialJobs <- subset(Wage, jobclass == jobs[1])
informationJobs <- subset(Wage, jobclass == jobs[2])

x <- subset(industrialJobs, wage >= 230)
y <- subset(informationJobs, wage >= 230)
# so for every industrial job earner over 230K there are ~3.4 information jobs 

qplot(age, wage, colour = education, data = training)
# from initial glance, appears that high earners are between 30 and 60

# only look at those with advanced degrees
educationLevels <- unique(training$education)
advancedDegree <- subset(training, education == educationLevels[4])
mean(advancedDegree$wage)
# 153.218
qplot(age, wage, data = advancedDegree)


# Fit a linear model
modFit <- train(wage ~ age + jobclass + education, method = "lm", data = training)
finMod <- modFit$finalModel
print(modFit)

plot(finMod,1,pch=19,cex=0.5,col="#00000010")

qplot(finMod$fitted.values, finMod$residuals, colour=race, data = training)
# this figure is misleading, as most of the original data is comprised of only white people

plot(finMod$residuals, pch=19)
# this is not the same as the plot Leek produced...
# as this plots the index of the residual vs its actual value, there should not be any trends. If there are that
# suggests another variable is missing

pred <- predict(modFit, testing)
qplot(wage, pred, colour=year, data = testing)


modFitAll <- train(wage ~ ., data = training, method = "lm")
pred <- predict(modFitAll, testing)
qplot(wage,pred,data = testing)

# you can manually inspect the summary of the model in order to eliminate features that aren't statistically significant
summary(modFitAll)


# Intercept
# year
# age
# education
# health
myModel <- train(wage ~ year + age + education + health, data = training, method = "lm")
pred <- predict(myModel, testing)
qplot(wage, pred, data = testing)
