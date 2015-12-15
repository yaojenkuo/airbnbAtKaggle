# airbnb X Kaggle

# read in csv files
setwd("C:/airbnbAtKaggle/data")
ageSummary <- read.table('age_gender_bkts.csv', sep=',', stringsAsFactors=F, header=T)
countriesSummary <- read.table('countries.csv', sep=',', stringsAsFactors=F, header=T)
sessions <- read.table('c:/sessions.csv', sep=',', stringsAsFactors=T, header=T)
trainUsers <- read.table('train_users_2.csv', sep=',', stringsAsFactors=T, header=T)
testUsers <- read.table('test_users.csv', sep=',', stringsAsFactors=T, header=T)

# libraries
library(ggplot2)
library(sqldf)
library(reshape2)

# merge ageSummary and countriesSummary for plotting
ageCountries <- merge(ageSummary, countriesSummary, by="country_destination", all.x=TRUE)
write.csv(ageCountries, "ageCountries.csv", row.names=FALSE)

# Build ABT for classification algorithm
# Using sqldf to manipulate dataset
sessions$action_type[sessions$action_type==''] <- '-unknown-'
sessionsActionType <- sqldf("select user_id, 
                 case when action_type=='booking_request' then 'booking_request'
                 when action_type=='booking_response' then 'booking_response'
                 when action_type=='click' then 'click'
                 when action_type=='data' then 'data'
                 when action_type=='message_post' then 'message_post'
                 when action_type=='modify' then 'modify'
                 when action_type=='partner_callback' then 'partner_callback'
                 when action_type=='submit' then 'submit'
                 when action_type=='view' then 'view'
                 else 'other_action_types' end as action_type,
                 sum(secs_elapsed) as secs_elapsed
                 from sessions
                 group by user_id, action_type
                 ")
sessionsDeviceType <- sqldf("select user_id,
                            case when device_type=='Android App Unknown Phone/Tablet' then 'android_app_unknown_phone_tablet'
                            when device_type=='Android Phone' then 'android_phone'
                            when device_type=='Blackberry' then 'blackberry'
                            when device_type=='Chromebook' then 'chromebook'
                            when device_type=='iPad Tablet' then 'iPad_tablet'
                            when device_type=='iPodtouch' then 'iPodtouch'
                            when device_type=='Linux Desktop' then 'linux_desktop'
                            when device_type=='Mac Desktop' then 'mac_desktop'
                            when device_type=='Opera Phone' then 'opera_phone'
                            when device_type=='Tablet' then 'tablet'
                            when device_type=='Windows Desktop' then 'windows_desktop'
                            when device_type=='Windows Phone' then 'windows_phone'
                            else 'other_device_types' end as device_type,
                            sum(secs_elapsed) as secs_elapsed
                            from sessions
                            group by user_id, device_type
                            ")
# use reshape2 package to 'dcast' the above 2 tables separately
sessionsActionTypeNew <- subset(sessionsActionType, user_id!='')
sessionsDeviceTypeNew <- subset(sessionsDeviceType, user_id!='')
row.names(sessionsActionTypeNew) <- NULL
row.names(sessionsDeviceTypeNew) <- NULL
userActionType <- dcast(sessionsActionTypeNew, user_id~action_type, sum)
userDeviceType <- dcast(sessionsDeviceTypeNew, user_id~device_type, sum)

# merge userActionType & userDeviceType
userActionDeviceSecsElapsed <- merge(userActionType, userDeviceType, by="user_id", all.x=T, all.y=T)
# replace NA with 0
userActionDeviceSecsElapsed[is.na(userActionDeviceSecsElapsed)] <- 0

# clean trainUsers/testUsers
## transform date variables to date format; time variable to time format
trainUsers$date_account_created <- as.Date(trainUsers$date_account_created, "%Y-%m-%d")
testUsers$date_account_created <- as.Date(testUsers$date_account_created, "%Y-%m-%d")
trainUsers$date_first_booking <- as.Date(trainUsers$date_account_created, "%Y-%m-%d")
testUsers$date_first_booking <- as.Date(testUsers$date_account_created, "%Y-%m-%d")
trainUsers$timestamp_first_active <- as.character(trainUsers$timestamp_first_active)
testUsers$timestamp_first_active <- as.character(testUsers$timestamp_first_active)
trainUsers$timestamp_first_active <- strptime(trainUsers$timestamp_first_active, "%Y%m%d%H%M%S")
testUsers$timestamp_first_active <- strptime(testUsers$timestamp_first_active, "%Y%m%d%H%M%S")
#trainUsers$timestamp_first_active <- format(trainUsers$timestamp_first_active, usetz=FALSE)
#testUsers$timestamp_first_active <- format(testUsers$timestamp_first_active, usetz=FALSE)

# merge trainUsers/testUsers with countriesSummary

# merge trainUsers/testUsers with userActionDeviceSecsElapsed
