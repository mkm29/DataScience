library(dplyr)
library(ggplot2)
library(grid)
library(gridExtra)
library(RColorBrewer)
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
# should I use Short.Name of EI.Sector? Checked, both appear to be equivalent
NEI.SCC$Coal <- with(NEI.SCC, grepl("[Cc]oal", Short.Name, perl = T))
#NEI.SCC$Coal2 <- with(NEI.SCC, grepl("[Cc]oal", EI.Sector, perl = T))
yearly <- NEI.SCC %>% group_by(year, Coal) %>% summarise(Total = sum(Emissions))
yearly.coal <- subset(yearly, Coal == TRUE)
setwd("../")
png(filename = "plot4.png", width = 1000, height = 800)
yLabel <- expression("Total PM"[2.5]*" emission in kilotons")

par(mfrow = c(2,1)); plot.new();

p1 <- ggplot(yearly.coal, aes(x = year, y = Total/1000, label = round(yearly.coal$Total/1000,2),
                              fill = year)) + 
  geom_bar(stat = "identity") + 
  ylab(yLabel) + 
  ggtitle(expression("Total PM"[2.5]*" emission in kilotons, United States 1999-2008"))
r <- range(yearly$Total/1000)
p2 <- ggplot(yearly, aes(x=year, y=Total/1000)) + 
  geom_line(aes(col = Coal)) +
  ylim(r[1]-50, r[2]+50) +
  ylab(yLabel)
plot.new()
grid.newpage()
grid.arrange(p1, p2)
dev.off()