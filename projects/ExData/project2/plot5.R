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
baltimore <- NEI.SCC %>% filter(fips == "24510") 
baltimore.highway <- subset(baltimore, Highway == TRUE)  %>% summarise(Total = sum(Emissions), Emissions = median(Emissions))
baltimore <- baltimore %>% group_by(year, Highway) %>% summarise(Total = sum(Emissions), Emissions = median(Emissions))

png(filename = "plot5.png", width = 1000, height = 800)
par(mfrow = c(2,1)); plot.new();
yLabel <- expression("Total PM"[2.5]*" emission in tons")

p1 <- ggplot(baltimore.highway, aes(x = year, y = Total, fill = year)) + 
  geom_bar(stat = "identity") + 
  ylab(yLabel) + 
  ggtitle(expression("Total PM"[2.5]*" emission in kilotons, Baltimore 1999-2008")) 
p2 <- ggplot(baltimore, aes(x=year, y=Total/1000)) + 
  geom_line(aes(col = Highway)) +
  ylab(yLabel)
grid.newpage()
grid.arrange(p1, p2)
dev.off()