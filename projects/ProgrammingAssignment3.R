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

best <- function(state, outcome) {
  ## Read outcome data
  
  
  ## Check that state and outcome are valid
  
  
  ## Return hospital name in that state with lowest 30-day death
}


rankhospital <- function(state, outcome, num = "best") {
  ## Read outcome data
  
  
  ## Check that state and outcome are valid
  
  
  ## Return hospital name in that state with the given rank
  
  
  ## 30-day death rate
}


rankall <- function(outcome, num = "best") {
  ## Read outcome data
  
  
  ## Check that state and outcome are valid
  
  
  ## For each state, find the hospital of the given rank
  
  
  ## Return a data frame with the hospital names and the
  
  
  ## (abbreviated) state name
}

