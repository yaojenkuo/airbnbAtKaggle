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
library(VIM)

# merge ageSummary and countriesSummary
ageCountries <- merge(ageSummary, countriesSummary, by="country_destination", all.x=TRUE)
write.csv(ageCountries, "ageCountries.csv", row.names=FALSE)

# explorations on sessions
ggplot(sessions, aes(action_type))+geom_bar()+coord_flip()
aggr(sessions, prop=TRUE, number=TRUE)

# merge sessions with trainUsers and testUsers separately
sessionsTrain <- merge(sessions, trainUsers, by.x="user_id", by.y="id")# inner join
sessionsTest <- merge(sessions, testUsers, by.x="user_id", by.y="id")# inner join
write.csv(sessionsTrain, "c:/sessionsTrain.csv", row.names=FALSE)
write.csv(sessionsTest, "c:/sessionsTest.csv", row.names=FALSE)
