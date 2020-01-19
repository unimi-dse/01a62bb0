#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#For Make a README
#https://www.makeareadme.com/

milanpollution <- function() {


    loadlibreries()
    filerd= scraping()
    test = datacleaning(filerd)
    url = a("Comune di Milano", href="https://dati.comune.milano.it/dataset")

    # Define UI for application that draws a histogram
    ui <- fluidPage(
        headerPanel("Analysis of pollutants Milan"),
        hr(),

        titlePanel("Milan pollution 2019"),
        sidebarLayout(
            sidebarPanel(
                # Dropdown menu for selecting variable from GE data.
                selectInput("pollutant",
                            label = "Select pollutant type",
                            choices = unique(test$inquinante),
                            selected = "PM10"),
                 # Default selection
                sliderInput("lag",
                            "Forecasting lags:",
                            min = 1,  max = 50, value = 10),


                hr(),
                checkboxInput("regression", "Show Regression line", FALSE),
                hr(),
                    helpText("Data from openData",url),


            ),

            mainPanel(

                plotOutput("Timeseries"),
                plotOutput("Forecast"),

            ),


        )
    )
    # Define server logic required to draw plots
    server <- function(input, output) {



        output$Timeseries <- renderPlot({

            if(input$regression)
            {
                inp = input$pollutant

                poll = subset(test,subset= inquinante==inp)
                poll= poll[,c('data','valore')]
                ggplot(poll, aes(x=data,y=valore, group=1))+geom_point()+geom_line()+ geom_smooth(method="lm")
                #Render plot data on x and value on y

            }

            else
                {
                    inp = input$pollutant

                    poll = subset(test,subset= inquinante==inp)
                    poll= poll[,c('data','valore')]

                    time = poll$data = NULL
                    time.ts = as.ts(poll)
                    plot(time.ts)+ geom_smooth(method="lm")
                    # Render timeseries plot

            }

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
    require(shiny)
    require(ggplot2)
    require(forecast)
    require(xts)
    require(ckanr)
    require(httr)
    require(jsonlite)
    require(tidyverse)
   # require(shinydashboard)
#    require(leaflet)

}

scraping <- function()
{
    url <- paste0("http://dati.comune.milano.it/api/action/",
                  "datastore_search?",
                  "resource_id=698a58e6-f276-44e1-92b1-3d2b81a4ad47&limit=10000")
    page <- GET(url) # API request
    status_code(page) # # Check that the call is successful
    leggo_list <- fromJSON(url)
    leggo <- leggo_list$result$records

    return(leggo)

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


installpack <- function()
{
    i =c("shiny","ggplot2","forecast","xts","ckanr","httr","jsonlite","tidyverse")
    for(j in i)
        if(!require(j))
            install.packages(j)
}

milanpollution()
