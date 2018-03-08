library(dplyr)
library(ggplot2)
library(stringr)
setwd("~/Desktop/DataScience/coursera/projects/ExData/project2/data")


SCC <- readRDS("Source_Classification_Code.rds")
NEI <- readRDS("summarySCC_PM25.rds")
#NEI$fips <- with(NEI, as.factor(fips))
# lets split fips into its state and county code
NEI$StateNum <- with(NEI, substring(fips, 1, 2))
NEI$CountyNum <- with(NEI, substring(fips, 3, 5))
states <- read.csv("stateLookup.csv")$StateName
states <- gsub("(?<=^|; )([a-z])", "\\U\\1", tolower(states), perl = T)
# split up fips into a state and county code


# SSCCC (2 digits for the state, followed by 3 for the county)
fips <- readLines("fips.csv")
x <- str_match(fips, "^.*(\\d{5})\\s+(.*)$")
fips.lookup <- matrix(x[,3], nrow = length(x[,3]))
rm(x);




# testing

code <- sam


code <- strsplit(x,"    ")[[1]][2]
stateCode <- strsplit(code,"\\d\\d")






# ie to lookup state #s, must pad it with three 0's: s000

stateNum <- str_match(x[,2], "^(\\d{2})\\d{3}$")[,2]
fips.lookup <- data.frame(fips = x[,2], CountyName = x[,3], StateNum = stateNum)

rm(fips); rm(x);
#NEI.SCC$Coal <<- with(NEI.SCC, grepl("[Cc]oal", Short.Name, perl = T))
# need to capture counties with RegEx!
counties.1999 <- subset(NEI, year == 1999)
totals.1999 <- counties.1999 %>% group_by(StateNum) %>% summarise(Total.1999 = sum(Emissions))
df <- merge.data.frame(stateLookup, totals.1999, by = "StateNum")
counties.2002 <- subset(NEI, year == 2002)
totals.2002 <- counties.2002 %>% group_by(StateNum) %>% summarise(Total.2002 = sum(Emissions))
df <- merge.data.frame(df, totals.2002[,c("StateNum", "Total.2002")], by = "StateNum")
counties.2005 <- subset(NEI, year == 2005)
totals.2005 <- counties.2002 %>% group_by(StateNum) %>% summarise(Total.2005 = sum(Emissions))
df <- merge.data.frame(df, totals.2005[,c("StateNum", "Total.2005")], by = "StateNum")
counties.2008 <- subset(NEI, year == 2008)
totals.2008 <- counties.2008 %>% group_by(StateNum) %>% summarise(Total.2008 = sum(Emissions))
df <- merge.data.frame(df, totals.2008[,c("StateNum", "Total.2008")], by = "StateNum")

outliers.1999 <- counties.1999 %>% filter(Emissions >= quantile(Emissions, probs = 0.95))
outliers.2002 <- counties.2002 %>% filter(TotalEmissions >= quantile(TotalEmissions, probs = 0.95))
outliers.2005 <- counties.2005 %>% filter(TotalEmissions >= quantile(TotalEmissions, probs = 0.95))
outliers.2008 <- counties.2008 %>% filter(TotalEmissions >= quantile(TotalEmissions, probs = 0.95))

offenders1 <- merge.data.frame(outliers.1999, outliers.2002, by = "fips")
offenders2 <- merge.data.frame(outliers.2005, outliers.2008, by = "fips")
offenders <- merge.data.frame(offenders1, offenders2, by = "fips")
colnames(offenders) <- c("fips", "TotalEmissions.1999", "MedianEmissions.1999",
                         "TotalEmissions.2002", "MedianEmissions.2002",
                         "TotalEmissions.2005", "MedianEmissions.2005",
                         "TotalEmissions.2008", "MedianEmissions.2008")

# look up offenders$fips in fips.lookup to get county names
indices <- offenders$fips %in% fips.lookup$fips
# so all offender counties exist in the lookup table except fips == "12086
#offenders[which(indices == F),]
# here are the repeat violator counties
repeat.offenders <- fips.lookup[which(fips.lookup$fips %in% offenders$fips),"CountyName"]
# lets add the state to each row (get state from the first 2 digits of fips)

