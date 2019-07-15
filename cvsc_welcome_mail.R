# (c) Aleksandra Pawlik, 2019

# Short script to help automate sending out welcome email to the CVSC guests
# The script reads in the file with all bookings (manually downloaded through the booking portal on )


library(tidyverse)


current_date <- as.Date(Sys.Date())
date_str <- gsub("-", "_", as.character(current_date))
filename <- paste("BookingRecords_", date_str, ".csv", sep="")
bookings <- read.csv(filename)

date2 <- format(current_date+2, "%d-%m-%Y")



b1 <- bookings %>% 
      select(Email, Check.In.Date, ) %>% 
      filter(as.character(Check.In.Date) == as.character(date2))

write_lines(b1$Email, path = "email_them.txt",sep=",")


## TO DO

# check if already emailed for a given booking
# schedule automated emails
# download the bookings csv