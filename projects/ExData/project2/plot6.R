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

baltimore.highway <- subset(NEI.SCC, fips == "24510" & Highway == TRUE) %>% group_by(year) 
baltimore.highway <- baltimore.highway %>% summarise(Total = sum(Emissions), Emissions = median(Emissions))
la.highway = subset(NEI.SCC, fips == "06037" & Highway == TRUE) %>% group_by(year) 
la.highway <- la.highway %>% summarise(Total = sum(Emissions), Emissions = median(Emissions))
df <- data.frame(Year = as.factor(c(baltimore.highway$year, la.highway$year)), 
                 Total = c(baltimore.highway$Total, la.highway$Total), 
                 Emissions = c(baltimore.highway$Emissions, la.highway$Emissions),
                 City = as.factor(c(rep("Baltimore",4),rep("Los Angeles",4))))



# we need to get the total's on the same scale for comparison plots
r <- c(0,max(range(baltimore.highway$Total), range(la.highway$Total))+500)
yLabel <- expression("Total PM"[2.5]*" emission in tons")
png(filename = "plot6.png", width = 800, height = 600)
par(mfrow = c(1,1), mar=c(5, 4, 4, 8) + 0.1); plot.new()
p1 <- barplot(height = la.highway$Total, names.arg = la.highway$year, ylab = yLabel, 
              xlab = "Year", col = "red", ylim = r)
text(x = p1, y = round(la.highway$Total,0), labels = round(la.highway$Total,0), pos = 3)
par(new = TRUE)
p2 <- barplot(height = baltimore.highway$Total, names.arg = baltimore.highway$year, ylab = yLabel, 
              main = expression("PM"[2.5]*" Emissions, United States 1999-2008"), col = "blue", 
              xlab = "Year", ylim = r)
legend("topright", legend = c("Los Angeles", "Baltimore"), lty = c(1,1), col = c("red", "blue"))
text(x = p2, y = round(baltimore.highway$Total,0)+100, labels = round(baltimore.highway$Total,0), 
     pos = 3, col = "white")

dev.off()