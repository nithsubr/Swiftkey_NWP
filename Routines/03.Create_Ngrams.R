
# This funtion creates 5 sets of N-Grams. Each containing the aggregate frequency of all N-grams (N = 1 to 5)
# Input this this funtion is the N (order of the gram) that needs to be generated
# This routine used the Corpus that has already been saved via Obtain_Data.R routine

getProfanityWords <- function(corpus) {
  
  profanityFileName <- "profanity.txt"
  if (!file.exists(profanityFileName)) {
    profanity.url <- "https://raw.githubusercontent.com/shutterstock/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/master/en"
    download.file(profanity.url, destfile = profanityFileName, method = "curl")
  }
  
  if (sum(ls() == "profanity") < 1) {
    profanity <- read.csv(profanityFileName, header = FALSE, stringsAsFactors = FALSE)
    profanity <- profanity$V1
    profanity <- profanity[1:length(profanity)-1]
  }
  
  profanity
}



Create_Ngrams <- function(N)
{
  
  # Check the user input. Currently only 1-5 grams are supported
  if (N > 5 && N < 1) stop ("Fatal Error. N should be between 1 and 5")
  
  # Load Packages
  library(tm)
  library(RWeka)
  library(reshape2)
  library(slam)
  library(doParallel)
  library(tau)
  library(data.table)
  library(stringr)
  library(quanteda)
  
  # Register for Parellel Processing
  registerDoParallel(4)
  jobcluster <- makeCluster(detectCores())
  invisible(clusterEvalQ(jobcluster, library(tm)))
  invisible(clusterEvalQ(jobcluster, library(RWeka)))
  invisible(clusterEvalQ(jobcluster, library(reshape2)))
  invisible(clusterEvalQ(jobcluster, library(slam)))
  options(mc.cores = 4)
  
  # Clear unused memory
  gc()
  
  if (N != 1)
  {
    load("./Swiftkey/with_twitter/1-Grams.rds")
    if(!exists("df_all")) {stop("Please first load the 1-Grams")}
    df1_all <- df_all
    rm(df_all)
    df1_all <- as.data.table(df1_all)
    setkey(df1_all, word)
    
    # Load Data - Corpus which has already been created by "Obtain_Data.R" routine
    load("./Swiftkey/Corp_all.RData")
    
    # Create N-Gram tokenizer control funtion
    NgramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = N, max = N))
    
    # Create the Document Term Matrix
    dtm <- DocumentTermMatrix(Corp, control = list(tokenize = NgramTokenizer))
    
    # Clear Unused Memory
    rm(Corp_sample)
    gc()
    
    # Status
    print("Stage 1 Complete")
    
    # Get the term frequencies Matrix
    freq_all <- rollup(dtm, 1, na.rm=TRUE, FUN = sum)
    
    # Clear Unused Memory
    rm(dtm)
    gc()
    
    # Status
    print("Stage 2 Complete")
    
    # Aggregate the Frequencies
    df_all <- melt(apply(freq_all , 2, sum))
    
    # Clear unused Memory
    rm(freq_all)
    gc()
    
    # Print number if rows processed
    print(nrow(df_all))
    
    # Status
    print("Stage 3 Complete")
    
    # Format Data to Split N Grams into N Words , 1 each per column
    
    df_all$grams <- rownames(df_all)
    
    df_all <- as.data.table(df_all)
    
  } else {
    
    # Create the custom Data Formatting Funtions
    removeNonAsciiChars <- function(x) iconv(x, "latin1", "ASCII", sub="")
    removeHashtags <- function(x) gsub("\\B#\\S+\\b","", x)
    removeUrls <- function(x) gsub("http[s]?://.*\\S+","",x)
    removeSites <- function(x) gsub("www\\..*\\.[com|edu|net|biz]","",x)
    
    # Read Data from Source - We will only use the blog and news data 
    # Twitter Data uses manu non-english words which arent appropriate for prediction
    data_blogs_all <- readLines("C:/Users/nithsubr/Documents/Swiftkey/en_US.blogs.txt")
    data_news_all <- readLines("C:/Users/nithsubr/Documents/Swiftkey/en_US.news.txt")
    data_twitter_all <- readLines("C:/Users/nithsubr/Documents/Swiftkey/en_US.twitter.txt")
    data <- sample(c(data_blogs_all, data_news_all, data_twitter_all))
    rm(data_blogs_all)
    rm(data_news_all)
    rm(data_twitter_all)
    gc()
    
    # Status
    print("Stage 1 Complete")
    
    data <- gsub("*[[:digit:]]*", "", data)
    data <- gsub("*[[:punct:]]*", "", data)
    data <- removeNonAsciiChars(data)
    data <- removeHashtags(data)
    data <- removeUrls(data)
    data <- removeSites(data)
    data <- str_trim(data, side = c("both", "left", "right"))
    
    # Status
    print("Stage 2 Complete")
    
    dtm <- dfm(data, toLower = TRUE, removeNumbers = TRUE, removePunct = TRUE, removeSeparators = TRUE, removeTwitter = TRUE)
    # Clear unused memory
    rm(data)
    gc()
    
    df_all <- data.table(grams = features(dtm), value = colSums(dtm))
    df_all <- df_all[order(df_all$grams), ]
    
    rm(dtm)
    
    # Status
    print("Stage 3 Complete")
    
  }
  
  if (N == 1)
  {
    df_all <- df_all[order(df_all$grams), ]
    df_all$id <- 1:nrow(df_all)
    names(df_all) <- c("word", "value", "id")
  }
  
  if (N == 2)
  {
    
    df_all$word <- sapply(df_all$grams, function(x) unlist(strsplit(x, " "))[1]) 
    setkey(df_all, word)
    word_1 <- df1_all[df_all, id, by = word]
    df_all <- cbind(df_all, word_1 = word_1$id)
    rm(word_1)
    
    df_all$word <- sapply(df_all$grams, function(x) unlist(strsplit(x, " "))[2])
    setkey(df_all, word)
    pred <- df1_all[df_all, id, by = word]
    df_all <- cbind(df_all, pred = pred$id)
    rm(pred)
    
    df_all <- df_all[, c("value", "word_1", "pred"), with = FALSE]
    
    df_all <- df_all[order(df_all$word_1,-df_all$value), ]
    
  }
  
  if (N == 3)
  {
    
    df_all$word <- sapply(df_all$grams, function(x) unlist(strsplit(x, " "))[1]) 
    setkey(df_all, word)
    word_1 <- df1_all[df_all, id, by = word]
    df_all <- cbind(df_all, word_1 = word_1$id)
    rm(word_1)
    
    df_all$word <- sapply(df_all$grams, function(x) unlist(strsplit(x, " "))[2]) 
    setkey(df_all, word)
    word_2 <- df1_all[df_all, id, by = word]
    df_all <- cbind(df_all, word_2 = word_2$id)
    rm(word_2)
    
    df_all$word <- sapply(df_all$grams, function(x) unlist(strsplit(x, " "))[3])
    setkey(df_all, word)
    pred <- df1_all[df_all, id, by = word]
    df_all <- cbind(df_all, pred = pred$id)
    rm(pred)
    
    df_all <- df_all[, c("value", "word_1", "word_2", "pred"), with = FALSE]
    
    df_all <- df_all[order(df_all$word_1, df_all$word_2, -df_all$value), ]
    
  }
  
  if (N == 4)
  {

    df_all$word <- sapply(df_all$grams, function(x) unlist(strsplit(x, " "))[1]) 
    setkey(df_all, word)
    word_1 <- df1_all[df_all, id, by = word]
    df_all <- cbind(df_all, word_1 = word_1$id)
    rm(word_1)
    
    df_all$word <- sapply(df_all$grams, function(x) unlist(strsplit(x, " "))[2]) 
    setkey(df_all, word)
    word_2 <- df1_all[df_all, id, by = word]
    df_all <- cbind(df_all, word_2 = word_2$id)
    rm(word_2)
    
    df_all$word <- sapply(df_all$grams, function(x) unlist(strsplit(x, " "))[3]) 
    setkey(df_all, word)
    word_3 <- df1_all[df_all, id, by = word]
    df_all <- cbind(df_all, word_3 = word_3$id)
    rm(word_3)
    
    df_all$word <- sapply(df_all$grams, function(x) unlist(strsplit(x, " "))[4])
    setkey(df_all, word)
    pred <- df1_all[df_all, id, by = word]
    df_all <- cbind(df_all, pred = pred$id)
    rm(pred)
    
    df_all <- df_all[, c("value", "word_1", "word_2", "word_3", "pred"), with = FALSE]
    
    df_all <- df_all[order(df_all$word_1, df_all$word_2, df_all$word_3, -df_all$value), ]
    
  }
  
  if (N == 5)
  {
    
    df_all$word <- sapply(df_all$grams, function(x) unlist(strsplit(x, " "))[1]) 
    setkey(df_all, word)
    word_1 <- df1_all[df_all, id, by = word]
    df_all <- cbind(df_all, word_1 = word_1$id)
    rm(word_1)
    
    df_all$word <- sapply(df_all$grams, function(x) unlist(strsplit(x, " "))[2]) 
    setkey(df_all, word)
    word_2 <- df1_all[df_all, id, by = word]
    df_all <- cbind(df_all, word_2 = word_2$id)
    rm(word_2)
    
    df_all$word <- sapply(df_all$grams, function(x) unlist(strsplit(x, " "))[3]) 
    setkey(df_all, word)
    word_3 <- df1_all[df_all, id, by = word]
    df_all <- cbind(df_all, word_3 = word_3$id)
    rm(word_3)
    
    df_all$word <- sapply(df_all$grams, function(x) unlist(strsplit(x, " "))[4]) 
    setkey(df_all, word)
    word_4 <- df1_all[df_all, id, by = word]
    df_all <- cbind(df_all, word_4 = word_4$id)
    rm(word_4)
    
    df_all$word <- sapply(df_all$grams, function(x) unlist(strsplit(x, " "))[5])
    setkey(df_all, word)
    pred <- df1_all[df_all, id, by = word]
    df_all <- cbind(df_all, pred = pred$id)
    rm(pred)
    
    df_all <- df_all[, c("value", "word_1", "word_2", "word_3", "word_4", "pred"), with = FALSE]
    
    df_all <- df_all[order(df_all$word_1, df_all$word_2, df_all$word_3, df_all$word_4, -df_all$value), ]
    
  }
  
  # Print number if rows saved
  # print(nrow(df_all))
  
  # Store the Data on disk
  filename <- paste("./Swiftkey/with_twitter/", N, "-Grams.rds", sep = "")  
  save(df_all, file = filename, precheck = F)
  
  # Status
  print("Stage 4 Complete")
  
  # Clear unused memory
  rm(df_all)
  gc()
  
}