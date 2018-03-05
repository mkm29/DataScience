##################################################
## Project: Exploratory Data Analysis: Course Project 2
## Script:  Take a closer look at fine PM2.5 data, provided by EPA (NEI data)
##          http://www.epa.gov/ttn/chief/eiinformation.html
## Source:  https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip
## Date:    3/1/18
## Author:  Mitch Murphy
##################################################



init <- function() {
  
  library(data.table)
  library(dplyr)
  library(ggplot2)
  library(tidyr)
  library(grid)
  library(gridExtra)
  library(reshape2)
  
  if (!require("RColorBrewer")) {
    install.packages("RColorBrewer")
    library(RColorBrewer)
  }
  
  projDir <<- file.path(dirname(sys.frame(1)$ofile))
  setwd(projDir)
  # get data directory
  setwd("../../../data")
  dataDirectory <- getwd()
  setwd(projDir)
  
  blues <- brewer.pal(8,"Blues")
  reds <- brewer.pal(8,"Reds" )
  greens <- brewer.pal(8, "Greens")
  purples <- brewer.pal(8, "Purples")
  colors <- list(blue = blues, red = reds, purple = purples, green = greens)
  
  Resources <- data.frame(INIT = TRUE,
                           DATA.READ = FALSE,
                           DATA.TIDY = FALSE,
                           ProjectDirectory = projDir,
                           DataDirectoy = dataDirectory, 
                           FigureDirectory = as.character(paste(projDir, "figure", sep = "/")),
                           Colors = colors)
  
  #with(Resources, ProjectDirectory = as.character(ProjectDirectory), DataDirectoy = as.character(DataDirectoy))
  Resources$ProjectDirectory <- with(Resources, as.character(ProjectDirectory))
  Resources$DataDirectoy <- with(Resources, as.character(DataDirectoy))
  
  return(Resources)
}

downloadData <- function(zipURL = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip") {
  if(class(Resources$DataDirectoy) != "character") {
    stop("Data directory is not of character type.")
  }
  
  setwd(Resources$DataDirectoy)
  
  Resources$DataDirectoy <<- paste(Resources$DataDirectoy, "NEI", sep = "/")
  
  # check if data already exists
  if(dir.exists("NEI")) {
    return()
  }
  
  # does zip file already exist?
  if(!file.exists("NEI.zip")) {
    download.file(zipURL, destfile = "NEI.zip")
  }
  
  unzip("NEI.zip", exdir = "NEI")
  file.remove("NEI.zip")
}


loadData <- function() {
  # check if data directory exists
  downloadData()
  
  # now load the rds files
  setwd(Resources$DataDirectoy)
  
  
  SCC <- readRDS("Source_Classification_Code.rds")
  SCC$Option.Group <- with(SCC, as.character(Option.Group))
  optionGroups <- unique(SCC$Option.Group)
  # need to add the mapping from Option.Group (string) to unique ID (optionGroups)
  SCC$Option.Group.Unique <- match(SCC$Option.Group, optionGroups)
  
  # the following is a large dataset (~ 6.5 million records) so will take between 20 and 30 seconds to load
  NEI <- readRDS("summarySCC_PM25.rds")
  NEI.SCC <<- merge.data.frame(NEI, SCC, by = "SCC")
  
  counties <- unique(NEI.SCC$fips)
  NEI.SCC$CountyCode <<- match(NEI.SCC$fips, counties)
  NEI.SCC$Short.Name <<- with(NEI.SCC, as.character(Short.Name))
  
  # add a column if coal is in the Short.Name
  NEI.SCC$Coal <<- with(NEI.SCC, grepl("[Cc]oal", Short.Name, perl = T))
  NEI.SCC$Highway <<- with(NEI.SCC, grepl("[Hh]ighway", Short.Name, perl = T))
  
  
  
  Resources$DATA.READ <<- TRUE
  setwd(Resources$ProjectDirectory)
}

