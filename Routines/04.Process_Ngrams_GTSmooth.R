
# CREATE THE PREDICTION MODEL
# Here we process the N-Grams already generated via "Create_NGrams.R" routine. 
# The existing format is (N-Grams, Frequency) sorted by N-Grams ascending and Frequency Descending
# We would apply the Good Turing funtion (preexisting in edgeR package) to get the normalizes N-Gram probabilities

process_ngrams_GTsmooth <- function() 
{
  
  # Load Required Packages
  library(edgeR)
  library(data.table)
  
  setwd("./Swiftkey/with_twitter")
  
  # Load the N-grams
  load(file = "1-Grams.rds")
  df1_all <- df_all
  rm(df_all)
  print("df1 load done")
  
  # Implement Good Turing using the in-build Bioconductor Function
  df1_all$prob <- goodTuringProportions(df1_all$value)
  df1_all <- data.table(df1_all)
  df1 <- df1_all[, c(1,3,4), with = F]
  names(df1) <- c("word", "pred", "prob_int")
  
  save(df1, file = "df1_GT.rds", precheck = F)
  print("df1 smoothing done")
  
  load(file = "2-Grams.rds")
  df2_all <- df_all
  rm(df_all)
  print("df2 load done")
  
  # Implement Good Turing using the in-build Bioconductor Function
  df2_all$prob <- goodTuringProportions(df2_all$value)
  df2_all <- data.table(df2_all)
  df2 <- df2_all[, c(2,3,4), with = F]
  names(df2) <- c("word_1", "pred", "prob_int")
  
  save(df2, file = "df2_GT.rds", precheck = F)
  print("df2 smoothing done")
  
  
  load(file = "3-Grams.rds")
  df3_all <- df_all
  rm(df_all)
  print("df3 load done")
  
  # Implement Good Turing using the in-build Bioconductor Function
  df3_all$prob <- goodTuringProportions(df3_all$value)
  df3_all <- data.table(df3_all)
  df3 <- df3_all[, c(2,3,4,5), with = F]
  names(df3) <- c("word_1", "word_2", "pred", "prob_int")
  
  save(df3, file = "df3_GT.rds", precheck = F)
  print("df3 smoothing done")
  
  
  load(file = "4-Grams.rds")
  df4_all <- df_all
  rm(df_all)
  print("df4 load done")
  
  # Implement Good Turing using the in-build Bioconductor Function
  df4_all$prob  <- goodTuringProportions(df4_all$value)
  df4_all <- data.table(df4_all)
  df4 <- df4_all[, c(2,3,4,5,6), with = F]
  names(df4) <- c("word_1", "word_2", "word_3", "pred", "prob_int")
  
  save(df4, file = "df4_GT.rds", precheck = F)
  print("df4 smoothing done")
  
  
  load(file = "5-Grams.rds")
  df5_all <- df_all
  rm(df_all)
  print("df5 load done")
  
  # Implement Good Turing using the in-build Bioconductor Function
  df5_all$prob  <- goodTuringProportions(df5_all$value)
  df5_all <- data.table(df5_all)
  df5 <- df5_all[, c(2,3,4,5,6,7), with = F]
  names(df5) <- c("word_1", "word_2", "word_3", "word_4", "pred", "prob_int")
  
  save(df5, file = "df5_GT.rds", precheck = F)
  print("df5 smoothing done")
  
}
    
  
  
  
  