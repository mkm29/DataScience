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
yearly <- NEI.SCC %>% group_by(year) %>% summarise(MeanEmissions = mean(Emissions), MedianEmissions = median(Emissions), Observations = n())
r1 <- range(log10(yearly$MeanEmissions))
r2 <- range(log10(yearly$MedianEmissions))
r <- c(min(r1,r2), max(r1,r2))
setwd("../")
png(filename = "plot1.png", width = 800, height = 600)
par(mfrow = c(2,1))
barplot(yearly$MedianEmissions, names.arg = yearly$year, ylab = "Emission Value", main = "PM2.5 Emissions, United States 1999-2008", col = c("green", "blue", "purple", "red"), xlab = "Year")
plot(x=yearly$year, y = log10(yearly$MeanEmissions), ylim = r, type = "l", col = "red", xlab = "Year", ylab = "Log of PM2.5 Value", main = "Emissions, United States 1999-2008")
par(new = TRUE)
plot(x=yearly$year, y = log10(yearly$MedianEmissions), ylim = r, type = "l", col = "blue", xlab = "Year", ylab = "Log of PM2.5 Value")
legend("topright", legend = c("Mean", "Median"), col = c("red", "blue"), lty=c(1,1))
dev.off()