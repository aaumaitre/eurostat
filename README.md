---
title: "Eurostat shiny app"
author: "Ariane Aumaitre"
date: "16 June 2019"
output: html_document
---

This repository contains a shiny app developed to plot Eurostat statistics on income and living conditions.

The running app can be found in <https://aaumaitre.shinyapps.io/Eurostat_dataviz/>

All data come from Eurostat and have been retrieved by using the Eurostat R library. More information about the data can be found here: <https://ec.europa.eu/eurostat/web/income-and-living-conditions/data/database>

Data contains information on 34 countries for as long as there has been availability on the indicator. The app allows to switch among countries, years, indicators, age groups and sex.

This repo contains one file for the data and two for the source code: 

-ui.R defines the user interface
-server.R generates the desired output

The first tab of the app generates line charts across time, while the second one creates static barplots. Charts are created using the rCharts library: <https://ramnathv.github.io/rCharts/> 
