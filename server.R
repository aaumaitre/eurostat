#libraries
library(shiny)
library(tidyverse)
library(plotly)
library(rsconnect)

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
    lines_data <- subset(eurostat, 
                        Country == GEOSelected & 
                          ind == INDSelected &
                          Year >= input$years[1] & 
                          Year <= input$years[2] &
                          age_groups == AGESelected &
                          sex == SEXSelected
    )
    
    #And with this the  plot is created
    h1 <- lines_data%>%
      ggplot(aes(x = Year, y = Value, group = Country))+
      geom_line(color = "dodgerblue")+
      labs(title = INDSelected)+
      theme_minimal()
    
    ggplotly(h1)
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
      ggplot(aes(x = reorder(Country, Value), y = Value))+
      geom_bar(stat = "identity", fill = "dodgerblue")+
      labs(title = IBSelected)
      theme_minimal()
    
    ggplotly(h2)
    
  }))
  
}
