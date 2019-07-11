library(data.table)
library(ggplot2)

files <- dir(".", pattern = "csv$", recursive = FALSE, full.names = TRUE)
DT <- data.table(file = files)
# choose the second name (as that is the submissions data)
# only want some columns, and want to give them nicer names
col_names <-  c("IP", "date", "title", "abstract", "theme","form","prize", "student", "org", "country", "ID")
AB <- fread(DT[2, file], drop = 9:16, col.names = col_names)

# make some columns factors
f_cols <- c('IP','theme','form','prize','student','country','ID')
AB[, (f_cols) := lapply(.SD, as.factor), .SDcols = f_cols]
# and give them more sensible levels
levels(AB$prize) <- c(FALSE, TRUE)
levels(AB$student) <- c(FALSE, TRUE)
levels(AB$form) <- c("oral", "poster")

# turn the date text into a proper date & separate out the time & date
AB[, c('day', 'time') := IDateTime(date)]
# count the submissions per day, and sum them to get a running total
IN <- AB[, .N, by=day][order(day), submitted:=cumsum(N)]
ggplot(IN) +aes(x=day, y=submitted) +geom_step()

deadlines <- c(as.IDate("2013-07-12"), as.IDate("2013-07-26"))
IN[day > deadlines[2],  status := 'late']
IN[day <= deadlines[1], status := 'early']
IN[day > deadlines[1] & day <= deadlines[2], status := 'lucky']

ggplot(IN) + 
  aes(x=day, y=submitted, colour = status) + 
  geom_vline(xintercept = deadlines, linetype = 2) +
  geom_step()

# read the conference dates
conf.dates <- fread("conf.dates.csv")
# convert date columns (all but first) to real dates
date_cols <- names(conf.dates)[-1]
conf.dates[, (date_cols) := lapply(.SD, as.IDate), .SDcols = date_cols]
setkey(conf.dates, conference)

# and calulate dyas_prior to match rest of data
IN[, day_prior := conf.dates["Perth_2013", conf.date] - day]

