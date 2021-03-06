% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/auth.R
\name{get_request_token}
\alias{get_request_token}
\title{get_request_token}
\usage{
get_request_token(consumer_key)
}
\arguments{
\item{consumer_key}{character string. Your Pocket consumer key.}
}
\value{
character string. Request token for the Pocket Application corresponding to consumer_key.
}
\description{
requests a request_token for the Pocket application with a given consumer key from the Pocket Authentication API. The request token can then be used in \code{\link{create_authorize_url}} and \code{\link{get_access_token}}.
}
\details{
See the \href{https://github.com/CorrelAid/pocketapi}{GitHub README} for details.
}
\seealso{
Other authentication functions: 
\code{\link{create_authorize_url}()},
\code{\link{get_access_token}()}
}
\concept{authentication functions}
