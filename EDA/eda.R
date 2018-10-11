# Required libraries
require(readr)
require(dplyr)
require(ggplot2)
require(tm)
require(proxy)

# Loading the csv log files

log_file = '../data/logfilemarch.csv'

# Fastest possible to allocate columns, would be interesting though to explore a way to stream data rather thatn
# loading all in a single variable (aparently in memory but I would doubt it)
log_data <- data.table::fread(log_file,sep=",",verbose=TRUE,header=FALSE, na.strings=c('','NA','N/A'))

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

# sample_data = head(log_data,nrow(log_data)*0.05)
# sample_data[is.na(sample_data$V3)]$V3 = 'Unknown'

create_splitted_daemon_data <- function(log_data) {
  log_data[is.na(log_data$V3)]$V3 = 'Unknown'
  daemons <- rename_data(log_data) %>% select(Daemon) %>% unique
  # For each daemon create a file
  print('Splitting the log data')
  logdata_per_daemon = split(log_data, f=log_data$V3)
  for( i in 1:nrow(daemons) ) {
    file_save = paste('../data/group/',daemons$Daemon[i],'.csv',sep='')
    nrow = nrow(logdata_per_daemon[[daemons$Daemon[i]]])
    print(paste('Saving file: ',file_save,', nrow:',nrow, sep=''))
    
    store_data <- rename_data(logdata_per_daemon[[daemons$Daemon[i]]])
    write.csv(store_data, file = file_save)
  }
}

# plot_daemon_freq(log_data)
# print_daemon_freq(log_data)
# create_splitted_daemon_data(log_data)


#After splitting we found some interesting details
logmcelog_file <- '../data/group/mcelog.csv'
logmcelog_data <- data.table::fread(logmcelog_file,sep=",",verbose=TRUE,header=FALSE, na.strings=c('','NA','N/A'))



calculate_tfidf <- function(corpus) {
  doc_corpus <- Corpus( VectorSource(corpus) )
  control_list <- list(removePunctuation = FALSE, stopwords = TRUE, tolower = TRUE)
  tf <- TermDocumentMatrix(doc_corpus, control = control_list) %>% as.matrix
  idf <- log( ncol(tf) / ( 1 + rowSums(tf != 0) ) ) %>% diag
  tf_idf <- crossprod(tf, idf)
  colnames(tf_idf) <- rownames(tf)
  # tf_idf / sqrt( rowSums( tf_idf^2 ) )
  return (tf_idf)
}

SimilarityCosine <- function(x, y) {
  similarity <- sum(x * y) / ( sqrt( sum(y ^ 2) ) * sqrt( sum(x ^ 2) ) )
  return( acos(similarity) * 180 / pi )
}

logmcelog_data$V5[2:nrow(logmcelog_data)]
news_tf_idf <- calculate_tfidf(logmcelog_data$V5[2:nrow(logmcelog_data)])


pr_DB$set_entry( FUN = SimilarityCosine, names = c("Cosine") )
d1 <- dist(news_tf_idf, method = "Cosine")
pr_DB$delete_entry("Cosine")

cluster1 <- hclust(d1, method = "ward.D")
plot(cluster1)
rect.hclust(cluster1, 2)