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
baltimore <- NEI.SCC %>% filter(fips == "24510") %>% group_by(year) %>% summarise(TotalEmissions = sum(Emissions), MeanEmissions = mean(Emissions), MedianEmissions = median(Emissions))
# because the mean is more sensitive to outtliers we will use the median
par(mfrow = c(1,1))
setwd("../")
png(filename = "plot2.png", width = 800, height = 600)
r <- c(0, round(range(baltimore$TotalEmissions/1000)[2],0)+1)
par(mfrow = c(1,1)); plot.new();
p1 <- barplot(height = baltimore$TotalEmissions/1000, names.arg = baltimore$year, ylab = "Total PM2.5 Emissions in kilotons", main = "PM2.5 Emissions,Baltimore 1999-2008", col = c("green", "blue", "purple", "red"), xlab = "Year", ylim = r)
text(x = p1, y = round(baltimore$TotalEmissions/1000,2), labels = round(yearly$TotalEmissions/1000,0), pos = 3, cex = 1)
dev.off()