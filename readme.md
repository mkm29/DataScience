# Getting and Cleaning Data

Contains the code and data for the Course Project, Getting and Cleaning Data, part of the Coursera series on Data Science. 

## Methodology

1. Initialize the R environment - set the working directory and load necessary packages.
2. The data is provided with this repo, however ensure that the data directory exists on the local machine; if not download it. 
3. Clean the data: load the features wanted in the analysis and then load the train and test sets, conditioned on the above features to include.
4. Merge the train and test data sets
5. Convert the activites in this merged data set into factors.
6. Compute the average of each variable.
7. Write this "tidy" data set to disk
