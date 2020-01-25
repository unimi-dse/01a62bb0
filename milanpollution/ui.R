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

#                          #all{background-color:rgb(174, 211, 254,0.2);background: #fff url(https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/01-big-clm-citylife-milan-image-by-big-bjarke-ingels-group-1574091716.jpg) repeat right;}


#                           background: url(https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/01-big-clm-citylife-milan-image-by-big-bjarke-ingels-group-1574091716.jpg) no-repeat center fixed;

# Define UI for application that draws a histogram
shiny::shinyUI(fluidPage(
  div(titlePanel(h1("MILAN POLLUTION ANALYSIS",id="testa"))),
  tags$style(HTML("
                          html, body {  font-size:20px;margin: 0; height: 100%;
  background: url(https://raw.githubusercontent.com/unimi-dse/01a62bb0/master/img/background2.jpg) no-repeat center fixed;
  -webkit-background-size: cover;
  -moz-background-size: cover;
  -o-background-size: cover;
  background-size: cover;
                          }

                          img {border: 1px solid gray;border-radius: 10px;}
                          html*{height:100%;font-family: Arial;overflow:auto;}
                          p {font-family: Arial;}
                          li {font-family: Arial;font-size:16px}
                          #cent{text-align:center;} p {font-size:16px;font-family:Arial}
                          h1{text-align: center;}
                          .navbar-default .navbar-brand { background-color: rgb(47,79,79,0.8);color: #ffffff;}
                          .navbar-default .navbar-brand:hover{ background-color: #2F4F4F;color: #ffffff;}
                          .navbar-default{background-color:rgb(143,188,143,0.9);color: #ffffff;border:solid 1px gray;}
                          .navbar > .container-fluid >  ul li.active a:not( :hover ){background-color:#4990c2;color:#ffffff;}
                          .navbar > .container-fluid >  ul li a:hover{background-color:#4990c2;color:#ffffff;}
                          .navbar > .container-fluid >  ul li a{background-color:rgb(143,188,143,0.8);color:#ffffff;}
                          .navbar > .container-fluid >  ul li.active a{background-color:#4990c2;color:#ffffff;}
                          .navbar > .container-fluid >  ul li.active a:hover{background-color:#4990c2;color:#ffffff;}
                         #backg{  height: 100%;border:1px solid gray;background-color:rgb(236,248,242,0.8);margin-bottom: 10px;  border-radius: 25px;}
                         #side{background-color: rgb(244,245,249,0.85);border:1px solid gray;}

                         #testa{
	margin: 0px 0px 0px 0px;
	font-weight: 50;
	font-family: 'Titillium Web', sans-serif;
	position: relative;
	font-size: 60px;
	color: #05386B;
	box-shadow:
		inset 0 0 0 1px rgba(53,86,129, 0.4),
		inset 0 0 5px rgba(53,86,129, 0.5),
		inset -285px 0 35px white;
	border-radius: 0 10px 0 10px;
	background: #fff url(https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/01-1579117277.jpg?crop=1.00xw:1.00xh;0,0&resize=2048) repeat center ;
}")),
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
                                            tags$img(src="http://dati.comune.milano.it/uploads/group/2017-11-15-122315.733556MarchioComuneMilanoVerticale4Colori.png", width = "80px", height = "100px",id="image"),




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
                                            tags$img(src="http://dati.comune.milano.it/uploads/group/2017-11-15-122315.733556MarchioComuneMilanoVerticale4Colori.png", width = "80px", height = "100px",id="image"),



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
                                            div(id="cent",img(tags$img(src="https://avatars0.githubusercontent.com/u/36515398?s=460&v=4", width = "150px", height = "150px"))),
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
                                        p("The aim of this project is to analysise the datas from the website of the Comune di Milano. In particular, the study is focused on the different pollutants detected during the years from ARPA's stations."),
                                        h2("Main page: Pollution"),
                                        p("In the main page are presented two plots: the time series representation and the forecast using the Autoregressive integrated moving average (ARIMA) model."),

                                        tags$li("The first chart is interactive and is possible to zoom in or select a portion of it thanks to the plotly package. This plot represents the time series of the data deteceted by every station day by day. It is possible to check the Checkbox to enable the visualization of the linear regression line."),
                                        tags$li("The second chart(also interactive) represents the forecast of the time series. It is possible to set a different from 1 to 50 lags using the slidebar."),
                                        p("Then is possible to select the year of the dataset in interest using a selector on the left side of the window. As the application get the datas using the API the loading of the data speed up and there is no delay changing the year."),

                                        h2("Second page: Stations"),
                                        p("In this page is possible to see the barplot(interactive) representing the number of total detected data from each station during the selected year. On the horizontal axis the are the station IDs on the vertical the detected data during the year."),
                                        h2("Third page: About"),
                                        p(" This section describes the project and the author details."),
                                        br()

                              )
                            )
                   )
      ))
))
