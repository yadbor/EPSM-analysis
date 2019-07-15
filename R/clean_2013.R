library(data.table)
library(ggplot2)

raw_path <- "data-raw"
clean_path <- "data"

# Submissions file has a looong name
sub_2013_file <- "EPSM-2013-Excellence-through-Innovation-and-Professional-Development.csv"

# report <- fread("http://www.jotform.com/csv/31209036615043")
# setnames(report, c('IP','date','title','abstract',
# 'theme','form','prize','student',
# 'given','family','email','affiliation','country',
# 'given.1','family.1','email.1','affiliation.1','country.1'
# ,'ID')
# )
# DT <- report[, .(date = as.Date(date))][, .N, by=date]
# AB <- DT[, .("date", "theme", "form", "prize", "student", 
#               "addr", "org", "city", "state", "country", "ID")]

# Only want some columns, and want to give them nicer names
col_nums <- c(2, 5, 6, 7, 8, 11, 12, 18, 19, 20, 21)
col_names <-  c("date", "theme", "form", "prize", "student", 
                "addr", "org", "city", "state", "country", "ID")
AB <- fread(sub_2013_file, select = col_nums, col.names = col_names)

# Anonymise the submitting email address, giving each a unique ID
AB[, submitter := as.integer(factor(addr, labels = ""))]
# then remove the identifiable address
AB <- AB[, -"addr"]
# Make some columns factors 
f_cols <- c('theme','form','prize','student','country','ID')
AB[, (f_cols) := lapply(.SD, as.factor), .SDcols = f_cols]
# and give them more sensible levels
levels(AB$prize) <- c(FALSE, TRUE)
levels(AB$student) <- c(FALSE, TRUE)
levels(AB$form) <- c("oral", "poster")

# turn the date text into a proper date & separate out the time & date
AB[, c('day', 'time') := IDateTime(date)]

# Read the conference dates and just select our date
conf_dates <- fread(file.path(raw_path, "conf.dates.csv"))
our_date <- conf_dates[city == "Perth" & year == 2013, date]
# and calculate day_prior (which will be negative, as day is before our_date)
AB[, day_prior := as.integer(round(difftime(day, our_date)))]

# write out the submissions by day
write.csv(AB[, .(Perth_2013 = .N), by=day_prior],
          file = file.path(clean_path, "Perth_2013.csv"),
          row.names = FALSE)
# and the submission details, with added conference column
AB[, conference := "EPSM"]
write.csv(AB[, .(submitter, city, state, country, theme, ID, conference, day_prior)],
          file = file.path(clean_path, "Perth_2013_details.csv"),
          row.names = FALSE)

# Finally delete the original submissions file, to avoid private information leaking out
#file.remove(sub_2013_file)