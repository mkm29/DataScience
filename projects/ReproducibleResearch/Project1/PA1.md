---
title: 'Reproducible Research: Peer Assignment 1'
author: "Mitch Murphy"
date: "3/8/2018"
output: 
  html_document:
    keep_md: true
---

## Loading and preprocessing the data

```r
library(knitr)
setwd("~/Desktop/DataScience/coursera/projects/ReproducibleResearch/Project1/")

if(!file.exists("activity.csv")) {
  # need to download the zip file and then unzip it
  download.file("https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip", destfile = "activity.zip")
  unzip("activity.zip")
  file.remove("activity.zip")
}
```

```
## [1] TRUE
```

```r
activityData <- read.csv("activity.csv")
# need to convert the date column into an R date, so we can extract the day of week from it.
activityData$date <- with(activityData, as.POSIXct(date))
activityData$day <- with(activityData, weekdays(date))
activityData$timestamp <- with(activityData, date+interval)
```


## What is mean total number of steps taken per day?

Did the question imply day of the week (Mon. - Fri.) or just daily? Here is both. 

```r
library(dplyr)
```

```
## Warning: package 'dplyr' was built under R version 3.2.5
```

```
## 
## Attaching package: 'dplyr'
```

```
## The following objects are masked from 'package:stats':
## 
##     filter, lag
```

```
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

```r
library(ggplot2)
```

```
## Warning: package 'ggplot2' was built under R version 3.2.5
```

```r
statsByWeekday <- activityData %>% group_by(day) %>% summarise(TotalSteps = sum(steps, na.rm = T), 
                                                               MeanSteps = mean(steps, na.rm = T), 
                                                               MedianSteps = median(steps, na.rm = T))
```

```
## Warning: package 'bindrcpp' was built under R version 3.2.5
```

```r
print(statsByWeekday)
```

```
## # A tibble: 7 x 4
##   day       TotalSteps MeanSteps MedianSteps
##   <chr>          <int>     <dbl>       <dbl>
## 1 Friday         86518      42.9           0
## 2 Monday         69824      34.6           0
## 3 Saturday       87748      43.5           0
## 4 Sunday         85944      42.6           0
## 5 Thursday       65702      28.5           0
## 6 Tuesday        80546      31.1           0
## 7 Wednesday      94326      40.9           0
```

```r
ggplot(statsByWeekday, aes(day, TotalSteps, fill = day)) + geom_bar(stat = "identity", show.legend = F) +
  facet_grid(.~day) + xlab("Day") + ylab("Steps") + theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank())
```

![](PA1_files/figure-html/unnamed-chunk-1-1.png)<!-- -->

```r
daily <- activityData %>% group_by(date) %>%  summarise(TotalSteps = sum(steps, na.rm = T), 
                                                               MeanSteps = mean(steps, na.rm = T), 
                                                               MedianSteps = median(steps, na.rm = T))

ggplot(daily, aes(x = TotalSteps)) +
    geom_histogram(fill = "blue", binwidth = 500) +
    labs(x = "Steps", y = "Frequency")
```

![](PA1_files/figure-html/unnamed-chunk-1-2.png)<!-- -->

```r
print("Daily")
```

```
## [1] "Daily"
```

```r
print(head(daily))
```

```
## # A tibble: 6 x 4
##   date                TotalSteps MeanSteps MedianSteps
##   <dttm>                   <int>     <dbl>       <dbl>
## 1 2012-10-01 00:00:00          0   NaN              NA
## 2 2012-10-02 00:00:00        126     0.438           0
## 3 2012-10-03 00:00:00      11352    39.4             0
## 4 2012-10-04 00:00:00      12116    42.1             0
## 5 2012-10-05 00:00:00      13294    46.2             0
## 6 2012-10-06 00:00:00      15420    53.5             0
```

## What is the average daily activity pattern?

```r
library(ggplot2)
intervals <- activityData %>% group_by(interval) %>% summarise(Max = max(steps, na.rm = T))
plot(intervals, xlab = "Interval", ylab = "Steps", main = "Average Steps Per Time Interval")
```

![](PA1_files/figure-html/unnamed-chunk-2-1.png)<!-- -->

If you look at the plot with interval being an indication of the time of day (starting at 12:01 AM), 
this data seems reasonable: your activity level ramps up after you wake up, until it peaks around mid-afternoon, 
and finally decreases before sleep. 

We can find the 5-minute interval that, on average, contains the maximum number of steps:

```r
which.max(intervals$Max)
```

```
## [1] 76
```


## Imputing missing values


```r
length(which(is.na(activityData$steps)))
```

```
## [1] 2304
```

So there are 2304 missing observations. 


```r
library(Hmisc)
```

```
## Warning: package 'Hmisc' was built under R version 3.2.5
```

```
## Loading required package: lattice
```

```
## Warning: package 'lattice' was built under R version 3.2.5
```

```
## Loading required package: survival
```

```
## Warning: package 'survival' was built under R version 3.2.5
```

```
## Loading required package: Formula
```

```
## Warning: package 'Formula' was built under R version 3.2.5
```

```
## 
## Attaching package: 'Hmisc'
```

```
## The following objects are masked from 'package:dplyr':
## 
##     src, summarize
```

```
## The following objects are masked from 'package:base':
## 
##     format.pval, units
```

```r
activityDataImputed <- activityData
activityDataImputed$steps <- impute(activityData$steps)
dailyImputed <- activityDataImputed %>% group_by(date) %>% summarise(steps = sum(steps, na.rm = T))
ggplot(dailyImputed, aes(x = steps)) +
  geom_histogram(fill = "blue", binwidth = 500) +
  labs(x = "Steps", y = "Frequency")
```

![](PA1_files/figure-html/impute-1.png)<!-- -->


## Are there differences in activity patterns between weekdays and weekends?

```r
daily$Weekend <- as.factor(ifelse(weekdays(daily$date) %in% c("Saturday", "Sunday"), TRUE, FALSE))
ggplot(daily, aes(date, TotalSteps, color=Weekend)) + geom_line()+facet_wrap(~Weekend)+labs(title = "Total Steps: Weekend vs. Weekday", x = "Interval", y = "No. of Steps")
```

![](PA1_files/figure-html/unnamed-chunk-5-1.png)<!-- -->

As would be expected, this particular person was not nearly as active during the weekends than during the week.
