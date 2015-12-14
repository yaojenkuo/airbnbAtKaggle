# airbnb X Kaggle

setwd("C:/airbnbAtKaggle/data")
ageSummary <- read.table('age_gender_bkts.csv', sep=',', stringsAsFactors=F, header=T)
countriesSummary <- read.table('countries.csv', sep=',', stringsAsFactors=F, header=T)

# merge ageSummary and countriesSummary
ageCountries <- merge(ageSummary, countriesSummary, by="country_destination", all.x=TRUE)
write.csv(ageCountries, "ageCountries.csv", row.names=FALSE)
