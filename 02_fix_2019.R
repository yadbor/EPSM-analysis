library(data.table)
library(ggplot2)

# load the raw submission data to get a submission date for each paper
# need this to sort out which were EPSM and which AOCMP, as only have
# paper numbers for AOCMP

MS <- fread("mixed_submissions.csv")

# write out as seperate files for each conference, 
# to make future re-use easier (I hope)
for (conf in names(MS)[-1]) { 
  cols  <- c("day_prior", conf)
  write.csv(na.omit(MS[, ..cols]),
            file = paste0(conf, ".csv")
            )
}

MS_days <- MS[!is.na(Perth_2019), rep(day_prior, Perth_2019)]

P19 <- fread("Perth_2019_subs.csv")
setnames(P19, c("ID", "org", "city", "state", "country", "code", 
                "theme","sub_theme", "paper", "conference"))

# note enough submission days in the MS sheet, 
# so assume the rest were all submitted on the last day?
all_days <- c(MS_days, rep(last(MS_days), nrow(P19)-length(MS_days)))
P19[, day_prior := all_days]

