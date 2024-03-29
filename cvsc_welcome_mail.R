# (c) Aleksandra Pawlik, 2019

# Short script to help automate sending out welcome email to the CVSC guests
# The script reads in the file with all bookings (manually downloaded through the booking portal on )


library(tidyverse)
library(ggplot2)
library(filesstrings)



current_date <- as.Date(Sys.Date(),  "%d-%m-%Y")
date_str <- gsub("-", "_", as.character(current_date))
filename <- paste("BookingRecords_", date_str, ".csv", sep="")
bookings <- read.csv(filename)

date2 <- format(current_date+1, "%d-%m-%Y")

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
               select(Guest, Staying.Days, Vegetarian)

write_lines(paste("Guests arriving today - ", date_str),path = paste("kitchen_report_", date_str, ".csv", sep=""))
write_lines("Guest name  , Staying days  , vegetarian  ",path = paste("kitchen_report_", date_str, ".csv", sep=""), append=TRUE)
write_lines("- - - - - - - - - -",path = paste("kitchen_report_", date_str, ".csv", sep=""), append=TRUE)
write.table(new_guests, col.names = F, file = paste("kitchen_report_", date_str, ".csv", sep=""), row.names=F,  sep=",", append=TRUE)

write_lines(paste("New guests total ",nrow(new_guests)),path = paste("kitchen_report_", date_str, ".csv", sep=""), append=TRUE)

write_lines("----------",path = paste("kitchen_report_", date_str, ".csv", sep=""), append=TRUE)
write_lines("----------",path = paste("kitchen_report_", date_str, ".csv", sep=""), append=TRUE)

current_guests <- bookings %>%
  mutate(Guest = paste(First.Name, Last.Name)) %>%
  filter(as.Date(Check.In.Date, "%d-%m-%Y") < as.Date(current_date, "%d-%m-%Y") & as.Date(current_date, "%d-%m-%Y") < as.Date(Check.Out.Date, "%d-%m-%Y") ) %>%
  select(Guest, Vegetarian)

write_lines(paste("Current guests "),path = paste("kitchen_report_", date_str, ".csv", sep=""), append=TRUE)
write_lines("Guest name  , vegetarian  ",path = paste("kitchen_report_", date_str, ".csv", sep=""), append=TRUE)
write_lines("- - - - - - - - - -",path = paste("kitchen_report_", date_str, ".csv", sep=""), append=TRUE)
write.table(current_guests, col.names = F, file = paste("kitchen_report_", date_str, ".csv", sep=""), row.names=F,  sep=",", append=TRUE)

write_lines(paste("Current guests total", nrow(current_guests)),path = paste("kitchen_report_", date_str, ".csv", sep=""), append=TRUE)

# Cleanup
# Move all files that are not with the current date at the end to the Archive
 

report_files= list.files(pattern = ".csv")
lapply(report_files, function(x){
    if (x != paste("linen_report_", date_str, ".csv", sep="")
        && x != paste("kitchen_report_", date_str, ".csv", sep="") 
        && x != paste("BookingRecords_", date_str, ".csv", sep="") 
        && x != paste("email_guests_on", date_str, ".csv", sep="") ){
      file.rename(from=x, to=paste("Archive/",x) )
    } 

  })



## Special requests

special_requests <- bookings %>%
  filter(Other.Information != "" ) %>%
  filter(Other.Information != "Linen required") %>%
  filter( !grepl("work party vouchers", Other.Information) ) %>%
  filter(as.Date(Check.In.Date, "%d-%m-%Y") > as.Date(current_date, "%d-%m-%Y")) %>%
  select(Booking.No., First.Name, Email, Check.In.Date, Other.Information)  %>%
  arrange(date = as.Date(Check.In.Date, "%d-%m-%Y")) 




write.table(special_requests, col.names = F, file = paste("special_requests", date_str, ".csv", sep=""), row.names=F,  sep=",")


## TO DO

# check if already emailed for a given booking
# schedule automated emails
# download the bookings csv