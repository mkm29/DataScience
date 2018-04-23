library(caret); data("faithful"); set.seed(333)

inTrain <- createDataPartition(y=faithful$waiting, p=0.5, list=F)
trainFaithful <- faithful[inTrain,]; testFaithful <- faithful[-inTrain,]
head(trainFaithful)

lm1 <- lm(eruptions ~ waiting, data = trainFaithful)
summary(lm1)

plot(trainFaithful$waiting, trainFaithful$eruptions, pch=19, col="blue", xlab="Waiting", ylab="Eruptions")
lines(trainFaithful$waiting, lm1$fitted.values, lwd=3)

# lets predict the num of eruptions when the weaiting time is 8-
coef(lm1)[1] + coef(lm1)[2]*80
# 4.119307

newdata <- data.frame(waiting=80)
predict(lm1, newdata)

w <- 80
r <- range(trainFaithful$waiting)
f <- (w-r[1])/(r[2]-r[1])
n <- length(trainFaithful$waiting)
index <- round(f*n,0)
error <- abs(lm1$residuals[index])
predict(lm1, newdata)+c(-1,1)*error


# we built this model on the train set, now let us see how it performs on the test set
par(mfrow = c(1,2))
plot(trainFaithful$waiting, trainFaithful$eruptions, pch=19, col="blue", xlab="Waiting", ylab="Eruptions")
lines(trainFaithful$waiting, lm1$fitted.values, lwd=3)
plot(testFaithful$waiting, testFaithful$eruptions, pch=19,col="blue", xlab="Waiting", ylab="Eruptions")
lines(testFaithful$waiting, predict(lm1, newdata=testFaithful), lwd=3)

# calculate RMSE on training 
sqrt(sum((lm1$fitted.values - trainFaithful$eruptions)^2))
# 5.75186
# this is another way of computing:
sqrt(sum(lm1$residuals^2))

# now calculate RMSE for the test set
sqrt(sum((predict(lm1,newdata=testFaithful)-testFaithful$eruptions)^2))
# 5.838559
# I do not think you can compute this as we did above (using just the lm1 model)

# Now let us calculate prediction intervals
pred1 <- predict(lm1, newdata=testFaithful, interval = "prediction")
ord <- order(testFaithful$waiting)
par(mfrow = c(1,1))
plot(testFaithful$waiting, testFaithful$eruptions, pch=19, col="blue")
matlines(testFaithful$waiting[ord], pred1[ord,], type = "l",col=c(1,2,2), lty = c(1,1,1), lwd=3)
# kind of already did this for one particullar value (waiting=80) above. The intervals are quite large...


# here we do the same thing but with the caret package
modFit <- train(eruptions ~ waiting, data = trainFaithful, method = "lm")
summary(modFit)
