##################################################
## Project: Getting and Cleaning Data Course Project
## Script: Read the accelometer data collected by UCI
## from Samsung Galaxy phones, clean it, perform simple stats on it
## Return a human-readable, formatted data frame 
## Source: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
## Date: 2/12/18
## Author: Mitch Murphy
##################################################

init <- function() {
  # Set the working directory
  projectDirectory <<- file.path(dirname(sys.frame(1)$ofile))
  setwd(projectDirectory)
  
  # get data directory
  setwd("../data/UCI HAR Dataset/")
  dataDirectory <<- paste0(getwd(), "/")
  setwd(projectDirectory)
  
  # Load needed packages
  library(data.table)
  library(reshape2)
  
}



downloadData <- function() {
  # Ensure that the UCI data exists in the current working directory.
  # If it does not, download the zip file and then unzip it
  # 
  # Args: nothing
  # Returns: nothing
  
  
  
  if(!dir.exists(dataDirectory)) {
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "data/UCI HAR Dataset.zip")
    unzip(paste0(dataDirectory, ".zip"))
  }
  # first check if the data is already there. If not, download it
}


## This function will read in both the train and test sets
## and cleans it up so we just have a train and test data.tables
## Not split into 2 functions due to how I use lexical scoping

readAndCleanData <- function() {
  # Read in the raw, unformatted data
  # "Clean it up" by only extracting the necessary columns (features)
  #  Repeat this process for both the train and test data sets
  # 
  # Args: none
  # 
  # Returns: officially nothing is returned from this function,
  #   however the formatted train and test data sets are added to the global environment
  # Read data
  activityLabels <<- fread(paste0(dataDirectory, "activity_labels.txt"), col.names = c("classLabels", "activityName"))
  
  features <- fread(paste0(dataDirectory, "features.txt"), col.names = c("index", "featureNames"))
  featuresToInclude <- grep(".*mean.*|.*std.*|.*max.*", features[, featureNames])
  measurements <- features[featuresToInclude,featureNames]
  measurements <- gsub('[()]', '', measurements)
  
  train.x <- fread(paste0(dataDirectory,"train/X_train.txt"))[, featuresToInclude, with = FALSE]
  data.table::setnames(train.x, colnames(train.x), measurements)
  train.y <- fread(paste0(dataDirectory,"train/Y_train.txt"), col.names = c("Activity"))
  train.subjects <- fread(paste0(dataDirectory,"train/subject_train.txt"), col.names = c("SubjectNum"))
  
  train <- cbind(train.subjects, train.y, train.x)
  
  
  # Now load up the test data
  test.x <- fread(paste0(dataDirectory,"test/X_test.txt"))[, featuresToInclude, with = FALSE]
  data.table::setnames(test.x, colnames(test.x), measurements)
  test.y <- fread(paste0(dataDirectory,"test/Y_test.txt"), col.names = c("Activity"))
  test.subjects <- fread(paste0(dataDirectory,"test/subject_test.txt"), col.names = c("SubjectNum"))
  
  test <- cbind(test.subjects, test.y, test.x)
  
  samsungData <<- rbind(train, test)
}

init()
# this function will do most of the work for us (reading and cleaning up the data)
downloadData()
readAndCleanData()


## Coerce the SubjectNum column into factors
total$SubjectNum <- as.factor(total$SubjectNum)
#total$SubjectNum <- NULL


# Now let us map the Activity number into its equiv name (read from activities.txt) in activitesLabel list

samsungData$Activity <- factor(samsungData$Activity, levels = activityLabels[["classLabels"]], labels = activityLabels[["activityName"]])

sub1 <- subset(samsungData, SubjectNum == 1)
par(mfrow = c(1,2), mar = c(5,4,1,1))
plot(sub1$`tBodyAcc-mean-X`, col = sub1$Activity, ylab = names(sub1)[3])
plot(sub1$`tBodyAcc-mean-Y`, col = sub1$Activity, ylab = names(sub1)[4])
legend("bottomright", legend = activityLabels$activityName, col = activityLabels$classLabels, pch = 1)

par(mfrow = c(1,2))
plot(sub1$`tBodyAcc-max-X`, pch = 19, col = sub1$Activity, ylab = "tBodyAcc-max-X")
legend("topleft", legend = activityLabels$activityName, col = activityLabels$classLabels, pch = 1)
plot(sub1$`tBodyAcc-max-Y`, pch = 19, col = sub1$Activity, ylab = "tBodyAcc-max-Y")

# there are a lot of features...lets try to reduce dimensionality by clustering

source("myplclust.R")

