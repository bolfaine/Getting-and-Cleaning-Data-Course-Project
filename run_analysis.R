library(reshape2)

file <- "dataset.zip"

## Download and unzip:
if (!file.exists(file)){
  fURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fURL, file, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(file) 
}

# Load activity labels + features

activity <- read.table("UCI HAR Dataset/activity_labels.txt")
activity[,2] <- as.character(activity[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation

getfeatures <- grep(".*mean.*|.*std.*", features[,2])
getfeatures.names <- features[getfeatures,2]
getfeatures.names = gsub('-mean', 'Mean', getfeatures.names)
getfeatures.names = gsub('-std', 'Std', getfeatures.names)
getfeatures.names <- gsub('[-()]', '', getfeatures.names)


# Load the datasets

train <- read.table("UCI HAR Dataset/train/X_train.txt")[getfeatures]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[getfeatures]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels

allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", getfeatures.names)

# Change activities & subjects into factors

allData$activity <- factor(allData$activity, levels = activity[,1], labels = activity[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
