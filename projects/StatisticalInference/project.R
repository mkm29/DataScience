library(data.table)
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