#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#


milanpollution <- function() {


    loadlibreries()
    test = datacleaning()
    # Define UI for application that draws a histogram
    header <- dashboardHeader(
        title = "Milan pollution 2019"
    )
    ui <- fluidPage(
        titlePanel("Milan pollution 2019"),
        sidebarLayout(
            sidebarPanel(
                # Dropdown menu for selecting variable from GE data.
                selectInput("pollutant",
                            label = "Select pollutant type",
                            choices = unique(test$inquinante),
                            selected = "PM10"),
                hr(),
                helpText("Data from openData comune di Milano"),
                # Default selection
                sliderInput("lag",
                            "Forecasting lags:",
                            min = 1,  max = 50, value = 1),
            ),




            mainPanel(

                plotOutput("BarPlot"),
                plotOutput("Timeseries"),
                plotOutput("Forecast")

            ),


        )
    )
    # Define server logic required to draw plots
    server <- function(input, output) {


        output$BarPlot <- renderPlot({
            inp = input$pollutant

            poll = subset(test,subset= inquinante==inp)
            poll= poll[,c('data','valore')]
            ggplot(poll, aes(x=data,y=valore, group=1))+geom_point()+geom_line()+ geom_smooth(method="lm")

            #Render plot data on x and value on y
        })


        output$Timeseries <- renderPlot({
            inp = input$pollutant

            poll = subset(test,subset= inquinante==inp)
            poll= poll[,c('data','valore')]
            ggplot(poll, aes(x=data,y=valore, group=1))+geom_point()+geom_line()+ geom_smooth(method="lm")

            time = poll$data = NULL
            time.ts = as.ts(poll)
            plot(time.ts)
            # Render timeseries plot

        })

        output$Forecast<- renderPlot({
            inp = input$pollutant
            poll = subset(test,subset= inquinante==inp)
            poll= poll[,c('data','valore')]
            ggplot(poll, aes(x=data,y=valore, group=1, color=valore))+geom_point()+geom_line()+ geom_smooth(method="lm")

            time = poll$data = NULL
            time.ts = as.ts(poll)
            fit = auto.arima(time.ts)


            # Render a forecast plot
            plot(forecast(fit,input$lag))
        })
    }

    # Run the application
    shinyApp(ui = ui, server = server)
}

loadlibreries <- function()
{
    library(shiny)
    library(ggplot2)
    library(forecast)
    library(xts)
    library(ckanr)
    library(httr)
    library(jsonlite)
    library(tidyverse)
    library(shinydashboard)
    library(leaflet)

}

datacleaning <- function()
{
    url <- paste0("http://dati.comune.milano.it/api/action/",
                  "datastore_search?",
                  "resource_id=698a58e6-f276-44e1-92b1-3d2b81a4ad47&limit=10000")
    page <- GET(url) # API request
    status_code(page) # # Check that the call is successful
    leggo_list <- fromJSON(url)
    leggo <- leggo_list$result$records

    Data = leggo
    Data$stazione_id=NULL
    Data$`_id`=NULL
    Data$valore = as.double(Data$valore)
    Data$inquinante = as.factor(Data$inquinante)
    Data = Data[complete.cases(Data),]
    Data$data = as.Date(Data$data)
    test = aggregate(valore~ data+inquinante, Data , mean)
}
milanpollution()

