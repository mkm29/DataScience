##################################################
## Project: R Programming, Assignment 2
## Script purpose: capitalize on caching matrix inverses
## Date: 2/5/18
## Author: Mitch Murphy
##################################################

makeCacheMatrix <- function(x = matrix()) {
  inv <- NULL #placeholder for inverse
  
  get <- function() x
  
  set <- function(mat) {
    x <<- mat
    i <<- NULL
  }
  
  # also need getter and setter for inv
  getInverse <- function() inv
  
  setInverse <- function(i) {
    inv <<- i
  }
  
  # return list of all 4 of these properties
  list(get = get, set = set, getInverse = getInverse, setInverse = setInverse)
}


## Write a short comment describing this function

cacheSolve <- function(x, ...) {
  inv <- x$getInverse()
  if(!is.null(inv)) {
    message("getting cached data")
    return(inv)
  }
  data <- x$get()
  inv <- solve(data)
  x$setInverse(inv)
  inv  ## Return a matrix that is the inverse of 'x'
}
