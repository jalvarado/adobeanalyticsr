# This code is executed in the package environment
.AAEnv <- new.env(parent = emptyenv())
.AAEnv$Token <- NULL
.AAEnv$AuthMethod <- "oauth"

# Set token to environment
set_token <- function(value) {
  .AAEnv$Token <- value
  return(value)
}

# Get token from environment
get_token <- function() {
  .AAEnv$Token
}

#' Authenticate with the AdobeAnalytics API V2.0 using JWT
#'
#' @param config_file path to the JWT interface configuration JSON file.
#'                    If not provided, will attempt to read from the environment
#'                    variable \code{AW_JWT_CONFIG_FILE}
#' @param key_file path to the private key used to sign the JWT
#'                 If not provided, will attempt to read from the environment
#'                 variable \code{AW_JWT_PRIVATE_KEY_FILE}
#'
#' @return Auth token
#'
#' @export
#' @import jose
#' @import httr
auth_jwt <- function(config_file = Sys.getenv("AW_JWT_CONFIG_FILE"),
                     key_file = Sys.getenv("AW_JWT_PRIVATE_KEY_FILE")) {

  assertthat::assert_that(
    assertthat::is.string(config_file),
    assertthat::is.string(key_file)
  )

  token <- get_token()
  if(!is.null(token)) {
    return(token)
  }

  # Read the configuration file to get access to the API_KEY,
  # TECHNICAL_ACCOUNT_ID, and CLIENT_SECRET
  adobe_config <- jsonlite::read_json(config_file)

  # Write the ORG_ID to the environment
  Sys.setenv(AW_CLIENT_SECRET = adobe_config$CLIENT_SECRET)
  Sys.setenv(AW_CLIENT_ID = adobe_config$API_KEY)

  # Create the JWT
  jwt <- get_jwt(adobe_config, key_file)

  token <- exchange_jwt(jwt = jwt,
                      ims_exchange = "https://ims-na1.adobelogin.com/ims/exchange/jwt",
                      config = adobe_config)

  .AAEnv$AuthMethod <- "jwt"
  set_token(token)
  message("Authentication successful! You can now make API calls.")
}

#' Create a JWT which can ben exchanged with the AdobeAnalytics API V2.0 for an
#' authentication token (bearer).
#'
#' @keywords internal
#'
#' @param config list containing the JWT integration settings downloaded from the
#'               Adobe I/O Console.
#' @param key_file path to the RSA private key which will be used to sign the JWT
#'
#' @return jwt A signed JWT encoded as a Base64 string
#'
get_jwt <- function(config,
                    key_file
) {
  private_key <- openssl::read_key(key_file)
  # Create the JWT payload
  claim <- jose::jwt_claim(
    exp = as.numeric(as.POSIXlt(Sys.time(), tz = "UTC") + 30),
    iss = config$ORG_ID,
    sub = config$TECHNICAL_ACCOUNT_ID,
    aud = paste("https://ims-na1.adobelogin.com/c/", config$API_KEY, sep = "")
  )
  scope <- "https://ims-na1.adobelogin.com/s/ent_analytics_bulk_ingest_sdk"
  claim[scope] <- TRUE

  return(jose::jwt_encode_sig(claim, private_key))
}

exchange_jwt <- function(jwt,
                         ims_exchange,
                         config) {
  message("Exchanging JWT for Auth token...")
  post_body <- list(client_id = config$API_KEY,
                    client_secret = config$CLIENT_SECRET,
                    jwt_token = jwt)

  r <- httr::POST(url = ims_exchange,
                  body = post_body,
                  encode = "form")
  stop_for_status(r)
  responseJson <- jsonlite::fromJSON(httr::content(r, as = "text"))

  return(responseJson$access_token)
}
