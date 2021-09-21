utils::globalVariables(c("itemId", "value", "metric", "data", "name", 'dataAnomalyDetected', 'dataLowerBound', 'dataUpperBound', 'day', 'eventnm', 'qickview', 'columnId', 'filters', 'filtername', 'mfinalname'))

# This code is executed in the package environment
.AAEnv <- new.env(parent = emptyenv())
.AAEnv$Token <- NULL

# Default to using the OAuth authentication flow.
.AAEnv$AuthMethod <- "oauth"

set_auth_method <- function(auth_method) {
  .AAEnv$AuthMethod <- auth_method
}

get_auth_method <- function() {
  return(.AAEnv$AuthMethod)
}

# Set token to environment
set_token <- function(value) {
  .AAEnv$Token <- value
  return(value)
}

# Get token from environment
get_token <- function() {
  .AAEnv$Token
}