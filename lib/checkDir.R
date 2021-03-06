## ---- check_dir
#==============================================================================#
#                                 checkDir                                     #
#==============================================================================#
#'  checkDir
#' 
#' This function takes a directory as a parameter, checks for its existence.
#' if the directory doesn't exist, it is created and the function returns a 
#' zero value.  Otherwise, the number of files in the directory is returned.
#'  
#' @param directory - the directory to be checked
#' @return number of files in the directory
#' @author John James
#' @export
checkDir <- function(directory) {
  
   if (!dir.exists(directory)) {
    dir.create(directory, recursive = TRUE)
    dirSize = 0
  } else {
    dirSize = length(dir(path = directory, all.files = FALSE))
  }
  return(dirSize)
}
## ---- end