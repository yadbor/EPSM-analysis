library(data.table)
library(here)


raw_folder <- here::here("data", "raw")

# read the file supplied by Conference Company
registrations <- fread(file.path(raw_folder, "Registration.csv"))
meetings <- names(registrations)[-1]

registrations[, prior := tstrsplit(Registration, " ")[1]]
registrations[, prior := as.numeric(prior)]

#meetings <- list("Hobart 2017", "Adelaide 2018", "Perth 2019")
canon <- list()
for (m in meetings) {
  tmp <- na.omit(registrations[, .SD, .SDcols = c(m, "prior")])
  setnames(tmp, c("num", "prior"))
  DT <- data.table(prior = rep(tmp[, prior], tmp[, num]))
  DT[, conference := "EPSM"]
  DT[, c("city", "year") := tstrsplit(m, " "), by = prior]
  # and fake an ID column (the rest will be NA)
  DT[, ID := .I]
  
  canon[[m]] <- DT
}

col_names <- c("submitter","city","state","country","theme","ID","conference","day_prior")
