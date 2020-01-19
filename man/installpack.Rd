\name{installpack}
\alias{installpack}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Install missing packages}
\description{
Install every missing packages needed by the application milanpollution.
}
\usage{
installpack()
}

\author{
Andrea Ierardi
}


\examples{

## The function is currently defined as
installpack <- function()
{
    i =c("shiny","ggplot2","forecast","xts","ckanr","httr","jsonlite","tidyverse")
    for(j in i)
        if(!require(j))
            install.packages(j)
}

}

