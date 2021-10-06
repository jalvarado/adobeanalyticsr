utils::globalVariables(c("itemId", "value", "metric", "data", "name", "dataAnomalyDetected", "dataLowerBound", "dataUpperBound", "day", "eventnm", "qickview", "columnId", "filters", "filtername", "mfinalname"))

# This code is executed in the package environment
.AAEnv <- new.env(parent = emptyenv())
.AAEnv$token <- NULL

# Default to using the OAuth authentication flow.
.AAEnv$auth_method <- "oauth"

set_auth_method <- function(auth_method) {
  .AAEnv$auth_method <- auth_method
}

get_auth_method <- function() {
  return(.AAEnv$auth_method)
}

# Set token to environment
set_token <- function(value) {
  .AAEnv$token <- value
  return(value)
}

# Get token from environment
get_token <- function() {
  .AAEnv$token
}