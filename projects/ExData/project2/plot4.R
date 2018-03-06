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
NEI.SCC$Coal <- with(NEI.SCC, grepl("[Cc]oal", Short.Name, perl = T))

yearly.coal <- NEI.SCC %>% group_by(year, Coal) %>% summarise(Mean = mean(Emissions), Median = median(Emissions))

setwd("../")
png(filename = "plot4.png", width = 1000, height = 800)
coalPlot1 <- ggplot(yearly.coal, aes(year, log10(Mean))) +
  geom_line(aes(col = as.factor(Coal))) + 
  scale_color_manual(labels = c("Non-coal", "Coal"), values = c("red", "blue")) +
  ggtitle("Mean Emissions 1999-2008")
coalPlot2 <- ggplot(yearly.coal, aes(year, log10(Median))) +
  geom_line(aes(col = as.factor(Coal))) + 
  scale_color_manual(labels = c("Non-coal", "Coal"), values = c("red", "blue")) +
  ggtitle("Median Emissions 1999-2008")
coalPlot1$labels$colour <- ""
coalPlot2$labels$colour <- ""
plot.new()
grid.newpage()
grid.arrange(coalPlot1, coalPlot2)
dev.off()