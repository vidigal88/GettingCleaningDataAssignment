
# Library -----------------------------------------------------------------

library(data.table)


# Read train set ----------------------------------------------------------

train <- fread('getting_and_cleaning_data/data/UCI HAR Dataset/train/X_train.txt')
train[, set := 'train']
dim(train)


# Read test data -------------------------------------------------------

test <- fread('getting_and_cleaning_data/data/UCI HAR Dataset/test/X_test.txt')
test[, set := 'test']
dim(test)
colnames(test)


# Get the var names -------------------------------------------------------

file_names <- fread('getting_and_cleaning_data/data/UCI HAR Dataset/features.txt')
var_names <- file_names[, V2]
head(var_names)


# Change names ------------------------------------------------------------

setnames(train, 
         old = paste0("V", 1:561),
         new = var_names)


setnames(test, 
         old = paste0("V", 1:561),
         new = var_names)



# 1. Merges the training and the test sets to create one data set. --------

train_test <- rbind(train, test)
head(train_test)
train_test[, 1:5]


# 2. Extracts only the measurements on the mean and standard devia --------

mean_std_var <- grep('mean\\D|std\\D', colnames(train_test), value = TRUE)

train_test <- train_test[, mget(c(mean_std_var))]


# 3. Uses descriptive activity names to name the activities in the --------

ytrain <- fread('getting_and_cleaning_data/data/UCI HAR Dataset/train/y_train.txt')
head(ytrain)
setnames(ytrain, 'V1', 'activity_code')

ytest <- fread('getting_and_cleaning_data/data/UCI HAR Dataset/test/y_test.txt')
head(ytest)
class(ytest)
setnames(ytest, 'V1', 'activity_code')

activity_labels <- fread('getting_and_cleaning_data/data/UCI HAR Dataset/activity_labels.txt')
setnames(activity_labels, 
         old = c('V1', 'V2'),
         new = c('activity_code', 'activity_label'))



# Merge data --------------------------------------------------------------

activity_train <- merge(ytrain, activity_labels,
                        by = 'activity_code', all.x = T)

activity_test <- merge(ytest, activity_labels,
               by = 'activity_code', all.x = T)

activity <- rbind(activity_train, activity_test)



# 4. Appropriately labels the data set with descriptive variable n --------


# devtools::install_github("bmewing/mgsub")
library(mgsub)

old_names <- colnames(train_test)

new_names <- mgsub::mgsub(old_names, 
             c('^t', 'BodyAcc\\D', 'GravityAcc\\D', 'BodyAccJerk\\D', 'BodyGyro\\D',
               'BodyGyroJerk\\D', 'GravityAccMag\\D', 'BodyAccMag\\D', 'BodyAccJerkMag\\D',
               'BodyGyroMag\\D', 'BodyGyroJerkMag\\D', 'mean\\D', 'meanFreq\\D', 'std\\D',
               '\\D-X', '\\D-Y', '\\D-Z', '^f', ')', 'BodyBodyAccJerkMag\\D',
               'BodyBodyGyroMag\\D', 'BodyBodyGyroJerkMag\\D'),
             c('time_', 'body_acc_', 'gravity_acc_', 'body_acc_jerk_', 'body_gyro_',
               'body_gyro_jerk_', 'gravity_acc_mag_', 'body_acc_mag_',
               'body_acc_jerk_mag_', 'body_gyro_mag_', 'body_gyro_jerk_mag_', 'avg_',
               'avg_', 'std_', 'x', 'y', 'z', 'freq_', '', 'body_body_acc_jerk_mag_', 
               'body_body_gyro_mag_', 'body_body_gyro_jerk_mag_'))


setnames(train_test,
         old_names, 
         new_names)



# 5. From the data set in step 4, creates a second, independent ti --------

subject_train <- fread('getting_and_cleaning_data/data/UCI HAR Dataset/train/subject_train.txt')
setnames(subject_train, 'V1', 'subject')

subject_test <- fread('getting_and_cleaning_data/data/UCI HAR Dataset/test/subject_test.txt')
setnames(subject_test, 'V1', 'subject')


# Bind subject data -------------------------------------------------------


subject <- rbind(subject_train, subject_test)

# Bind subject and  activity with main data -------------------------------


train_test <- cbind(train_test, subject, activity)



# Get the mean by subject and activity ------------------------------------


train_test_mean <- train_test[, lapply(.SD, mean), 
           .SDcols = new_colnames,
           by = c('subject', 'activity_label')]

