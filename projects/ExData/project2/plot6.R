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

baltimore.highway <- subset(NEI.SCC, fips == "24510" & Highway == TRUE) %>% group_by(year) %>% summarise(Emissions = median(Emissions))
la.highway = subset(NEI.SCC, fips == "06037" & Highway == TRUE) %>% group_by(year) %>% summarise(Emissions = median(Emissions))
r1 <- range(baltimore.highway$Emissions)
r2 <- range(la.highway$Emissions)
r <- c(min(r1,r2), max(r1,r2))

png(filename = "plot6.png", width = 800, height = 600)
plot(x=baltimore.highway$year, y=baltimore.highway$Emissions, xlab = "Year", ylab = "Emission Value", main = "Motor Vehicle Emissions, Baltimore vs. L.A.", ylim = r, type = "l", lwd = 2, col = "blue")
par(new = TRUE)
plot(x=la.highway$year, y=la.highway$Emissions, xlab = "Year", ylab = "Emission Value", ylim = r, col = "red", lwd = 2, lty = 2, type = "l")
legend("topright", legend = c("Los Angeles", "Baltimore"), lty = c(1,1), col = c("red", "blue"))
dev.off()