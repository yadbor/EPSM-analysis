library(data.table)
library(here)


raw_folder <- here::here("data", "raw")

registrations <- fread(file.path(raw_folder, "Registration.csv"))
meetings <- names(registrations)[-1]

registrations[, prior := tstrsplit(Registration, " ")[1]]
registrations[, prior := as.numeric(prior)]

meetings <- data.table(city = c("Hobart", "Adelaide"),
                       year = c("2017", "2018"),
                       conference = c("EPSM", "EPSM"))
for (m in seq.int(1, nrow(meetings))) {
  col_ID <- meetings[m, paste(city, year)]
  tmp <- na.omit(registrations[, .SD, .SDcols = c(col_ID, "prior")])
  setnames(tmp, c("num", "prior"))
  DT[, .(prior = rep(tmp[, prior], tmp[, num]))]
  DT[, c("city", "year", "conference") := meetings[m, ], by = prior]
  
}

col_names <- c("submitter","city","state","country","theme","ID","conference","day_prior")
