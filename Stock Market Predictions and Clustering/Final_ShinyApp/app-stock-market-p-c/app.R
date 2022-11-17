#Setup
library(shiny)
library(fpp3)
library(tsibble)
library(readr)
library(tidyverse)
library(plotly)
library(magrittr)
library(DT)
library(forecast)


#Loading data

df_stocks_N <- read.csv("data.csv")
head(df_stocks_N)
# forecast dates for 100 days 
fcast_date <- seq(as.Date("2021-12-31"), by = "day", length.out = 100)
df_stocks_N$Time <-  as.Date(df_stocks_N$Time)

ui <- fluidPage(
  
  # Application title
  titlePanel("Forecasting Stocks Price Using ARIMA"),
  
  br(),
  
  sidebarLayout(
    
    sidebarPanel(
      selectInput("Company", "Company:",
                  choices = colnames(df_stocks_N[2:17]))
    ),
    
    
    
    # Show forecast plots
    mainPanel(
      plotlyOutput("ForecastPlot")
    ))
)


# Define server logic required to draw a histogram
server <- function(input, output) {
  observeEvent(input$Company,{
    output$ForecastPlot <- renderPlotly({
      plot_ly(x = df_stocks_N$Time , y = df_stocks_N[,colnames(df_stocks_N) == input$Company], name = "Historical",
              type = "scatter", mode = "lines", line = list(color = "rgb(0,0,0)", width = 4)) %>%
        add_trace(x = fcast_date , y  = forecast(auto.arima(df_stocks_N[,colnames(df_stocks_N) == input$Company]), h = 100)$mean,
                  name = "Forecast", line = list(color = "rgb(42,66,247)", width = 4 , dash = "dot")) %>%
        layout(title = "Forecast of Closing Stock Price",
               xaxis = list(title = "Date"),
               yaxis = list(title = "Price"))
      
      
      
    })
  })
}

# Run the application 
shinyApp(ui = ui, server = server)