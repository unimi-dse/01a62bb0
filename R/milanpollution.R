#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

#Make a README
#https://www.makeareadme.com/




milanpollution <- function()
 {



    loadlibreries()
    url = a("Comune di Milano", href="https://dati.comune.milano.it/dataset")

    flat_ds2019= scraping("698a58e6-f276-44e1-92b1-3d2b81a4ad47")
    ds2019 = datacleaning(flat_ds2019)
    flat_ds2018 = scraping("ea80c691-74bd-4356-94b6-0f446f190c0b")

    ds2018 = datacleaning(flat_ds2018)
    flat_ds2017= scraping("a032a06e-24c2-4df1-ac83-d001e9ddc577")
    ds2017 =datacleaning(flat_ds2017)

    test =ds2019

    # Define UI for application
    ui <- fluidPage(



        titlePanel(  h1(id="big-heading", "Milan Pollution Analisys")),
        tags$style(HTML("#big-heading{ color: #7c795d; font-family: 'Raleway',sans-serif; font-size: 48px; font-weight: 600; line-height: 27px; margin: 0 0 10px; text-align: center; }")),

        hr(),
        navbarPage("Pollution Milan",
                   tabPanel("Pollution",

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


                br(),
                checkboxInput("regression", "Show Regression line", TRUE),
                hr(),
                helpText("Data from openData",url),
                hr(),
                br(),
                selectInput("years",
                            label = "Select the year",
                            choices = c("2019","2018","2017"),
                            selected = "2019"),


            ),

            mainPanel(

               # plotOutput("Timeseries"),
                plotlyOutput('Timeseries'),

plotlyOutput("Forecast2"),


            ),


        ) ),

        tabPanel("Stations",
                 sidebarLayout(
                     sidebarPanel(
                         helpText("Data from openData",url),


                     ),

                 mainPanel(

                     plotOutput("stations_plot"),

                 ))

                 ),
        tabPanel("About")
        ),
    )

    # Define server logic required to draw plots
    server <- function(input, output) {


        output$stations_plot <- renderPlot(
        {

           flat =  checkyears(input$years, TRUE)
           df =  stazioni_clean(flat)
           ggplot(df, aes(x=station_id, y=total_detected, fill=station_id)) +
           geom_bar(stat="identity",color="black")+theme_minimal()+theme(plot.title = element_text(size=18, face="bold"))+ggtitle(paste("Number of detected datas from each station year:",input$years))

        })

        output$Timeseries <- renderPlotly({




            test = checkyears(input$years, FALSE)
            # Render timeseries plot
            inp = input$pollutant

            poll = subset(test,subset= inquinante==inp)
            poll= poll[,c('data','valore')]
            if(input$regression)
            {
                fit <- lm( poll$valore ~ poll$data, data = poll)

                plot_ly(x = poll$data, y = poll$valore, name ="values ",type = 'scatter',mode = 'line')%>%
                layout(title = paste('Value of ',inp, "per day of ", input$years),
                       xaxis = list(title = 'Days'),
                       yaxis = list (title = paste('Value of ',inp))) %>%
                add_lines(x = ~poll$data, y = fitted(fit), name="regression")

            }

            else
            {
                plot_ly(x = poll$data, y = poll$valore, name ="values ",type = 'scatter',mode = 'line')%>%
                    layout(title = paste('Value of ',inp, "per day of ", input$years),
                           xaxis = list(title = 'Days'),
                           yaxis = list (title = paste('Value of ',inp)))
            }
        })

        output$Forecast<- renderPlotly({

            test = checkyears(input$years,FALSE)

            inp = input$pollutant
            poll = subset(test,subset= inquinante==inp)
            poll= poll[,c('data','valore')]
            #ggplot(poll, aes(x=data,y=valore, group=1, color=valore))+geom_point()+geom_line()+ geom_smooth(method="lm")
            time = poll$data = NULL
            time.ts = as.ts(poll)
            fit = auto.arima(time.ts)

            # Render a forecast plot
            plot(forecast(fit,input$lag))


        })

        output$Forecast2<- renderPlot({

            test = checkyears(input$years,FALSE)

            inp = input$pollutant
            poll = subset(test,subset= inquinante==inp)
            poll= poll[,c('data','valore')]
            ggplot(poll, aes(x=data,y=valore, group=1, color=valore))+geom_point()+geom_line()+ geom_smooth(method="lm")
            time = poll$data = NULL
            time.ts = as.ts(poll)
            fit = auto.arima(time.ts)

            forc =forecast(fit,input$lag)
            plot(forecast(fit, input$lag))

           # plot_ly(p)
            #    layout(title = paste('Value of ',inp, "per day of ", input$years),
             #          xaxis = list(title = 'Days'),
              #         yaxis = list (title = paste('Value of ',inp)))

            # Render a forecast plot
            #plot(forecast(fit,input$lag))
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
    require(plotly)
}

scraping <- function(id)
{
    url <- paste0("http://dati.comune.milano.it/api/action/",
                  "datastore_search?", paste("resource_id=", id,"&limit=10000", sep=""))
    page <- GET(url) # API request
    status_code(page) # # Check that the call is successful
    leggo_list <- fromJSON(url)
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

checkyears  <- function(year, flat)
{

    if(flat)
    {
        if(year=="2019")
        {
            return(flat_ds2019)
        }
        if(year=="2018")
        {
            return(flat_ds2018)
        }
        if(year=="2017")
        {
            return(flat_ds2017)
        }
    }
    if(year=="2019")
    {
        return(ds2019)
    }
    if(year=="2018")
    {
        return(ds2018)
    }
    if(year=="2017")
    {
        return(ds2017)
    }

}

installpack <- function()
{
    i =c("shiny","ggplot2","forecast","xts","ckanr","httr","jsonlite","tidyverse","plotly")
    for(j in i)
        if(!require(j))
            install.packages(j)
}


milanpollution()

