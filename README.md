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

<p> There are two main functions of the package that are <code> milanpollution()</code> and <code> installpack() </code>.
  
 <h3> Functions </h3>
 <code> installpack()</code>
 <p> This function will install the needed packages to run the application. It is suggested to run this function before the --- milanpollution()--- function. </p>
 <br>
 <code> milanpollution()</code>
  <p> This function loads the Shiny  application </p>
  
  
 <h2> Description of the application </h2>
