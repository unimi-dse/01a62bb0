# 01a62bb0

<h1> Milan pollution Shiny App </h1>
<p> The aim of this project is the analysis of the data taken from the site of the Comune di Milano using CKAN Data Application programming interface(API). </p>
<br>
<h2> Installation</h2>

```R
# first install the R package "devtools" (.... OTHERS TO BE SPECIFIED) if not installed
devtools::install_github('unimi-dse/01a62bb0')
```

<br>
<h2> Usage</h2>
<p> Load the package </p>

```R
require(milanpollution)
```

<p> There are two main functions of the package that are <code> milanpollution()</code> and <code> installpack()</code>.
  
 <h3> Functions </h3>
 <code> installpack()</code>
 <p>This function will install the needed packages to run the application. <bold> It is suggested </bold> to run this function before the <italic> milanpollution() </italic> function </p>

<br>
 <code> milanpollution()</code>
  <p> This function loads the Shiny  application </p>
  
  <br>
 <h2> Description of the application </h2>
<p> When runned the milanpollution() function in the console, will be charged the application. It takes a bit to get and charge the data from the OpenData Comune di Milano site using CKAN API </p>

<p> Charged the dataset, the application starts.</p>

<h3> Main page: Pollution </h3>
#--- put IMAGE ---
<p> In the main page are presented two plots: the time series of the datas and the related forecast. 
  <li> The first plot represents the time series of the data deteceted by every station day by day. It is possible to check the Checkbox to enable the visualization of the linear regression line. </li>
  <li> The second plot represents the forecast of the time series. It is possible to set a different lag for the forecast using the selector. </li>
  <p> Then is possible to select the year of the dataset in interest. </p>
</p>
