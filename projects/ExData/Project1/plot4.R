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

plot4 <- function() {
  if(is.null(powerData)) {
    warning("Power data is not loaded.")
  } else {
    png(paste(figureDirectory, "plot4.png", sep = "/"))
    
    # setup plot layout
    par(mfrow=c(2,2))
    # plot 1
    plot(powerData$DateTime, powerData$Global_active_power, type="l", xlab="", ylab="Global Active Power")
    # plot 2
    plot(powerData$DateTime, powerData$Voltage, type="l", xlab="datetime", ylab="Voltage")
    # plot 3
    plot(x = powerData$DateTime, y = powerData$Sub_metering_1, type="l", xlab="", ylab="Energy sub metering")
    lines(powerData$DateTime, powerData$Sub_metering_2, col = "red")
    lines(powerData$DateTime, powerData$Sub_metering_3, col = "blue")
    legend("topright", col=c("black","red","blue"), legend = c("Sub_metering_1","Sub_metering_2", "Sub_metering_3"), lty=c(1,1), bty="n", cex = 0.5)
    
    # plot 4
    plot(powerData$DateTime, powerData$Global_reactive_power, type="l", xlab="datetime", ylab="Global_reactive_power")
    
    dev.off()
  }
}

init()
load_data()
plot4()