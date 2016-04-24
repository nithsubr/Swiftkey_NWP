create_corpus_quant <- function()
{
  
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
  data <- sample(c(data_blogs_all, data_news_all, data_twitter_all), replace = FALSE)
  data <- sample(data, size = length(data)*0.20, replace = FALSE)
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
  
  QCorp <- corpus(data)
  
  # Save the Corpus on the Disk
  save(QCorp, file = "./Swiftkey/QCorp.RData", precheck = F)
  
}