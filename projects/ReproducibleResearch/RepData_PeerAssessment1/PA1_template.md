---
title: 'Reproducible Research: Peer Assignment 1'
author: "Mitch Murphy"
date: "3/13/2018"
output: 
  html_document:
    keep_md: true
---



## Loading and preprocessing the data

```r
if(!file.exists("activity.csv")) {
  if(!file.exists("activity.zip")) {
    download.file("https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip", destfile = "activity.zip")
  }
  # need to download the zip file and then unzip it
  unzip("activity.zip")
}
activityData <- read.csv("activity.csv")
# need to convert the date column into an R date, so we can extract the day of week from it.
activityData$date <- with(activityData, as.POSIXct(date))
activityData$day <- with(activityData, weekdays(date))
activityData$timestamp <- with(activityData, date+interval)
activityData$weekend <- with(activityData, ifelse(day %in% c("Saturday", "Sunday"), TRUE, FALSE))
```


## What is mean total number of steps taken per day?

```r
daily <- activityData %>% group_by(date) %>%  summarise(TotalSteps = sum(steps, na.rm = T), 
                                                        MeanSteps = mean(steps, na.rm = T), 
                                                        MedianSteps = median(steps, na.rm = T))
```

```
## Warning: package 'bindrcpp' was built under R version 3.2.5
```

```r
ggplot(daily, aes(x = TotalSteps)) +
    geom_histogram(fill = "blue", binwidth = 500) +
    labs(x = "Steps", y = "Frequency")
```

![](PA1_template_files/figure-html/daily-1.png)<!-- -->

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
intervals <- activityData %>% group_by(interval) %>% summarise(Max = max(steps, na.rm = T))
plot(intervals, xlab = "Interval", ylab = "Steps", main = "Average Steps Per Time Interval")
```

![](PA1_template_files/figure-html/unnamed-chunk-1-1.png)<!-- -->

```r
which.max(intervals$Max)
```

```
## [1] 76
```
As expected, there is little activity early in the day (interval equals 0), but then activity drastically increases after 
about interval 500, remains active until about interval 2000 where the user becomes less active (night time). The max
number of steps (on average) occurs during interval 76.

## Imputing missing values

```
## [1] "There are 2304 missing observations (13.1147540983607%)."
```
Because there are a lot of NA (missing) values, we will impute these values by replacing them with the mean of the 
k-nearest neighbors. 


```r
activityDataImputed <- activityData
activityDataImputed$steps <- impute(activityData$steps)
dailyImputed <- activityDataImputed %>% group_by(date) %>% summarise(steps = sum(steps, na.rm = T),
                                                                     MeanSteps = mean(steps, na.rm = T),
                                                                     MedianSteps = median(steps, na.rm = T))
ggplot(dailyImputed, aes(x = steps)) +
  geom_histogram(fill = "blue", binwidth = 500) +
  labs(x = "Steps", y = "Frequency")
```

![](PA1_template_files/figure-html/impute-1.png)<!-- -->

```r
dailyImputed
```

```
## # A tibble: 61 x 4
##    date                steps MeanSteps MedianSteps
##    <dttm>              <dbl>     <dbl>       <dbl>
##  1 2012-10-01 00:00:00     0         0           0
##  2 2012-10-02 00:00:00   126       126         126
##  3 2012-10-03 00:00:00 11352     11352       11352
##  4 2012-10-04 00:00:00 12116     12116       12116
##  5 2012-10-05 00:00:00 13294     13294       13294
##  6 2012-10-06 00:00:00 15420     15420       15420
##  7 2012-10-07 00:00:00 11015     11015       11015
##  8 2012-10-08 00:00:00     0         0           0
##  9 2012-10-09 00:00:00 12811     12811       12811
## 10 2012-10-10 00:00:00  9900      9900        9900
## # ... with 51 more rows
```

There does not appear to be any significant changes when imputed missing values. 

## Are there differences in activity patterns between weekdays and weekends?

```r
weekday <- subset(activityData, weekend == FALSE) %>% group_by(interval) %>% summarise(Mean = mean(steps, na.rm = T))
weekend <- subset(activityData, weekend == TRUE) %>% group_by(interval) %>% summarise(Mean = mean(steps, na.rm = T))
par(mfrow=c(1,2))
plot(weekday, main = "Average daily steps, weekdays", col = "purple", ylab = "Steps")
plot(weekend, main = "Average daily steps, weedends", col = "red", ylab = "Steps")
```

![](PA1_template_files/figure-html/weekend-1.png)<!-- -->
It appears that opposite of what we expect holds: we observe less activity (on average) throughout the week than we 
do on the weekends.
