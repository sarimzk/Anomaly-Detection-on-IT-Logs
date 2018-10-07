# Required libraries
require(readr)
require(dplyr)
require(ggplot2)

# Loading the csv log files

log_file = '../data/logfilemarch.csv'

# Fastest possible to allocate columns, would be interesting though to explore a way to stream data rather thatn
# loading all in a single variable (aparently in memory but I would doubt it)
log_data <- data.table::fread(log_file,sep=",",verbose=TRUE,header=FALSE)
# Just checking the dimensions dim(log_data)



# Renaming the columns
rename_data <- function(log_data) {
  log_data %>% rename(Timestamp = V1, MachineName = V2, Daemon = V3, LogText = V4)
}

# Print daemon frequency
print_daemon_freq <- function(log_data) {
  rename_data(log_data) %>% 
    count(Daemon, sort=TRUE)  %>% rename(count=n)
}
# Shows a Log smooth ordering of the daemon presents

plot_daemon_freq <- function(log_data) {
  rename_data(log_data) %>% 
    count(Daemon, sort=TRUE)  %>% mutate(count=log(n)) %>%
    ggplot() + geom_bar(mapping = aes(x=reorder(Daemon,-count), y = count), stat = "identity") + 
    theme(axis.text.x=element_text(angle=90, hjust=1)) +
    labs(x = "Daemon", y = "Smooth log count")
}


plot_daemon_freq(log_data)
print_daemon_freq(log_data)


daemons <- rename_data(log_data) %>% select(Daemon) %>% unique
# For each daemon create a file
for( i in 1:nrow(daemons) ) {
  rename_data(log_data) %>% filter(Daemon==daemons$Daemon[i]) %>% print
  break
}



