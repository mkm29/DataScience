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
baltimore.types <- baltimore %>% group_by(type, year) %>% summarise(Total = sum(Emissions))
baltimore.types$type <- with(baltimore.types, as.factor(type))

setwd("../")
png(filename = "plot3.png", width = 1000, height = 800)
#   for this plot, you will have 4 lines (one for each type), the x axis is the year and the y is the 
#   mean emissions
#baltimore.types$Total <- with(baltimore.types, Total/1000)
yLabel <- expression("PM"[2.5]*" emission in tons")
p1 <- ggplot(baltimore.types, aes(x = year, y = Total, fill=type, 
                                  labesl = round(baltimore.types$Total,2))) + 
  geom_bar(stat = "identity") + 
  facet_grid(. ~ type) +
  ylab(yLabel) + 
  ggtitle(expression("Total PM"[2.5]*" emissions in Baltimore, 199902998"))
p2 <- ggplot(baltimore.types, aes(year, Total)) + 
  geom_line(aes(col = type)) +
  ylab(yLabel)
grid.newpage()
grid.arrange(p1,p2)
dev.off()

plot(baltimore.highway$year, baltimore.highway$Emissions, type = "l", lwd = 2, col = "blue", 
     xlab = "Year", ylab = yLabel, main = "Emissions, 1999-2008")
par(new = TRUE)
plot(la.highway$year, la.highway$Emissions, type = "l", lwd = 2, col = "red", lty = 2,
     xlab = "Year", ylab = yLabel, main = "Emissions, 1999-2008")
legend("topright", legend = c("Los Angeles", "Baltimore"), col = c("red", "blue"), lty = c(1,2))
