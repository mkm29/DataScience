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
yearly <- NEI.SCC %>% group_by(year) %>% summarise(TotalEmissions = sum(Emissions), 
                                                   MeanEmissions = mean(Emissions), 
                                                   MedianEmissions = median(Emissions), 
                                                   Observations = n())
r <- c(0, 800+range(yearly$TotalEmissions)[2]/1000)
setwd("../")
png(filename = "plot1.png", width = 800, height = 600)
par(mfrow = c(1,1)); plot.new();
p1 <- barplot(height = yearly$TotalEmissions/1000, names.arg = yearly$year, 
              ylab = "Total PM2.5 Emissions in kilotons", 
              main = "PM2.5 Emissions, United States 1999-2008", 
              col = c("green", "blue", "purple", "red"), xlab = "Year", ylim = r)
text(x = p1, y = round(yearly$TotalEmissions/1000,0), 
     labels = round(yearly$TotalEmissions/1000,0), pos = 3)
dev.off()