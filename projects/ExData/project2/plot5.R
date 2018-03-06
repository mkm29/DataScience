library(data.table)
library(dplyr)
library(ggplot2)
library(grid)
library(gridExtra)
setwd("~/Desktop/DataScience/coursera/projects/ExData/project2")
zipURL = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
if(!dir.exists("NEI")) {
  if(!file.exists("NEI.zip")) {
    download.file(zipURL, destfile = "NEI.zip")
  }
}
unzip("NEI.zip", exdir = "NEI")
setwd(paste(getwd(),"NEI",sep = "/"))
SCC <- readRDS("Source_Classification_Code.rds")
NEI <- readRDS("summarySCC_PM25.rds")
NEI.SCC <- merge.data.frame(NEI, SCC, by = "SCC")
NEI.SCC$Highway <- with(NEI.SCC, grepl("[Hh]ighway", Short.Name, perl = T))
baltimore.highway <- NEI.SCC %>% filter(Highway == TRUE) %>% group_by(year) %>% summarise(Emissions = median(Emissions))

png(filename = "plot5.png", width = 1000, height = 800)
plot(x=baltimore.highway$year, y = baltimore.highway$Emissions, xlab = "Year", ylab = "Emission Value", main = "Motor Vehicle Emissions, Baltimore 1999-2008", type = "l", lwd = 2, col = "blue")
dev.off()