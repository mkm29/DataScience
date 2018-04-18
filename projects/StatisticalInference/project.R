library(datasets)
library(ggplot2)

set.seed(round(1000*pi, 0))

lambda <- 0.2
# We willl be taking the average of 40 exponentials
n <- 40
# we will be comparing this distribution to 1000 random uniforms
numOfSims <- 1000
simulatedExponentials <- replicate(numOfSims, rexp(n, lambda))
# now lets compute the mean of these simulations
means <- apply(simulatedExponentials, 2, mean)


d <- density(means)
plot(d, main = "Kernel Density of Means", xlab = "Mean")
polygon(d, col = "red", border = "blue")
observed_mean <- mean(means)
legend("topleft", legend = c(paste("Observed Mean:",round(observed_mean,3)), paste("Expected Mean:",lambda^-1)),
       lty = c(2,3), col = c("yellow", "black"), bty = "n")
abline(v=lambda^-1, col = "yellow", lwd = 2, lty = 2)
abline(v=observed_mean, col = "black", lty = 3, lwd = 2)

# first let's compute the standard deviations
sample_sd <- sd(means)
expected_sd <- (1/lambda)/sqrt(n)
# now let's focus on the variance of the 2
sample_var <- sample_sd^2
expected_var <- ((1/lambda)*(1/sqrt(n)))^2
compareMatrix <- matrix(c(1/lambda,observed_mean,
                          expected_var, sample_var), nrow = 2)
rownames(compareMatrix) <- c("Expected","Observed")
colnames(compareMatrix) <- c("mean", "variance")
compareMatrix

# lets overlay the normal distribution over our observed data (density/histogram)
xfit <- seq(min(means), max(means), length=100)
yfit <- dnorm(xfit, mean=1/lambda, sd=(1/lambda/sqrt(n)))
hist(means,breaks=n,prob=T,col="orange",xlab = "means",main="Density of means",ylab="density")
lines(xfit, yfit, pch=22, col="black", lty=5)

qqnorm(means)
qqline(means, col = 2)


tg <- ToothGrowth
tg$dose <- as.factor(tg$dose)
str(tg)
summary(tg)

ggplot(data=tg, aes(x=dose, y=len, fill=supp)) + geom_bar(stat="identity",) + facet_grid(. ~ supp) + 
  xlab("Dose, mg") + ylab("Tooth length") + guides(fill=guide_legend(title="Supplement"))

ci <- t.test(len ~ supp, data = tg)
pval <- ci$p.value

tg.dose1 <- subset(tg, dose %in% c(0.5,1.0))
tg_dose2 <- subset(tg, dose %in% c(0.5,2.0))
tg_dose3 <- subset(tg, dose %in% c(1.0,2.0))

# construct the CI for dose of 0.5 and 1.0
t.test(len ~ dose, data = tg.dose1)
#construct the CI for a dose of 0.5 and 2.0
t.test(len ~ dose, data = tg_dose2)
# construct the CI for a dose of 1.0 and 2.0
t.test(len ~ dose, data = tg_dose3)