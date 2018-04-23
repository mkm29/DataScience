library(caret); library(kernlab); data(spam)
inTrain <- createDataPartition(y=spam$type, p=0.75, list = F)

training <- spam[inTrain,]
testing <- spam[-inTrain,]

# column 58 is the type: spam or non-spam
M <- abs(cor(training[,-58]))
diag(M) <- 0
which(M > 0.8, arr.ind = T)
#        row col
# num415  34  32
# direct  40  32
# num857  32  34
# direct  40  34
# num857  32  40
# num415  34  40

# from this the following covariates are correlated (>0.8):
# num415 & num857
# direct & num857
par(mfrow = c(1,2))
plot(spam[,34], spam[,32], xlab = "num415", ylab = "num857")
plot(spam[,32], spam[,40], xlab = "num415", ylab = "direct")

X <- 0.71*(training$num415 + training$num857)
Y <- 0.71*(training$num415 - training$num857)
par(mfrow = c(1,1))
plot(X,Y)

smallSpam <- spam[,c(32, 34, 40)]
prComp1 <- prcomp(smallSpam[,c(1,2)])
plot(prComp1$x[,1],prComp1$x[,2])


prComp1$rotation
#              PC1        PC2
# num857 0.7061498 -0.7080625
# num415 0.7080625  0.7061498
## This is where he got 0.71 above!

# need to repeat this for the 2nd correlated pair (direct & num857)
prComp2 <- prcomp(smallSpam[,c(1,3)])
plot(prComp2$x[,1],prComp2$x[,2])
prComp2$rotation

# visualize!
typeColor <- ((spam$type=="spam")*1+1)
prComp <- prcomp(log10(spam[,-58]+1))
plot(prComp$x[,1], prComp$x[,2], col = typeColor, xlab = "PC1", ylab = "PC2")
# In PCA, the first principle component explains the most variation in the data, the 2nd PC explains the second, etc.

# you can do the same PCA with caret
preProc <- preProcess(log10(spam[,-58]+1), method = "pca", pcaComp = 2)
spamPC <- predict(preProc, log10(spam[,-58]+1))
plot(spamPC[,1], spamPC[,2], col = typeColor)

# not sure where the error stems from..
modelFit <- train(training$type ~ ., method = "glm", preProcess="pca",data = training)
