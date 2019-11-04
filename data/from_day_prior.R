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
  all_data[[id]] <- fread(here("data", CF[ID == id, submissions]))
  # Create calendar submission dates
  all_data[[id]][, submit_date := CF[ID == id, conf_date] + day_prior]
}




from_day_prior <- function(DT) {
  
}
