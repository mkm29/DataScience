##################################################
## Project: Exploratory Data Analysis - Week 1 Course Project
## Script: Load power consumption data and take a look at the data (plotting)
## Saves 4 plots
## Source: https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip
## Date: 2/16/18
## Author: Mitch Murphy
##################################################

init <- function () {
  library(data.table)
  projectDirectory <<- file.path(dirname(sys.frame(1)$ofile))
  figureDirectory <<- paste(projectDirectory, "figure", sep = "/")
  
  
  setwd(projectDirectory)
  
  # now get the data directory
  setwd("../../../data")
  dataDirectory <<- getwd()
  # finally reset the working directory to the project directory
  setwd(projectDirectory)
  
  options(tz="America/New_York")
  Sys.setenv(TZ="America/New_York")
}


load_data <- function(zipURL = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip") {
  # Ensure that the UCI data exists in the current working directory.
  # If it does not, download the zip file and then unzip it
  # 
  # Args: zipURL - string representing the URL where the zip file exists
  # Returns: nothing, but set global variables (storing the data)
  
  # change to the data directory
  setwd(dataDirectory)
  
  dataFile <- paste(dataDirectory, "household_power_consumption.txt", sep = "/")
  # check if file exists, if not download and unzip the data from zipURL
  if(!file.exists(dataFile) ) {
    zipFile <- "household_power_consumption.zip"
    download.file(zipURL, destfile = zipFile)
    unzip(zipfile = zipFile)
    file.remove(zipFile)
  }
  # only read in one date? from a dataset of over 2 million? seems dumb
  
  #2007-02-02
  
  ## we only want the dates 2007-02-01 and 2007-02-02
  ## the first line is column names
  cnames <- colnames(fread(dataFile, nrow=1))
  dateFormat <- "%d/%m/%Y"
  powerData <<- fread(dataFile, nrows = 2*1440, skip = 66637)
  colnames(powerData) <<- cnames
  powerData$Date <<- as.Date(powerData$Date, dateFormat)
  powerData$DateTime <<- as.POSIXct(paste(powerData$Date, powerData$Time, sep = " "), format = "%Y-%m-%d %H:%M:%S")
  
  setwd(projectDirectory)
}

plot1 <- function() {
  if(is.null(powerData)) {
    warning("Power data is not loaded.")
  } else {
    png(paste(figureDirectory, "plot1.png", sep = "/"))
    hist(powerData$Global_active_power, main="Global Active Power", col = "red", xlab="Global Active Power (kilowatts)", ylab="Frequency")
    dev.off()
  }
}

init()
load_data()
plot1()