grid.ftable <- function(d, padding = unit(4, "mm"), ...) {
  
  nc <- ncol(d)
  nr <- nrow(d)
  
  ## character table with added row and column names
  extended_matrix <- cbind(c("", rownames(d)),
                           rbind(colnames(d),
                                 as.matrix(d)))
  
  ## string width and height
  w <- apply(extended_matrix, 2, strwidth, "inch")
  h <- apply(extended_matrix, 2, strheight, "inch")
  
  widths <- apply(w, 2, max)
  heights <- apply(h, 1, max)
  
  padding <- convertUnit(padding, unitTo = "in", valueOnly = TRUE)
  
  x <- cumsum(widths + padding) - 0.5 * padding
  y <- cumsum(heights + padding) - padding
  
  rg <- rectGrob(x = unit(x - widths/2, "in"),
                 y = unit(1, "npc") - unit(rep(y, each = nc + 1), "in"),
                 width = unit(widths + padding, "in"),
                 height = unit(heights + padding, "in"))
  
  tg <- textGrob(c(t(extended_matrix)), x = unit(x - widths/2, "in"),
                 y = unit(1, "npc") - unit(rep(y, each = nc + 1), "in"),
                 just = "center")
  
  g <- gTree(children = gList(rg, tg), ...,
             x = x, y = y, widths = widths, heights = heights)
  
  grid.draw(g)
  invisible(g)
}



getStatsForYear <- function(filterYear, outlierProb = 0.95) {
  
  # 1 - group by CountyCode
  data.counties <- NEI.SCC %>% filter(year == filterYear) %>% group_by(CountyCode) %>% summarise(MeanEmissions = mean(Emissions), MedianEmissions = median(Emissions))
  data.counties <- as.data.frame(data.counties)
  
  
  threshold <- quantile(data.counties$MedianEmissions, probs = c(0.95))
  outliers <- subset(data.counties, MedianEmissions >= threshold)
  thresholdColname <- paste0(100*outlierProb,"%")
  
  
  data.counties.sd.mean <- sd(data.counties$MeanEmissions) # 8.702102
  data.counties.quantile.mean <- quantile(data.counties$MeanEmissions, probs = c(0.5,outlierProb))
  data.counties.mean <- data.frame(stdDev = data.counties.sd.mean, "50%" = data.counties.quantile.mean[1], thresholdColname = data.counties.quantile.mean[2])
  data.counties.sd.mediann <- sd(data.counties$MedianEmissions) # 0.14516
  data.counties.quantile.median <- quantile(data.counties$MedianEmissions, probs = c(0.5,outlierProb))
  data.counties.median <- data.frame(stdDev = data.counties.sd.mediann, "50%" = data.counties.quantile.median[1], thresholdColname = data.counties.quantile.median[2])
  colnames(data.counties.mean) <- c("stdDev", "50%", thresholdColname)
  colnames(data.counties.median) <- colnames(data.counties.mean)
  data.counties.stats <- rbind(data.counties.mean, data.counties.median)
  rownames(data.counties.stats) <- c("Mean", "Median")
  
  
  # create a list containing all of these variables
  dataList <- list(data = data.counties, threshold = threshold, outliers = outliers, stats = data.counties.stats)
  return(dataList)
}


Resources <- init()
loadData()


