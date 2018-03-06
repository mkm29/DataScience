library(data.table)
library(dplyr)
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
baltimore <- NEI.SCC %>% filter(fips == "24510") %>% group_by(year) %>% summarise(MeanEmissions = mean(Emissions), MedianEmissions = median(Emissions))
# because the mean is more sensitive to outtliers we will use the median
par(mfrow = c(1,1))
setwd("../")
png(filename = "plot2.png", width = 800, height = 600)
plot(x=baltimore$year, y=baltimore$MedianEmissions, col = "blue", lwd = 2, lty = 2, xlab = "Year", ylab = "Emission Value", main = "PM2.5 Emissions, Baltimore 1999-2008", type = "l")
dev.off()