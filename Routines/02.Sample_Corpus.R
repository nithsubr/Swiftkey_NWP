Sample_Corpus <- function(perc = 0.05)
{

# Check the user input. Currently only 1-5 grams are supported
if (perc <= 0 || perc > 1) stop ("Fatal Error. perc should be > 0 or <= 1")

# Load Packages
library(tm)
library(RWeka)
library(reshape2)
library(slam)
library(doParallel)
library(tau)

# Register for Parellel Processing
registerDoParallel(4)
jobcluster <- makeCluster(detectCores())
invisible(clusterEvalQ(jobcluster, library(tm)))
options(mc.cores = 4)

# Clear unused memory
gc()

load("./Swiftkey/Corp.RData")

set.seed(334433)

# Randomly Sample the data to reduce memory usage, yet keeping the variation
Corp_sample <- sample(Corp, size = length(Corp) * perc, replace = FALSE)

# Save the Corpus on the Disk
save(Corp_sample, file = "./Swiftkey/Corp_Sample.RData", precheck = F)

print("Sampled Corpus Written Back to the Disk")

}