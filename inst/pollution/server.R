#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#CRAN zoo

'%>%'  <- magrittr::`%>%`



#' restfullAPI
#'
#' Get the dataset from the Opendata website of the city of Milan using CRAN API.
#' @param id character. Identify the id of the dataset. if \code{NULL} return an error
#'
#' @return data.frame
#'
#' @examples
#' \dontrun{
#' restfullAPI(id)
#' }
#' #' @export
#'


shinyServer(function(input, output) {


  output$stations_info <- renderText({
    paste("In the year",
          input$yearstation, "there were", length(checkdataset(input$yearstation,NULL)$station_id), "active stations.","<br>","The active station were: ")
  })

  output$stations_active <- renderText({
    paste(checkdataset(input$yearstation,NULL)$station_id)
  })
  output$stations_plot <-plotly::renderPlotly(
    {

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

    poll = checkdataset(input$years,input$pollutant)

    time =xts::xts(poll[,-1],order.by = poll[,1])
    fit = forecast::auto.arima(time)
    TSplotly::TSplot(50,forecast::forecast(fit,input$lag),  Ylab = "Value", Xlab = "Time(Day)",NEWtitle="ARIMA Forecast",title_size =15, ts_original = "Original time series", ts_forecast= "Predicted time series")

    # Render a forecast plot

  })


})
