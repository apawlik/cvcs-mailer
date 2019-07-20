# (c) Aleksandra Pawlik, 2019

# Short script to help automate sending out welcome email to the CVSC guests
# The script reads in the file with all bookings (manually downloaded through the booking portal on )


library(tidyverse)
library(ggplot2)



current_date <- as.Date(Sys.Date(),  "%d-%m-%Y")
date_str <- gsub("-", "_", as.character(current_date))
filename <- paste("BookingRecords_", date_str, ".csv", sep="")
bookings <- read.csv(filename)

date2 <- format(current_date+2, "%d-%m-%Y")

b1 <- bookings %>% 
      select(Email, Check.In.Date, ) %>% 
      filter(as.character(Check.In.Date) == as.character(date2))

write_lines(b1$Email, path = paste("email_guests_on", date_str, ".csv", sep=""),sep=",")


## Linen report

linen <- bookings %>% 
         filter( Linen.Required == "Yes" | Last.Name =="Haka Tours")  %>%
        mutate(Guest = paste(First.Name, Last.Name)) %>%
        mutate(Staying.Days = (as.Date(Check.Out.Date, "%d-%m-%Y") - as.Date(Check.In.Date, "%d-%m-%Y") )) %>%
        select(Check.In.Date, Check.Out.Date, Staying.Days, Guest,  Room.Type) %>%
        arrange(date = as.Date(Check.In.Date, "%d-%m-%Y")) 

write_lines(paste("Linen requirements as of ", date_str),path = paste("linen_report_", date_str, ".csv", sep=""))

write.table(linen, file = paste("linen_report_", date_str, ".csv", sep=""), sep=",", row.names = F, append=TRUE)



# Kitchen report
new_guests <- bookings %>%
               filter(as.character(Check.In.Date) == as.character(format(current_date, "%d-%m-%Y")) ) %>%
               mutate(Guest = paste(First.Name, Last.Name)) %>%
               mutate(Staying.Days = (as.Date(Check.Out.Date, "%d-%m-%Y") - as.Date(Check.In.Date, "%d-%m-%Y") )) %>%
               select(Guest, Staying.Days)

write_lines(paste("Guests arriving today - ", date_str),path = paste("kitchen_report_", date_str, ".txt", sep=""))
write.table(new_guests, col.names = F, file = paste("kitchen_report_", date_str, ".txt", sep=""), row.names=F,  sep=",", append=TRUE)

write_lines("Total new ",path = paste("kitchen_report_", date_str, ".txt", sep=""), append=TRUE)

write_lines("----------",path = paste("kitchen_report_", date_str, ".txt", sep=""), append=TRUE)

current_guests <- bookings %>%
  mutate(Guest = paste(First.Name, Last.Name)) %>%
  filter(as.Date(Check.In.Date, "%d-%m-%Y") < as.Date(current_date, "%d-%m-%Y") & as.Date(current_date, "%d-%m-%Y") < as.Date(Check.Out.Date, "%d-%m-%Y") ) %>%
  select(Guest)

write_lines(paste("Current guests "),path = paste("kitchen_report_", date_str, ".txt", sep=""), append=TRUE)
write.table(current_guests, col.names = F, file = paste("kitchen_report_", date_str, ".txt", sep=""), row.names=F,  sep=",", append=TRUE)

write_lines("Total current ",path = paste("kitchen_report_", date_str, ".txt", sep=""), append=TRUE)

# Cleanup
# Move all files that are not with the current date at the end to the Archive
 




## TO DO

# check if already emailed for a given booking
# schedule automated emails
# download the bookings csv