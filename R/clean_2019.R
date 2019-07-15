# Load needed libraries and set file locations
library(data.table)
library(stringr)
library(ggplot2)

raw_path <- "data-raw"
clean_path <- "data"

# tidy & spilt the submission data

# Read the raw submissions to get a submission date for each abstract
MS <- fread(file.path(raw_path, "Registration.csv"))
# Filenames without spaces are safer. The Perth data is EPSM & AOCMP combined
setnames(MS, c("day_prior", "Hobart_2017", "Adelaide_2018", "Combined_2019"))
# Clean up the day_prior column, using only digits before the first " "
MS[, day_prior := lapply(tstrsplit(day_prior, " ")[1], as.integer)]
# and make them negative days, as they are days prior to conference
MS[, day_prior := -1 * abs(day_prior)]

# Write seperate files for each conference, to make future re-use easier
for (conf in names(MS)[-1]) { 
  cols  <- c("day_prior", conf)
  write.csv(na.omit(MS[, ..cols]), # only rows with values for this conf
            file = file.path(clean_path, paste0(conf, ".csv")),
            row.names = FALSE
  )
}

# tidy & anonymise the submission details
AOCMP <- fread(file.path(raw_path, "AOCMP_abstracts.csv"))
setnames(AOCMP, "ID")
# Read the complete submission sheet
PER_19 <- fread(file.path(raw_path, "EPSM2019_subs.csv"))
setnames(PER_19, c("submitter", "city", "state", "country", "code", 
                   "theme","sub_theme", "ID"))
# Start by labelling everything as EPSM
PER_19[, conference := "EPSM"]
# Re-label rows that match the AOCMP ID list
PER_19[AOCMP, conference := "AOCMP", on = "ID"]
# Expand submission days so get a day for each submitted abstract
sub_days <- MS[!is.na(Combined_2019), rep(day_prior, Combined_2019)]
# If not enough days, assume the rest were all on the last day
all_days <- c(sub_days, rep(last(sub_days), nrow(PER_19)-length(sub_days)))
# As the abstracts are in submission order, this will set the right day
# Make the days prior negative, as they all come before conference date
PER_19[, day_prior := -1 * abs(all_days)]

# Write out seperate EPSM and AOCMP submission files (already have the combined one above)
write.csv(PER_19[conference == "EPSM", .(Perth_2019 = .N), by = day_prior],
          file = file.path(clean_path, "Perth_2019.csv"),
          row.names = FALSE
)
write.csv(PER_19[conference == "AOCMP",  .(AOCMP_2019 = .N), by = day_prior],
          file = file.path(clean_path, "AOCMP_2019.csv"),
          row.names = FALSE
)
# Write the details file, combining theme & sub-theme and dropping postcode
PER_19[, theme := paste(theme, sub_theme)]
write.csv(PER_19[,  .(submitter, city, state, country, theme, ID, conference, day_prior)],
          file = file.path(clean_path, "Perth_2019_details.csv"),
          row.names = FALSE
)