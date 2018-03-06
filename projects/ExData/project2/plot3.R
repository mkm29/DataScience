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
baltimore <- subset(NEI.SCC, fips == "24510")
baltimore.types <- baltimore %>% group_by(type, year) %>% summarise(Mean = mean(Emissions), Median = median(Emissions))
baltimore.types$type <- with(baltimore.types, as.factor(type))

setwd("../")
png(filename = "plot3.png", width = 1000, height = 800)
# for this plot, you will have 4 lines (one for each type), the x axis is the year and the y is the mean emissions
p1 <- ggplot(baltimore.types, aes(year, log10(Mean))) + 
  geom_line(aes(col = type)) +
  ggtitle("Mean Emissions, per type 1999-2008")

p2 <- ggplot(baltimore.types, aes(year, log10(Median))) +
  geom_line(aes(col = type)) +
  ggtitle("Median Emissions, per type 1999-2008")
plot.new()
grid.newpage()
grid.arrange(p1, p2, ncol = 1, nrow = 2)
dev.off()