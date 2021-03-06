## ---- parallelize_task
#==============================================================================#
#                             parallelizeTask                                  #
#==============================================================================#
#' parallelizeTask
#' 
#' This generic function used to parallelize a task (when possible)
#' 
#' @param task - the function to parallelize
#' @param ... - other parameters required by task
#' @return r - return from task
#' @author John James
#' @export
parallelizeTask <- function(task, ...) {
  
  # Calculate number of cores
  ncores <- detectCores() - 1
  
  # Initiate cluster 
  cl <- makeCluster(ncores)  
  registerDoParallel(cl)
  
  # Run Task
  r <- task(...)
  
  # Stop cluster
  stopCluster(cl)
  
  return(r)
}
## ---- end