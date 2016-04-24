create_corpus_quant() <- function()
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
    
  
}