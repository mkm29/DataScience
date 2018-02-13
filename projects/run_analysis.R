##################################################
## Project: Getting and Cleaning Data Course Project
## Script: Read the accelometer data collected by UCI
## from Samsung Galaxy phones, clean it, perform simple stats on it
## Return a human-readable, formatted data frame 
## Source: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
## Date: 2/12/18
## Author: Mitch Murphy
##################################################

init <- function(base_directory = "~/Desktop/DataScience/coursera/") {
  # Set the working directory
  setwd(base_directory)
  
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
  
  dataDirectory <<- paste(getwd(), "data/UCI HAR Dataset", sep = "/")
  
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
  
  
  dataDirectory <- paste(getwd(),"data/UCI HAR Dataset/",sep = "/")
  # Read data
  activityLabels <<- fread(paste0(dataDirectory, "activity_labels.txt"), col.names = c("classLabels", "activityName"))
  
  features <- fread(paste0(dataDirectory, "features.txt"), col.names = c("index", "featureNames"))
  featuresToInclude <- grep("(mean|std)\\(\\)", features[, featureNames])
  measurements <- features[featuresToInclude,featureNames]
  measurements <- gsub('[()]', '', measurements)
  
  train.x <- fread(paste0(dataDirectory,"train/X_train.txt"))[, featuresToInclude, with = FALSE]
  data.table::setnames(train.x, colnames(train.x), measurements)
  train.y <- fread(paste0(dataDirectory,"train/Y_train.txt"), col.names = c("Activity"))
  train.subjects <- fread(paste0(dataDirectory,"train/subject_train.txt"), col.names = c("SubjectNum"))
  
  train <<- cbind(train.subjects, train.y, train.x)
  
  
  # Now load up the test data
  test.x <- fread(paste0(dataDirectory,"test/X_test.txt"))[, featuresToInclude, with = FALSE]
  data.table::setnames(test.x, colnames(test.x), measurements)
  test.y <- fread(paste0(dataDirectory,"test/Y_test.txt"), col.names = c("Activity"))
  test.subjects <- fread(paste0(dataDirectory,"test/subject_test.txt"), col.names = c("SubjectNum"))
  
  test <<- cbind(test.subjects, test.y, test.x)
}

init()
# this function will do most of the work for us (reading and cleaning up the data)
downloadData()
readAndCleanData()


## Merges the training and the test sets to create one data set.
if(is.null(train) & is.null(test)) {
  stop("train and test variables do not exist. Make sure you first call readAndClean()")
}
total <- rbind(train, test)

## Coerce the SubjectNum column into factors
total$SubjectNum <- as.factor(total$SubjectNum)

# Now let us map the Activity number into its equiv name (read from activities.txt) in activitesLabel list

total$Activity <- factor(total$Activity, levels = activityLabels[["classLabels"]], labels = activityLabels[["activityName"]])



## From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
## This will be our final, "tidy" data set
total <- reshape2::melt(data = total, id = c("SubjectNum", "Activity"))
total <- reshape2::dcast(data = total, SubjectNum + Activity ~ variable, fun.aggregate = mean)

## Now save (write) this data table to disk
write.table(total, file = paste(dataDirectory, "tidyData.txt", sep = "/"))
