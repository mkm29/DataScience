##################################################
## Project: R Programming, Assignment 3
## Script Perform basis analyses on particular hospital data
## Date: 2/6/18
## Author: Mitch Murphy
##################################################


# set the working directory to that where the data for this project is located
setwd("~/Desktop/DataScience/coursera/data/hospital/")


# now make sure the data.table package is installed/loaded
require(data.table)

outcome <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
head(outcome)

outcome[, 11] <- as.numeric(outcome[, 11])
hist(outcome[, 11])

# initial setup complete, now write functions that operate on the outcome data