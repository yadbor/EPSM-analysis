library(data.table)
library(here)

# Get the list of all conferences with their dates
CF <- fread(here("data", "conferences.csv"))
CF[, ID := paste(meeting,city,year, sep="_")]

# Make strings into Dates to make date arithmetic work
date_cols <- grep("date", names(CF))
CF[, (date_cols) := lapply(.SD, as.Date), .SDcols = date_cols]

# Read all the individual submission files into a list
all_data <- list()
for (id in CF$ID) { 
  # Read the submissions
  TMP <- fread(here("data", CF[ID == id, submissions]))
  if (length(names(TMP)) == 2) {
    # only have days_prior and a column of counts per day
    count_col <- str_which(names(TMP), "day_prior", negate = TRUE)
    # repeat each day by the number of submissions on that day
    # and create a new data.table with those days
    submissions <- rep(TMP[, day_prior], unlist(TMP[, ..count_col]))
    DT <- data.table(day_prior = submissions)
    # add the conference, city and year columns
    DT[, c("conference", "city", "year") := tstrsplit(id, "_")]
    # and fake an ID column (the rest will be NA)
    DT[, ID := .I]
  } else {
    DT <- TMP
  }
  # Create calendar submission dates
  DT[, day_prior := abs(day_prior)] # make all files use the same convention
  DT[, submit_date := CF[ID == id, conf_date] - day_prior]
  # add to list
  all_data[[id]] <- DT
}

DTALL <- rbindlist(all_data, fill = TRUE)

