## ---- analyze_lexical_features

#==============================================================================#
#                           analyzeLexicalFeatures                             #
#==============================================================================#
#'  analyzeLexicalFeatures
#' 
#' This function takes as its parameters, the listed tokenized document 
#' to be tagged and returns a list containing:
#' - a data frame of descriptive statistics for each POS tag
#' - a list of token / pos tags pairs
#' 
#' @param document - the document to tag in unlisted token format
#' @param posTags - data frame of pos tags and descriptions
#' @return analysis - analysis of lexical density for the file
#' @author John James
#' @export
analyzeLexicalFeatures <- function(document, posTags) {
  
  # Initialize Annotators
  sentAnnotator <- Maxent_Sent_Token_Annotator()
  wordAnnotator <- Maxent_Word_Token_Annotator()
  posAnnotator <- Maxent_POS_Tag_Annotator()
  
  # Prepare a list of data frames, one per chunk, with feature frequencies
  taggedChunks <- lapply(seq_along(document), function(x) {
#    cat("\r......tagging chunk", x, "out of", length(document), "chunks                 ")
    tagChunk(document[[x]], x, sentAnnotator, wordAnnotator,
             posAnnotator, posTags)
  })
  
  # Combine the list of long data frames into a single data frame for all chunks
  chunkMatrix <- rbindlist(lapply(seq_along(taggedChunks), function(x) {
    taggedChunks[[x]]$tagsTableLong
  }))
  chunkMatrix[is.na(chunkMatrix)] <- 0
  
  # Combine the list of wide data frames into a single data frame for all chunks
  featureMatrix <- rbindlist(lapply(seq_along(taggedChunks), function(x) {
    taggedChunks[[x]]$tagsTableWide
  }), fill = TRUE)
  featureMatrix[is.na(featureMatrix)] <- 0
  
  # Combine the list of data frames into a single data frame for all chunks
  tagPairs <- unlist(lapply(seq_along(taggedChunks), function(x) {
    taggedChunks[[x]]$pairs
  }))
  
  # Calculate descriptive statistics and sample sizes
  features <- names(featureMatrix)
  featureStats <- rbindlist(lapply(seq_along(featureMatrix), function(x) {
    min <- min(as.numeric(as.character(featureMatrix[[x]])),na.rm=TRUE)
    max <- max(as.numeric(as.character(featureMatrix[[x]])),na.rm=TRUE)
    mean <- mean(as.numeric(as.character(featureMatrix[[x]])),na.rm=TRUE)
    range <- max - min
    total <- sum(as.numeric(as.character(featureMatrix[[x]])),na.rm=TRUE)
    sd <- sd(as.numeric(as.character(featureMatrix[[x]])),na.rm=TRUE)
    vc <- sd / mean  # normalized deviation
    te <- .05 * mean
    n <- sd^2 / (te/1.96)^2
    tag <- features[[x]]
    desc <- subset(posTags, Tag == tag, select = Description)
    df <- data.frame(tag = tag, desc = desc, min = min, max = max, 
                     mean = mean, range = range, total = total, sd = sd, 
                     vc = vc, te = te, n = n)
    df[complete.cases(df),]
  }))
  total <- sum(featureStats$total)
  featureStats$pctTotal <- data.frame(pctTotal = featureStats$total
                                      / total * 100)
  featureStats <- featureStats[,c(1,2,3,4,5,6,7,12,8,9,10,11)]
  avgVc <- mean(featureStats$vc)
  
  analysis <- list(
    avgVc = avgVc,
    chunkMatrix = chunkMatrix,
    featureMatrix = featureMatrix,
    featureStats = featureStats,
    tagPairs = tagPairs
  )
  
  return(analysis)
}

## ---- end