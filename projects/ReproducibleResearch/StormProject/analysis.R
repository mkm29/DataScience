library(dplyr)
library(data.table)
library(ggplot2)
library(Hmisc)

setwd("~/Developer/DataScience/projects/ReproducibleResearch/StormProject/")

if(!file.exists("StormData.csv.bz2")) {
  download.file("https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2")
}


stormData <- as.data.table(read.csv("StormData.csv.bz2"))
str(stormData)


# Across the United States, which types of events (as indicated in the EVTYPE variable) 
# are most harmful with respect to population health? 
#class(stormData$EVTYPE)
stormData$EVTYPE <- with(stormData, as.factor(EVTYPE))
events <- unique(stormData$EVTYPE)
stormData$EVTYPENUM <- match(stormData$EVTYPE, events)

# health related variables: FATALITIES, INJURIES
# scale the 2 and create one variable?
#stormData$POP.HEALTH <- scale(stormData$FATALITIES.SCALED) + scale(stormData$INJURIES.SCALED)
stormData$POP.HEALTH <- stormData$FATALITIES + stormData$INJURIES


# how do we measure "population health?" 
#   we will combine fatalaties and injuries to create a new varialbe: POP.HEALTH
# interested in: EVTYPE, FATALITIES, INJURIES
statsByEvent <- stormData %>% group_by(EVTYPENUM) %>% arrange(desc(POP.HEALTH)) %>% summarise(Total = sum(POP.HEALTH),
                                                                                              Fatalities = sum(FATALITIES),
                                                                                              Injuries = sum(INJURIES))
statsByEvent <- cbind(statsByEvent, Event = events[statsByEvent$EVTYPENUM])
eventsByHealth <- data.frame(Event = statsByEvent$Event, Total = statsByEvent$Total)

# sort by POP.HEALTH (desc)
eventsByHealth <- eventsByHealth[order(eventsByHealth$Total, decreasing = T),]
head(eventsByHealth, n = 10)



## Across the United States, which types of events have the greatest economic consequences?

# PROPDMGEXP, CROPDMGEXP
stormData$TOTALDMG <- stormData$PROPDMG + stormData$CROPDMG
statsByDamage <- stormData %>% group_by(EVTYPENUM) %>% arrange(desc(TOTALDMG)) %>% summarise(Total = sum(TOTALDMG),
                                                                                              PropDmg = sum(PROPDMG),
                                                                                              CropDmg = sum(CROPDMG))
statsByDamage <- cbind(statsByDamage, Event = events[statsByDamage$EVTYPENUM]) #%>% select(Event, PropDmg, DropDmg)
eventsByDamage <- data.frame(Event = statsByDamage$Event, TotalDamage = statsByDamage$Total)
# sort by TotalDamage (decreasing)
eventsByDamage <- eventsByDamage[order(eventsByDamage$TotalDamage, decreasing = TRUE),]
head(eventsByDamage, n = 10)
