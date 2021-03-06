## ---- mkn_counts

#==============================================================================#
#                                mknAbsCount                                   #
#==============================================================================#
#'  mknAbsCount
#' 
#' This function takes as its parameter, the meta data for the processed 
#' training ngram the mkn lm, then calculates raw counts for each ngram 
#' in separate data tables and saves to disc. Total counts for each ngram are
#' summarized, stored to disc and returned to the calling environment
#' 
#' @param mkn - the meta data for the MKN language model
#' @param nGrams - the meta data for the processed training set ngrams
#' @return summaryCounts - the summary counts for each nGram
#' @author John James
#' @export
mknAbsCount <- function(mkn, nGrams) {
  
  startTime <- Sys.time()
  
  message(paste("\nCalculating nGram Counts for MKN model at", startTime))
  
  summaryCounts <- rbindlist(lapply(seq_along(nGrams), function(x) {
    message(paste('...calculating counts for', nGrams[[x]]$fileDesc))
    
    # Load N-grams and list the nGrams to keep
    current <- loadObject(mkn$counts[[x]])
    setkey(current, nGram)

    # Get N-Gram counts from N-Gram
    currentNGram <- loadObject(nGrams[[x]])
    counts <- data.table(nGram = featnames(currentNGram), 
                             count = colSums(currentNGram),
                             key = 'nGram')

    # Merge with counts table
    current <- merge(current, counts, by='nGram', all.x = TRUE)
    
    # Add context counts for higher order ngrams
    if (x > 1) {
      context <- current[,.(contextCount = sum(count)), by = context]
      setkey(context, context)
      setkey(current, context)
      current <- merge(current, context, by = "context")
    }
    
    # Clear all NA values
    for (i in seq_along(current)) set(current, i=which(is.na(current[[i]])), j=i, value=0)
    
    # Save counts
    mkn$counts[[x]]$data <- current
    saveObject(mkn$counts[[x]])
    
    # Summarize counts 
    s <- list()
    s$nGram <- mkn$counts[[x]]$fileDesc
    s$Count <- nfeature(currentNGram)
    s
  }))
  
  # Save Summary counts
  mkn$summary$data <- summaryCounts
  saveObject(mkn$summary)

  # Log Results
  logR(paste(mkn$mName, 'counts'), startTime, 
       mkn$counts[[1]]$directory, 'various')
  
  # Alert User
  endTime <- Sys.time()
  message(paste0('...MKN Counts completed at ', endTime))
  message(paste('...Elapsed time is', round(difftime(endTime, startTime,  units = 'auto'), 2)))
  
  return(mkn$summary$data)
}
## ---- end
#summary <- mknAbsCount(corpora$train$processedData$nGrams$text, lm$mkn)