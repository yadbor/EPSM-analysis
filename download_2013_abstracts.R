sub_2013_file <- "EPSM-2013-Excellence-through-Innovation-and-Professional-Development.csv"
ALL <- data.table::fread(sub_2013_file)
new_names <- strsplit("IP,date,title,abstract,theme,form,prize,student,name,family,email,org,country.1,name.2,family.2,email.2,org.2,city,state,country,ID", ",")[[1]]
setnames(ALL, new_names)

ALL[, curl::curl_download(url = abstract, destfile = file.path("abstracts", ID)), by = ID]