## A Shiny app for visualizing Eurostat Statistics in Income and Living Conditions
_Ariane Aumaitre, 16 June 2019_


This repository contains a shiny app developed to plot Eurostat statistics on income and living conditions. 
The running app can be found in <https://aaumaitre.shinyapps.io/Eurostat/> . All data come from Eurostat 
and have been retrieved by using the [eurostat R library](http://ropengov.github.io/eurostat/) by [rOpenGov](https://ropengov.github.io). More information about the data can be found 
[here](https://ec.europa.eu/eurostat/web/income-and-living-conditions/data/database). The dataset used for the app 
contains information on 34 countries for as long as there has been availability on the indicator. 
The app allows to switch among countries, years, indicators, age groups and sex.

This repo contains one file for the data and two for the source code: 

* ui.R defines the user interface

* server.R generates the desired output

The first tab of the app generates line charts across time, while the second one creates static barplots. 
Charts are created using `ggplot2` and `plotly` for R. 

![](https://i.ibb.co/dG54S08/image.png)

### Basic syntax of a Shiny app

Any Shiny app is built using two elements: an user interface and a server, that are then both run using
the `shinyApp()` function. If you're using RStudio, you can start building your app by doing **new file -> Shyny Web App**.
It's up to you whether you want to have your app in one or two R files, just remember to add the `shinyApp()` line at the end of 
your script if you're using a single file (you'll see that I'm using two files for my app - I find it simpler). 

In a nutshell, the **user interface** is the part of your code where the inputs (i.e. the elements to be personalized) are defined, 
together with the layout we want to give to the final app (this includes which outputs will be present and where they will show up).
The **server**, on the other hand, defines the way in which _outputs_ are to be built.

In our Eurostat app, you can see that the ui file contains all features related to side pannels (whic elements can be selected and how),
as well as the information stating that the app will have three tabs, their names and layouts. The server file relates the app inputs with 
our data and defines how the plots are to look like.

### The user interface

You can find the user interface code in the ui.R file. The code is all annotated, but these are some elements you may want
to keep in mind if trying to replicate or to edit with your own data.

* `fluidPage()` is the function that we'll be using to create our ui. It will define how the app will look like. 

* As I wanted to have three apps in my app, I'm using `tabsetPanel` with `type = "tabs"`. Within this function,
each call to `tabPanel()` specifies the layout within each tab. You'll see that the elements of the side bar change for every
tab as I wanted them to be different, that's why `sidebarPanel` is located within `tabPanel` and not outside. 

* `sidebarPanel()` creates the side bar where the user will be selecting the different inputs. Here, each call to `selectInput`
refers to a different element (countries,a ge, sex...). Within this function, we always need to specify an `inputId` - the way
we will call this element throughout the code, a `label` - the name to be shown in the app, the `choices` that the input can take
and the `selected` choice by default. Other arguments can be added, such as `multiple`, that allows to select different options
from the choices at the same time.

* In addition to several `selectInput()`, you'll notice that the side bar also includes a call to `sliderInput()`,
that allows to choose the year range that we want to see in the x-axis. The function works in a pretty similar way to `selectInput()`.

* After defining the side bar, we need to tell R what to show in the body of the app. This is done with the 
`mainPanel(plotlyOutput("lines"))` call, where `mainPanel()` states that we're now designing the body of the app
and `plotlyOutput` that this section will show an plotly to be defined in the server. `"lines"` is the name that we will be using
to refer to this output.

* The rest of the code follows the exact same logic to create the bar plots tab. Since the last tab includes only text with 
the app information, it is directly defined within the `tabPanel()` call.

```r
#Libraries needed
library(shiny)
library(tidyverse)
library(rsconnect)
library(plotly)

#Data to be used
load("eurostat.RData")


#Creating the user interface
fluidPage(
  #This line allows the app to show properly on mobile devices:
  HTML('<meta name="viewport" content="width=1024">'),
  
  #Setting the relative size of the sidebar and the plot area:
  tags$head(tags$style(HTML(".col-sm-4 { width: 25%;}
                    .col-sm-8 { width: 75%;}")),
            #Title to be shown @ browser (to get rid of html tags)
            tags$title("Plotting Eurostat statistics on income and living conditions")),

  
  # Application title
  headerPanel(HTML("<b><center>Plotting Eurostat statistics on income and living conditions</b></center></br>")),
  

  
  #Giving a tabset appearance to the app
  tabsetPanel(type = "tabs",
              #Each tabPanel call specifies input for contents of tab
              tabPanel("Line plots", #Tab title
                       sidebarLayout( #To have a personalized sidebar per tab
                         sidebarPanel(
                           #creating the select lists for countries, indicators, sex, age:
                           selectInput(inputId = "geo",
                                       label = "Select countries:",
                                       choices = levels(eurostat$Country),
                                       selected = levels(eurostat$Country)[1],
                                       multiple = TRUE), #allowing multiple country selection
                           selectInput(inputId = "ind",
                                       label = "Select indicator:",
                                       choices = levels(eurostat$ind),
                                       selected = levels(eurostat$ind)[5]),
                           selectInput(inputId = "age",
                                       label = "Age groups:",
                                       choices = levels(eurostat$age_groups),
                                       selected = "Total"),
                           selectInput(inputId = "sex",
                                       label = "Sex:",
                                       choices = levels(eurostat$sex),
                                       selected = "Total"),
                           #Slider bar to allow custom x axis
                           sliderInput("years", "Year range",
                                       min(eurostat$Year), max(eurostat$Year),
                                       value = c(1995, 2018),
                                       step = 5)),
                         #The main panel of the tab will show the lines plot(ly)
                         mainPanel(plotlyOutput("lines")))),
              #Same process for the next tab: bar plots 
              #(some changes made to the options in the side panel)
              tabPanel("Bar plots",
                       sidebarLayout(
                         sidebarPanel( selectInput(inputId ="years_b", 
                                                   label = "Year",
                                                   choices = c(1995:2018),
                                                   selected = 2017),
                                       selectInput(inputId = "ind_b",
                                                   label = "Indicator",
                                                   choices = levels(eurostat$ind),
                                                   selected = levels(eurostat$ind)[5]),
                                       selectInput(inputId = "age_b",
                                                   label = "Age groups",
                                                   choices = levels(eurostat$age_groups),
                                                   selected = "Total"),
                                       selectInput(inputId = "sex_b",
                                                   label = "Sex",
                                                   choices = levels(eurostat$sex),
                                                   selected = "Total")),
                         mainPanel(plotlyOutput("bars")))),
              #Panel with information about the app:
              tabPanel("About", 
                       p(HTML("This is a Shiny Application built to plot statistics on income and living conditions from Eurostat.")),
                       p(HTML("It allows to either compare countries across time by using line charts, or to take more specific snapshots of a moment in time by comparing the 34 countries available.")),
                       p(HTML("You can browse through different indicators and look at their values while specifying sex ang age groups.")),
                       p(HTML("Passing the mouse over the chart gives the exact values of the indicators by country and year.")),
                       p(HTML("Code for the app is available on <a href= https://github.com/aaumaitre/eurostat/>Github</a>")),
                       p(HTML("Data comes from Eurostat and has been retrieved using the eurostat package in R")),
                       p(HTML("Plots are generated using ggplot2 and ggplotly.")),
                       p(HTML("</br>For any questions or inquiries, you can find me at <a href=https://arianeaumaitre.com/> arianeaumaitre.com</a> or on <a href = https://twitter.com/ariamsita>Twitter</a>."))
                       )
              
  ))
```

### The Server

Remember the names that we were giving to the inputs and outputs? Now is when we're going to use them. Within the server,
we will create a function defining exactly what is to be showed there where we indicated an output in the ui. We will also 
specify the relationship between outputs and inputs.

* We start with `output$lines <- renderPlotly({` , that signals that we will be using our output called "lines" and
that we will be creating a plotly object  (in our case, combining `ggplot2` with the `ggplotly()` function.

* Within `renderPlotly`, I first allocate names to _all selected inputs_, making sure that we now have an object for each
of the selections made in the side bar. Once this is done, I create a dataframe (`lines_data`) that subsets the original data in function of all these objects --> this allows R to know which data to show in the final plot, at the same time that it matches inputs 
and outputs.

* Once the data frame has been defined, I create the `h1` plot object giving it the values I want to be showed and pass it to  `ggplotly()` including some aesthetic details.

* The process for the bar plot is exactly the same

```r

#libraries
library(shiny)
library(tidyverse)
library(plotly)
library(rsconnect)
library(wesanderson)

#data
load("eurostat.RData")

#Server function to define the output that will be shown in the app

function(input, output) {

  #First, the lines chart
  output$lines <- renderPlotly({
    #The "Selected" variables will serve to subset out data in function of
    # the input: they are a way of storing the input selected
    GEOSelected = input$geo
    INDSelected = input$ind
    AGESelected = input$age
    SEXSelected = input$sex
    #To link the input selected with our dataframe, we subset our data
    #frame ("eurostat") with the values selected by the user and create
    #a data frame
    lines_data <- 
      subset(eurostat, 
             Country %in% GEOSelected & 
               ind == INDSelected &
               Year >= input$years[1] & 
               Year <= input$years[2] &
               age_groups == AGESelected &
               sex == SEXSelected)
    
    #And with this the  plot is created
    h1 <- lines_data%>%
      ggplot(aes(x = Year, y = Value, color = Country))+
      geom_line(size = 0.8)+
      geom_point(size = 1.8)+
      #The second argument in wes_palette makes values change depending on 
      #the number of countries that are selected
      scale_color_manual(values =rev(wes_palette("Darjeeling1", 
                                                 length(unique(lines_data$Country)), 
                                                 type = "continuous")))+
      #bringing some air to the plot:
      expand_limits(y = (max(lines_data$Value) + 0.05*max(lines_data$Value)))+
      scale_x_continuous(breaks = seq(min(lines_data$Year), max(lines_data$Year), by = 2))+
      labs(title = INDSelected,
           x = NULL, y = NULL, color = NULL)+ 
      theme_minimal()+
      theme(panel.grid.major.y = element_line(color = "grey87"), 
            panel.grid.major.x = element_blank(),
            axis.line.x = element_line(color = "grey87"),
            axis.ticks.x = element_line(color = "grey40"),
            plot.title = element_text(size = 16, hjust = 0.5, face = "bold"),
            axis.text.x = element_text(size = 10, color = "grey40"),
            axis.text.y = element_text(size = 10, color = "grey40"))
    
    ggplotly(h1, width = 1200, height = 600)%>%
      layout(legend = list(orientation = "h", x = 0.3, y =-0.1))
  }
  )
  
  #Same process for the bar chart:
  output$bars <- renderPlotly(({
    IBSelected = input$ind_b
    YBSelected = input$years_b
    AGEBSelected = input$age_b
    SEXBSelected = input$sex_b
    
    
    bars_data <- subset(eurostat,                                             
                        ind == IBSelected &
                          Year == YBSelected & 
                          age_groups == AGEBSelected &
                          sex == SEXBSelected)
    
    h2 <- bars_data%>%
      ggplot(aes(x = reorder(Country, Value), y = Value,
                 text = paste0(Country, " ", Year,": ", Value)))+
      geom_bar(stat = "identity", fill = "dodgerblue", width = 0.5)+
      expand_limits(y = (max(bars_data$Value) + 0.05*max(bars_data$Value)))+
      labs(title = IBSelected, y = NULL, x = NULL)+
      theme_minimal()+ 
      theme(panel.grid.major.y = element_line(color = "grey87"), 
            panel.grid.major.x = element_blank(),
            axis.line.x = element_line(color = "grey87"),
            axis.ticks.x = element_line(color = "grey40"),
            plot.title = element_text(size = 16, hjust = 0.5, face = "bold"),
            axis.text.x = element_text(size = 10, color = "grey40", angle = 45),
            axis.text.y = element_text(size = 10, color = "grey40"))
    
    ggplotly(h2, tooltip = "text", width = 1200, height = 600)
  
  }))
  
}
```

### And now what??

We're done! If you're using RStudio, all you have to do is click **'Run App'** and let the magic happen. If you want
to deploy your app, you can do it directly from [Shiny](https://www.shinyapps.io/) - just remember that you need to
be using a Shiny App file and not a normal script, and that your data file should be in the same folder as your app files. 
This may save you some headaches :)

If you have any questions or want to know more, feel free to drop a [tweet](https://twitter.com/ariamsita) or
send an [email](ariane.aumaitre@gmail.com).
