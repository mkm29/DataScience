library(dplyr)
library(data.table)
library(ggplot2)
library(Hmisc)

setwd("~/Developer/DataScience/projects/ReproducibleResearch/StormProject/")

if(!file.exists("StormData.csv.bz2")) {
  download.file("https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2")
}

## Data Processing
cache <- TRUE
if(cache) {
  load("stormData.RData")
} else {
  stormData <- as.data.table(read.csv("StormData.csv.bz2"))
  stormData$EVTYPE <- with(stormData, as.factor(EVTYPE))
  events <- unique(stormData$EVTYPE)
  stormData$EVTYPENUM <- match(stormData$EVTYPE, events)
  stormData$POPHEALTH <- stormData$FATALITIES + stormData$INJURIES
  stormData$TOTALDMG <- stormData$PROPDMG + stormData$CROPDMG
  stormData$DATE <- as.POSIXct(stormData$BGN_DATE, format = "%m/%d/%Y %H:%M:%S")
  stormData$YEAR <- format(stormData$DATE, "%Y")
  stormData$MONTH <- format(stormData$DATE, "%m")
  # R gets stuck somewhere here...
  #stormData$DATE <- strptime(stormData$BGN_DATE, format = "%m/%d/%Y %H:%M:%S")
}

years <- unique(stormData$YEAR)
events <- unique(stormData$EVTYPE)


## Population Health
statsByEvent <- stormData %>% group_by(EVTYPENUM) %>% arrange(desc(POPHEALTH))
statsByEvent <- statsByEvent %>% summarise(Total = sum(POPHEALTH), Fatalities = sum(FATALITIES), Injuries = sum(INJURIES), n = n())
statsByEvent <- cbind(statsByEvent, Event = events[statsByEvent$EVTYPENUM], EVTYPENUM = statsByEvent$EVTYPENUM)
statsByEvent <- statsByEvent[order(statsByEvent$Total, decreasing = T),]

topEventNums <- head(statsByEvent$EVTYPENUM, n=10)
eventsYearly <- subset(stormData, EVTYPENUM %in% topEventNums) %>% group_by(EVTYPENUM, YEAR) %>% arrange(desc(POPHEALTH)) %>% summarise(TOTAL = sum(POPHEALTH), n = n())
eventsYearly$EVENT <- events[eventsYearly$EVTYPENUM]
eventsYearly$YEAR <- as.numeric(eventsYearly$YEAR)

ggplot(eventsYearly, aes(x = YEAR, y = n, colour = EVENT)) + geom_line(aes(group = EVENT)) +
  xlab("Year") + ylab("Frequency") + ggtitle("Frequency of storms: 1950-2018")

x <- subset(eventsYearly, n >= 10000)
x2 <- subset(eventsYearly, EVENT == "TSTM WIND")
x3 <- subset(eventsYearly, EVENT == "THUNDERSTORM WINDS")

ggplot(subset(eventsYearly, YEAR >=1988), aes(x = YEAR, y = TOTAL, colour = EVENT, lty = EVENT)) + geom_line(aes(group = EVENT)) +
  xlab("Year") + ylab("Injuries + Fatalities") + ggtitle("Population Health vs. Year")

# only focus on fatalities
storms1 <- head(statsByEvent[order(statsByEvent$Fatalities, decreasing = T),c("Event", "Fatalities")], n = 10)$Event
# Only focus on injuries
storms2 <- head(statsByEvent[order(statsByEvent$Injuries, decreasing = T),c("Event", "Injuries")], n = 10)$Event
intersect(storms1, storms2)



## Economic Damages
statsByDamage <- stormData %>% group_by(EVTYPENUM) %>% arrange(desc(TOTALDMG))
statsByDamage <- statsByDamage %>% summarise(Total = sum(TOTALDMG), PropDmg = sum(PROPDMG), CropDmg = sum(CROPDMG))
statsByDamage <- cbind(statsByDamage, Event = events[statsByDamage$EVTYPENUM])
head(statsByDamage[order(statsByDamage$Total, decreasing = T),c("Event", "Total")], n = 10)

topEventNums.damage <- head(statsByDamage$EVTYPENUM, n=10)
eventsYearly.damage <- subset(stormData, EVTYPENUM %in% topEventNums.damage) %>% group_by(EVTYPENUM, YEAR) %>% arrange(desc(TOTALDMG)) %>% summarise(TOTAL = sum(TOTALDMG), n = n())
eventsYearly.damage$EVENT <- events[eventsYearly.damage$EVTYPENUM]
eventsYearly.damage$YEAR <- as.numeric(eventsYearly.damage$YEAR)

ggplot(subset(eventsYearly.damage, YEAR >= 1988), aes(x = YEAR, y = TOTAL, colour = EVENT)) + geom_line(aes(group = EVENT)) +
  xlab("Year") + ylab("Property + Crop Damage") + ggtitle("Economic Costs From Storms, 1988-2018")