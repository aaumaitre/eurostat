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
