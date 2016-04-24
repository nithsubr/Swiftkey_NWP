
# This funtion takes in the Data from the Data Store, Creates a Corpus, Formats the same and Stored it on the disk
# Below are the formatting options - 
# 1. Remove all Latin and Non-ASCII words
# 2. Remove all the Hash Tags
# 3. Remove all the URLs and sites
# 4. Remove Punctuations
# 5. Remove Numbers
# 6. Remove White Spaces

Create_Corpus <- function()
{
  # Load the required libraries
  library(tm)
  library(doParallel)
  
  # Register for parallel processing
  registerDoParallel(4)
  jobcluster <- makeCluster(detectCores())
  invisible(clusterEvalQ(jobcluster, library(tm)))
  options(mc.cores = 4)
  
  # Create the custom Data Formatting Funtions
  removeNonAsciiChars <- content_transformer(function(x) iconv(x, "latin1", "ASCII", sub=""))
  removeHashtags <- content_transformer(function(x) gsub("\\B#\\S+\\b","", x))
  removeUrls <- content_transformer(function(x) gsub("http[s]?://.*\\S+","",x))
  removeSites <- content_transformer(function(x) gsub("www\\..*\\.[com|edu|net|biz]","",x))
  
  # Read Data from Source - We will only use the blog and news data 
  # Twitter Data uses manu non-english words which arent appropriate for prediction
  data_blogs_all <- readLines("C:/Users/nithsubr/Documents/Swiftkey/en_US.blogs.txt")
  data_news_all <- readLines("C:/Users/nithsubr/Documents/Swiftkey/en_US.news.txt")
  data_twitter_all <- readLines("C:/Users/nithsubr/Documents/Swiftkey/en_US.twitter.txt")
  data <- sample(c(data_blogs_all, data_news_all, data_twitter_all))
  
  set.seed(334433)
  
  # Randomly Sample the data to reduce memory usage, yet keeping the variation
  data <- sample(data, size = length(data) * 0.10, replace = FALSE)

  # Create the Corpus
  Corp <- VCorpus(VectorSource(data))
  
  # Clear unused memory
  rm(data)
  gc()
  
  # Format the Corpus Data
  Corp <- tm_map(Corp, removeNonAsciiChars)
  Corp <- tm_map(Corp, removeHashtags)
  Corp <- tm_map(Corp, removeUrls)
  Corp <- tm_map(Corp, removeSites)
  Corp <- tm_map(Corp, removePunctuation)
  Corp <- tm_map(Corp, removeNumbers)
  Corp <- tm_map(Corp, stripWhitespace)  
  #Corp <- tm_map(Corp, removeWords, c("i", stopwords("english")))
  
  # Save the Corpus on the Disk
  save(Corp, file = "./Swiftkey/Corp_all.RData", precheck = F)
  
  
}