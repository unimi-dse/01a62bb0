#' Checkdataset
#'
#' Check whether and which dataset is already loaded, download and visualise it.
#' If the dataset is loaded, then get that from an \code{hash}, if not loaded then call \code{\link{restfullAPI}} and upload the \code{hash}
#'
#' @param year character. The year of the dataset to check
#' @param pollutant character. The name of the pollutant to check. if \code{NULL} (the default) means we are checking the dataset for the stations
#'
#' @return data.frame
#'
#' @export
#' @examples
#' checkdataset(year, pollutant)
#'
#'
#'
checkdataset <- function(year, pollutant = NULL)
{


  #check if the year is already loaded
  checkYears(year)

  #If pollutant is not NULL, then are requested dataset for timeseries(page 1)
  if(!is.null(pollutant))
  {

    test = h[[year]]
    test = subset(test,subset= test$inquinante==pollutant)
    test= test[,c('data','valore')]

    return(test)

  }

  #else pollutant is NULL, then are requested dataset for stations info(page 2)
  else
  {
    df = h2[[year]]
    return(df)
  }

}

h = hash::hash()
h2 = hash::hash()


#Check if dataset is already loaded
checkYears <- function(year)
{
  if(is.null(h[[year]])| is.null(h2[[year]]))
  {

    id <- switch(year,"2019" = "698a58e6-f276-44e1-92b1-3d2b81a4ad47" ,"2018"= "ea80c691-74bd-4356-94b6-0f446f190c0b","2017" =  "a032a06e-24c2-4df1-ac83-d001e9ddc577")
    df = restfullAPI(id)
    test = datacleaning(df)
    h[[year]] = test
    h2[[year]]= station_clean(df)
  }
}

#Clean the dataset for time series
datacleaning <- function(leggo)
{
  Data = leggo
  Data$stazione_id=NULL
  Data$`_id`=NULL
  Data$valore = as.double(Data$valore)
  Data$inquinante = as.factor(Data$inquinante)
  Data = Data[complete.cases(Data),]
  Data$data = as.Date(Data$data)
  test = aggregate(valore~ data+inquinante, Data , mean)

  return (test)
}

#Clean the dataset for station infos
station_clean <- function(file)
{
  file$valore = as.double(file$valore)
  file$inquinante = as.factor(file$inquinante)
  file$stazione_id = factor(file$stazione_id)
  file = file[complete.cases(file),]


  i = sort(unique(file$stazione_id))
  df = data.frame()
  for(j in i)
  {
    missing = file$stazione_id == j
    lis = list(j,length(file$stazione_id[missing]))
    df = rbind(df,lis,stringsAsFactors=FALSE)
  }
  colnames(df)= c("station_id","total_detected")

  return(df)


}

