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

readAndCleanData <- function(reduceFeatures = FALSE) {
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
  
  features <<- fread(paste0(dataDirectory, "features.txt"), col.names = c("index", "featureNames"))
  
  featuresToInclude <<- as.integer(row.names(features))
  
  if(reduceFeatures) {
    featuresToInclude <- grep(".*mean.*|.*std.*|.*max.*", features[, featureNames])
  }
  
  
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
samsungData$SubjectNum <- as.factor(samsungData$SubjectNum)
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
distanceMatrix <- dist(sub1[,9:11])
hclustering <- hclust(distanceMatrix)
myplclust(hclustering, lab.col = 1:6)

svd1 <- svd(scale(sub1[, -c(1,2,562,563)]))
par(mfrow = c(1,3))
plot(svd1$u[,1], col = sub1$Activity, pch = 19)
plot(svd1$u[,2], col = sub1$Activity, pch = 19)
plot.new()
legend("bottomright", legend = activityLabels$activityName, col = activityLabels$classLabels, pch = 1)

# the first singular vector seperates moving and non-moving activities. not so sure about the 2nd
# lets try to find maximum contributor
par(mfrow = c(1,1))
plot(svd1$v[,2], pch = 19)

## NOT RIGHT
maxContrib <- which.max(svd1$v[,2])
distanceMatrix <- dist(sub1[, c(9:11, maxContrib)])
hclustering <- hclust(distanceMatrix)
myplclust(hclustering, lab.col = 1:6)

# use k-means clustering to see if we can seperate out the individual activities
kClust <- kmeans(sub1[,-c(1,2,562,563)], centers = 6, nstart = 100)
table(kClust$cluster, sub1$Activity)

# each time you run the above code, kmeans will produce different clusters. our goal is to seperate out the activites
# so pick the cluster that bins each activity in the fewest number of clusters
# The resulting clusters are pretty good (at least for moving)
# from these cluster, if set of observations fall in clusters 2,4 or 5 the subject is moving
# if in clusters 1,3 and 6 the subject is not moving
#WALKING WALKING_UPSTAIRS WALKING_DOWNSTAIRS SITTING STANDING LAYING
#1       0                0                  0      10        2     18
#2       0               53                  0       0        0      3
#3       0                0                  0      37       51      0
#4      95                0                  0       0        0      0
#5       0                0                 49       0        0      0
#6       0                0                  0       0        0     29
