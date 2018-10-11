# Required libraries
require(readr)
require(dplyr)
require(ggplot2)
require(tm)
require(proxy)
require(tidytext)
require(ggplot2)


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


log_to_analyze <- c(
  'mpd.csv',
  'smartd.csv',
  'mpdman.csv',
  'python.csv',
  'sdpd.csv',
  'rpc.statd.csv',
  'hcid.csv',
  'sftp-server.csv',
  'run_srp_daemon.csv',
  'shutdown.csv',
  'logger.csv',
  'init.csv',
  'dkms_autoinstaller.csv',
  'mount.csv',
  'mcelog.csv',
  'S99SMmonitor.csv',
  'SMagent.csv',
  'OpenSM.csv',
  'yum.csv',
  'wall.csv',
  'bfs_parallel.csv')

pr_DB$set_entry(FUN = "R_cosine",
                names = c("cosine", "angular"),
                PREFUN = "pr_cos_prefun",
                distance = FALSE,
                convert = "pr_simil2dist",
                type = "metric",
                loop = FALSE,
                C_FUN = TRUE,
                abcd = FALSE,
                formula = "xy / sqrt(xx * yy)",
                reference = "Anderberg, M.R. (1973). Cluster Analysis for Applicaitons. Academic Press.",
                description = "The cos Similarity (C implementation)")


for(i in 1:length(log_to_analyze)) {
  file_log <- log_to_analyze[[i]]
  loggroup_file <- paste('../data/group/',file_log,sep="")
  print(paste('Reading ',file_log,' and calculating TF-IDF'))
  loggroup_data <- data.table::fread(loggroup_file,sep=",",verbose=FALSE,header=TRUE, na.strings=c('','NA','N/A'))
  
  if(nrow(loggroup_data)<=2){
    next
  }
  news_tf_idf <- calculate_tfidf(loggroup_data$LogText)
  d1 <- dist(news_tf_idf, method = "Cosine")  
  cluster1 <- hclust(d1, method = "ward.D")
  png(paste0('../data/analyze/',file_log,'.png'), width = 1500, height = 1500)
  plot(cluster1,main=paste('Dendogram for:',file_log))
  dev.off()
}

pr_DB$delete_entry("Cosine")
#After splitting we found some interesting details
#rect.hclust(cluster1, 2)

# Zipf law
log_file <- paste('../data/group/','dhcpd.csv',sep="")
log_file_data <- data.table::fread(log_file,sep=",",verbose=FALSE,header=TRUE, na.strings=c('','NA','N/A'))
daemon_words <- log_file_data %>% unnest_tokens(word,LogText) %>% count(Daemon,word,sort=TRUE) %>% ungroup()

total_words <- daemon_words %>% group_by(Daemon) %>% summarise(total=sum(n))
daemon_words <- left_join(daemon_words, total_words)
log(daemon_words$n/daemon_words$total)

# ggplot(daemon_words, aes(n/total, fill = Daemon)) +
#   geom_histogram(show.legend = FALSE) +
#   xlim(NA, 0.06) +
#   facet_wrap(~Daemon, ncol = 2, scales = "free_y") 

freq_by_rank <- daemon_words %>% 
  group_by(Daemon) %>% 
  mutate(rank = row_number(), 
         `term frequency` = n/total)

freq_by_rank %>% 
  ggplot(aes(rank, `term frequency`, color = Daemon)) + 
  geom_line(size = 1.1, alpha = 0.8, show.legend = FALSE) + 
  scale_x_log10() +
  scale_y_log10() + ggtitle(paste('Zipf Law on log file',log_file))
  

log_file_data
tail(freq_by_rank,500)

