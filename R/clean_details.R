# Load needed libraries and set file locations
library(data.table)
library(stringr)
library(ggplot2)

raw_path <- "../data-raw"
clean_path <- "../data"

# paths are relative to the location of this script, so move there
# push current location
loc <- getwd()
# change directory, unless alreay there 
if (loc != "R") setwd("R")
# now in the R directory 

details <- data.table(file = dir(path = clean_path, 
                                 pattern = "details.csv", 
                                 full.names = TRUE)
)
details[, year := str_match(file, "\\_(\\d{4})\\_")[,2]]

# pop location back to where we were
# setwd(loc)