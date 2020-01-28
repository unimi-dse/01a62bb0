#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#



'%>%'  <- magrittr::`%>%`

url = a("Comune di Milano", href="https://dati.comune.milano.it/dataset")


# Define UI for application that draws a histogram
shiny::shinyUI(fluidPage( theme= "style.css",


  div(titlePanel(h1("MILAN POLLUTION ANALYSIS",id="testa"))),

  hr(),

  div(
      navbarPage(  "Pollution Milan",
                   tabPanel("Pollution",

                            sidebarLayout(

                              sidebarPanel( id="side",
                                            # Dropdown menu for selecting variable from GE data.
                                            selectInput("pollutant",
                                                        label = "Select pollutant type",
                                                        choices = c("SO2","C6H6","CO_8h","NO2","O3","PM10","PM25","SO2"),
                                                        selected = "PM10"),
                                            # Default selection
                                            sliderInput("lag",
                                                        "Forecasting lags:",
                                                        min = 1,  max = 50, value = 10),

                                            checkboxInput("regression", "Show Regression line", TRUE),

                                            hr(),

                                            selectInput("years",
                                                        label = "Select the year",
                                                        choices = c("2019","2018","2017"),
                                                        selected = "2019"),


                                            helpText("Data from openData",url),
                                            tags$img(src="milan.png", width = "80px", height = "100px",id="image"),




                              ),

                              mainPanel(id="backg",

                                        h1("Plot results"),
                                        hr(),
                                        plotly::plotlyOutput('Timeseries')%>% shinycssloaders::withSpinner(color="#0dc5c1"),
                                        br(),
                                        hr(),
                                        plotly::plotlyOutput("Forecast")%>% shinycssloaders::withSpinner(color="#0dc5c1"),
                                        br(),

                              )


                            ) ),

                   tabPanel(id="side","Stations",
                            sidebarLayout(
                              sidebarPanel( id="side",

                                            h1("Number of active stations"),
                                            hr(),

                                            htmlOutput("stations_info")%>% shinycssloaders::withSpinner(color="#0dc5c1"),
                                            htmlOutput("stations_active")%>% shinycssloaders::withSpinner(color="#0dc5c1"),

                                            hr(),
                                            selectInput("yearstation",
                                                        label = "Select the year",
                                                        choices = c("2019","2018","2017"),
                                                        selected = "2019"),
                                            br(),


                                            helpText("Data from openData",url),
                                            tags$img(src="milan.png", width = "80px", height = "100px",id="image"),



                              ),

                              mainPanel(id="backg",
                                        h1("Plot results"),
                                        hr(),
                                        plotly::plotlyOutput("stations_plot")%>% shinycssloaders::withSpinner(color="#0dc5c1"),
                                        br(),
                              ))

                   ),
                   tabPanel("About", id = "side",

                            sidebarLayout(
                              sidebarPanel( id="side",

                                            h1("Author"),
                                            hr(),
                                            h2("Andrea Ierardi",id="cent"),
                                            div(id="cent",img(tags$img(src="linkedin.jpg", width = "150px", height = "150px"))),
                                            hr(),
                                            h2("Studies"),

                                            p("MSc. Data Science and Economics student - Università degli studi di Milano."),
                                            p("Graduated in Computer Science - Università del Piemonte orientale(UPO)"),
                                            hr(),

                                            h2("Link"),
                                            a("LinkedIn", href="https://www.linkedin.com/in/andreaierardi/"),
                                            br(),
                                            a("Github",href="https://github.com/Andreaierardi")


                              ),



                              mainPanel(id="backg",
                                        h1("About"),
                                        hr(),
                                        p("The aim of this project is to analysise the datas regarding pollution in Milan from the website of the Comune di Milano. In particular, the study is focused on the different pollutants detected during the years from ARPA's stations."),
                                        h2("Main page: Pollution"),
                                        p("In the main page are presented two plots: the time series representation and the forecast calcolated on the Autoregressive integrated moving average (ARIMA) model."),

                                        tags$li("The first chart is interactive and it is possible to zoom in or to select a portion of it thanks to the Plotly package. This plot represents the time series of the data deteceted day by day by every station. Checking the Checkbox is possible to enable the visualization of the linear regression line of the time series."),
                                        tags$li("The second chart(also interactive) represents the forecast of the time series. Using the slidebar, is possible to set the lags of the forecast from 1 to 50 units. "),
                                        p("Using a selector in the left side of the window, is possible to select the year of interest in the dataset. As the application receives the data with the API, the loading of the dataset speed up and there is no much delay changing the year."),
                                        hr(),

                                        h2("Second page: Stations"),
                                        p("In the second page is presented the barplot of the detected data from each station during the years. Using a selector in the left panel of the page, is possible to select the year of interest in which you are interested in displaying how much and which station were active in that year."),
                                        tags$li("In this page is possible to see the barplot(interactive) representing the number of total detected data from each station during the selected year. On the horizontal axis the are the station IDs on the vertical the detected data during the year."),

                                         hr(),

                                        h2("Third page: About"),
                                        p(" This section describes the project and the author details."),
                                        br()

                              )
                            )
                   )
      ))
))
