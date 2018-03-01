##################################################
## Project: Exploratory Data Analysis: Course Project 2
## Script:  Take a closer look at fine PM2.5 data, provided by EPA (NEI data)
##          http://www.epa.gov/ttn/chief/eiinformation.html
## Source:  https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip
## Date:    3/1/18
## Author:  Mitch Murphy
##################################################



init <- function() {
  
  library(data.table)
  library(dplyr)
  
  projDir <<- file.path(dirname(sys.frame(1)$ofile))
  setwd(projDir)
  # get data directory
  setwd("../../../data")
  dataDirectory <- getwd()
  setwd(projDir)
  
  Resources <- data.frame(INIT = TRUE,
                           DATA.READ = FALSE,
                           DATA.TIDY = FALSE,
                           ProjectDirectory = projDir,
                           DataDirectoy = dataDirectory)
  
  #with(Resources, ProjectDirectory = as.character(ProjectDirectory), DataDirectoy = as.character(DataDirectoy))
  Resources$ProjectDirectory <- with(Resources, as.character(ProjectDirectory))
  Resources$DataDirectoy <- with(Resources, as.character(DataDirectoy))
  return(Resources)
}

downloadData <- function(zipURL = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip") {
  if(class(Resources$DataDirectoy) != "character") {
    stop("Data directory is not of character type.")
  }
  
  setwd(Resources$DataDirectoy)
  
  Resources$DataDirectoy <<- paste(Resources$DataDirectoy, "NEI", sep = "/")
  
  # check if data already exists
  if(dir.exists("NEI")) {
    return()
  }
  
  # does zip file already exist?
  if(!file.exists("NEI.zip")) {
    download.file(zipURL, destfile = "NEI.zip")
  }
  
  unzip("NEI.zip", exdir = "NEI")
  file.remove("NEI.zip")
}


loadData <- function() {
  # check if data directory exists
  downloadData()
  
  # now load the rds files
  setwd(Resources$DataDirectoy)
  
  
  SCC <<- readRDS("Source_Classification_Code.rds")
  # the following is a large dataset (~ 6.5 million records) so will take between 20 and 30 seconds to load
  NEI <<- readRDS("summarySCC_PM25.rds")
  Resources$DATA.READ <<- TRUE
  
  
  
  setwd(Resources$ProjectDirectory)
}



Resources <- init()
loadData()