analysis <- function() {
  
  ####### Question 1  ####### 
  # Have total emissions from PM2.5 decreased in the United States from 1999 to 2008? Using the base plotting system, 
  # make a plot showing the total PM2.5 emission from all sources for each of the years 1999, 2002, 2005, and 2008.
  us.yearly <- NEI.SCC %>% group_by(year) %>% summarise(MeanEmissions = mean(Emissions), MedianEmissions = median(Emissions), Observations = n())
  us.counties <- NEI.SCC %>% group_by(year, CountyCode) %>% summarise(MeanEmissions = mean(Emissions), MedianEmissions = median(Emissions), Observations = n())
  
  us.1999 <- getStatsForYear(1999)
  us.2002 <- getStatsForYear(2002)
  us.2005 <- getStatsForYear(2005)
  us.2008 <- getStatsForYear(2008)
  
  # lets find the counties that were "repeat violators"...they were in the top 5% every year...
  a <- merge.data.frame(us.1999$outliers, us.2002$outliers, by = "CountyCode")
  b <- merge.data.frame(us.2005$outliers, us.2008$outliers, by = "CountyCode")
  repeatViolators <- merge.data.frame(a, b, by = "CountyCode")
  counties <- unique(NEI.SCC$fips)
  rm(a); rm(b); rm(counties);
  badCounties <- as.data.frame(counties[repeatViolators$CountyCode])
  
  # due to the contributions from outliers, the median looks more promising to use over the mea

  
  
  setwd(Resources$FigureDirectory)
  
  ## Personally I prefer this plot, as it is more descriptive.
  png(filename = "plot1.png", width = 800, height = 800)
  plot.new()
  grid.newpage()
  heights = unit(c(0.1,0.35,0.35,0.2), "npc")
  pushViewport(viewport(layout = grid.layout(4, 1, heights = heights)))
  grid.text("Emissions (PM2.5), United States 1999-2012", vp = viewport(layout.pos.row = 1, layout.pos.col = 1), gp=gpar(fontsize=18, fontface = "bold"))
  print(qplot(x = us.yearly$year, y = log10(us.yearly$MeanEmissions), geom = "line", xlab = "Year", ylab = "Log of Mean Emissions"), vp = viewport(layout.pos.row = 2, layout.pos.col = 1))
  print(qplot(x = us.yearly$year, y = log10(us.yearly$MedianEmissions), geom = "line", xlab = "Year", ylab = "Log of Median Emissions"), vp = viewport(layout.pos.row = 3, layout.pos.col = 1))
  grid.table(us.yearly, vp = viewport(layout.pos.row = 4, layout.pos.col = 1), rows = NULL)
  dev.off()
 
  
   
  
  ####### Question 2  #######   
  # Have total emissions from PM2.5 decreased in the Baltimore City, Maryland (fips == "24510") from 1999 # to 2008? 
  # Use the base plotting system to make a plot answering this question.
  
  baltimore <- subset(NEI.SCC, fips == "24510")
  mycol <- rgb(0, 0, 255, max = 255, alpha = 125, names = "blue50")
  baltimore.summary <- baltimore %>% group_by(year) %>% summarise(MeanEmissions = mean(Emissions), MedianEmissions = median(Emissions), Observations = n())
  # hard to tell visually due to the outliers. lets remove them and replot <96%
  baltimore.outliers.removed <- subset(baltimore, Emissions < quantile(baltimore$Emissions, probs = 0.95))
  
  png(filename = "plot2.png", width = 1000, height = 800)
  bl <- baltimore %>% group_by(year) %>% summarise(MeanEmissions = mean(Emissions), MedianEmissions = median(Emissions))
  par(mfrow = c(1,1))
  plot.new()
  plot(x=bl$year, y = log10(bl$MedianEmissions), xlab = "Year", ylab = "Log of PM2.5 Emission", main = "Emissions, Baltimore 1999-2008", type = "l", col = Resources$Colors.purple[3])
  dev.off()
  
  png(filename = "plot2a.png", width = 1000, height = 800)
  par(mfrow = c(1,1))
  plot.new()
  plot(log10(baltimore$Emissions), pch = 19, col = mycol, xlab = "", ylab = "Log of PM2.5 Value", main = "Emissions, Baltimore 1999-2008")
  dev.off()
  
  
  
  
   ####### Question 3  #######   
  # Of the four types of sources indicated by the 𝚝𝚢𝚙𝚎 (point, nonpoint, onroad, nonroad) variable, which of these four sources h
  # ave seen decreases in emissions from 1999–2008 for Baltimore City? Which have seen increases in emissions from 1999–2008? 
  # Use the ggplot2 plotting system to make a plot answer this question.
  baltimore.types <- baltimore %>% group_by(type, year) %>% summarise(Mean = mean(Emissions), Median = median(Emissions))
  class(baltimore.types$type)
  baltimore.types$type <- with(baltimore.types, as.factor(type))
  
  setwd(as.character(Resources$FigureDirectory))
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
  
  
  
  outliers <- NEI.SCC %>% filter(Emissions >= 2.82)
  
  # should we make coal great again :)
  outliers %>% group_by(year) %>% summarise(Mean = mean(Emissions), Median = median(Emissions))
  outliers.coal <- subset(outliers, Coal == TRUE)
  outliers.highway <- subset(outliers, Highway == TRUE)
  # no we definitely should not!
  outliers.coal %>% group_by(year) %>% summarise(Mean = mean(Emissions), Median = median(Emissions))
  outliers.highway %>% group_by(year) %>% summarise(Mean = mean(Emissions), Median = median(Emissions))
  outliers %>% group_by(type) %>% summarise(Mean = mean(Emissions), Median = median(Emissions))
  
  
  
  
  ####### Question 4  ####### 
  # Across the United States, how have emissions from coal combustion-related sources changed from 1999–2008?
  
  coal.summary <- NEI.SCC %>% filter(Coal == FALSE) %>% summarise(Mean = mean(Emissions), Median = median(Emissions))
  coal.summary <- rbind(coal.summary, NEI.SCC %>% filter(Coal == TRUE) %>% summarise(Mean = mean(Emissions), Median = median(Emissions)))
  rownames(coal.summary) <- c("Non-coal", "Coal")
  
  
  coal.yearly.summary <- NEI.SCC %>% filter(Coal == FALSE) %>% group_by(year) %>% summarise(Mean = mean(Emissions), Median = median(Emissions))
  coal.yearly.summary <- rbind(coal.yearly.summary, NEI.SCC %>% filter(Coal == TRUE) %>% group_by(year) %>% summarise(Mean = mean(Emissions), Median = median(Emissions)))
  
  yearly.coal <- NEI.SCC %>% group_by(year, Coal) %>% summarise(Mean = mean(Emissions), Median = median(Emissions))
  
  setwd(as.character(Resources$FigureDirectory))
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
  
  ####### Question 5  ####### 
  # How have emissions from motor vehicle sources changed from 1999–2008 in Baltimore City?
  
  png(filename = "plot5.png", width = 1000, height = 800)
  baltimore.highway <- NEI.SCC %>% group_by(year, Highway) %>% summarise(Mean = mean(Emissions), Median = median(Emissions))
  p1 <- ggplot(baltimore.highway, aes(year, log10(Mean))) +
    geom_line(aes(col = as.factor(Highway))) + 
    scale_color_manual(labels = c("Non-vehicular", "Vehicle"), values = c("red", "blue")) +
    ggtitle("Mean Emissions, per type 1999-2008")
  p1$labels$colour <- "Type"
  p1$labels$x <- "Year"
  p2 <- ggplot(baltimore.highway, aes(year, log10(Median))) +
    geom_line(aes(col = as.factor(Highway))) + 
    scale_color_manual(labels = c("Non-vehicular", "Vehicle"), values = c("red", "blue")) +
    ggtitle("Median Emissions, per type 1999-2008")
  p2$labels$colour <- "Type"
  p2$labels$x <- "Year"
  grid.newpage()
  grid.arrange(p1, p2)
  dev.off()
  
  ####### Question 6  ####### 
  # Compare emissions from motor vehicle sources in Baltimore City with emissions from motor vehicle sources in Los Angeles County, California (fips == "06037")
  # Which city has seen greater changes over time in motor vehicle emissions?
  baltimore.highway <- NEI.SCC %>% filter(fips == "24510" & Highway == TRUE) %>% group_by(year) %>% summarise(MeanEmissions = mean(Emissions), MedianEmissions = median(Emissions))
  df <- as.data.frame(baltimore.highway)
  df$City <- as.factor(rep("Baltimore",4))
  la.highway <- NEI.SCC %>% filter(fips == "06037" & Highway == TRUE) %>% group_by(year) %>% summarise(MeanEmissions = mean(Emissions), MedianEmissions = median(Emissions))
  la.highway <- as.data.frame(la.highway)
  la.highway <- cbind(la.highway, City = as.factor(rep("LA",4)))
  df <- rbind(df, la.highway)
  
  png(filename = "plot6.png", width = 1000, height = 800)
  p1 <- ggplot(df, aes(year, log10(MeanEmissions))) +
    geom_line(aes(col = City)) +
    ggtitle("Mean Emissions, 1999-2008")
  p2 <- ggplot(df, aes(year, log10(MedianEmissions))) +
    geom_line(aes(col = City)) +
    ggtitle("Median Emissions, 1999-2008")
  p1$labels$y <- "log of Mean"
  p2$labels$y <- p1$labels$y
  grid.newpage()
  grid.arrange(p1,p2)
  dev.off()
}

furtherAnalysis <- function() {
  # construct ylim range
  r1 <- range(yearly$NormMean)
  r2 <- range(yearly$NormMedian)
  r <- c(min(r1,r2), max(r1,r2))
  
  plot(x=yearly$year, y=yearly$NormMean, type = "l", lwd = 2, col = "blue", ylim = r)
  plot.new()
  plot(x=yearly$year, y=yearly$NormMedian, type = "l", lwd = 2, col = "red", ylim = r)
  
}
