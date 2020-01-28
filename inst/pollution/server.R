#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


'%>%'  <- magrittr::`%>%`
#CRAN zoo


h = hash::hash()
h2 = hash::hash()


scraping <- function(id)
{
  url <- paste0("http://dati.comune.milano.it/api/action/",
                "datastore_search?", paste("resource_id=", id,"&limit=10000", sep=""))
  page <- httr::GET(url) # API request
  httr::status_code(page) # # Check that the call is successful
  leggo_list <- jsonlite::fromJSON(url)
  leggo <- leggo_list$result$records
  return(leggo)

}

stazioni_clean <- function(file)
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

checkYears <- function(year)
{
  if(is.null(h[[year]])| is.null(h2[[year]]))
  {

    id <- switch(year,"2019" = "698a58e6-f276-44e1-92b1-3d2b81a4ad47" ,"2018"= "ea80c691-74bd-4356-94b6-0f446f190c0b","2017" =  "a032a06e-24c2-4df1-ac83-d001e9ddc577")
    df = scraping(id)
    test = datacleaning(df)
    h[[year]] = test
    h2[[year]]= stazioni_clean(df)
  }
}
checkdataset <- function(year, pollutant)
{


#  print(paste("id:" ,id))
#  print(paste("year", year))

  checkYears(year)

  if(!is.null(pollutant))
  {
#    print(paste("poll", pollutant))

    test = h[[year]]
    test = subset(test,subset= test$inquinante==pollutant)
    test= test[,c('data','valore')]

    return(test)

  }


  else
  {
    df = h2[[year]]
    return(df)
  }

}



shinyServer(function(input, output) {




  # test <- reactive({

  #  if(input$years == "2019")
  #    id = "698a58e6-f276-44e1-92b1-3d2b81a4ad47"
  # else if(input$years=="2018")
  id= "ea80c691-74bd-4356-94b6-0f446f190c0b"
  #  else if (input$years=="2017")
  #    id = "a032a06e-24c2-4df1-ac83-d001e9ddc577"
  #  else
  #    stop("Dataset ID not found")

  #  if(is.null(h[[input$years]]))
  #  {
  #
  #df = scraping(id)
  #     test = datacleaning(df)

  #     h[[input$years]] = test
  #    h2[[input$yearstation]]= df
  #  }

  #  df = h2[[input$yearstation]]
  #  test = h[[input$years]]

  # })

  # df <- reactive({
  # if(input$yearstation == "2019")
  #   id = "698a58e6-f276-44e1-92b1-3d2b81a4ad47"
  # else if(input$yearstation=="2018")
  #   id= "ea80c691-74bd-4356-94b6-0f446f190c0b"
  # else if (input$yearstation=="2017")
  #   id = "a032a06e-24c2-4df1-ac83-d001e9ddc577"
  #else
  #  stop("Dataset ID not found")
  # if(is.null(h2[[input$yearstation]]))
  # {

  #   df = scraping(id)
  #  h2[[input$yearstation]] = stazioni_clean(df)
  # }

  # df = h2[[input$yearstation]]
  # })
  #         df = scraping("698a58e6-f276-44e1-92b1-3d2b81a4ad47")
  #    else if (input$years == "2018")
  #       df = scraping("ea80c691-74bd-4356-94b6-0f446f190c0b")

  #   else if(input$years =="2017")
  #      df = scraping("a032a06e-24c2-4df1-ac83-d001e9ddc577")
  # else
  #    stop("Unexpected dataset")
  #    })

  output$stations_info <- renderText({
    paste("In the year",
          input$yearstation, "there were", length(checkdataset(input$yearstation,NULL)$station_id), "active stations.","<br>","The active station were: ")
  })

  output$stations_active <- renderText({
    paste(checkdataset(input$yearstation,NULL)$station_id)
  })
  output$stations_plot <-plotly::renderPlotly(
    {

      #flat =  checkyears(input$yearstation, TRUE)
      #flat = checkdataset()
      df =  checkdataset(input$yearstation,NULL)

      plotly::plot_ly(df,
                      x = df$station_id,
                      y = df$total_detected,
                      type = "bar",color =df$station_id
      ) %>%
        plotly::layout(title = paste("Number of detected datas from each station - year:",input$yearstation),
                       xaxis = list(title = "Station ID"),
                       yaxis = list(title = "Data detected"))

    })

  output$Timeseries <-plotly::renderPlotly({



    #  test= checkdataset()
    #test = checkyears(input$years, FALSE)
    # Render timeseries plot
    poll =  checkdataset(input$years,input$pollutant)
    inp = input$pollutant


    if(input$regression)
    {
      fit <- lm( poll$valore ~ poll$data, data = poll)

      plotly::plot_ly(x = poll$data, y = poll$valore, name ="values ",type = 'scatter',mode = 'line')%>%
        plotly::layout(title = paste('Value of ',inp, "per day of ", input$years),
                       xaxis = list(title = 'Days'),
                       yaxis = list (title = paste('Value of ',inp))) %>%
        plotly::add_lines(x = ~poll$data, y = fitted(fit), name="regression")

    }

    else
    {
      plotly::plot_ly(x = poll$data, y = poll$valore, name ="values ",type = 'scatter',mode = 'line')%>%
        plotly::layout(title = paste('Value of ',inp, "per day of ", input$years),
                       xaxis = list(title = 'Days'),
                       yaxis = list (title = paste('Value of ',inp)))
    }
  })

  output$Forecast<-plotly::renderPlotly({

    #   test= checkdataset()
    poll = checkdataset(input$years,input$pollutant)

    time =xts::xts(poll[,-1],order.by = poll[,1])
    fit = forecast::auto.arima(time)
    TSplotly::TSplot(50,forecast::forecast(fit,input$lag),  Ylab = "Value", Xlab = "Time(Day)",NEWtitle="ARIMA Forecast",title_size =15, ts_original = "Original time series", ts_forecast= "Predicted time series")

    # Render a forecast plot

  })


})


#pollution <- function()
#{
  # Create Shiny app ----
#  shiny::shinyApp(ui = shinyUI, server = shinyServer)
#}
