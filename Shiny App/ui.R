
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(markdown)

shinyUI(
  
  navbarPage(title = "Predict the Next Word",
             
             tabPanel("Word Prediction",
                      
                      fluidRow(
                        
                        column(6, wellPanel(
                          
                          br(),
                          
                          textInput("term", "Enter your text Here: ", width = 1000),
                          
                          br(),
                          
                          radioButtons("radio", label = "Select the Smoothing Algorithm", choices = c("Kensar Ney" = "kn", "Good Turing" = "gt"), selected = "kn"),
                          
                          h6("(Please wait for a while after chaging the smoothing algorithm for the data load)"),
                          
                          br(),
                          br(),
                          
                          h3("Prediction"),
                          br(),
                          
                          h4("Below are 3 Possible choices for the next word. They are ordered by their probablities"),
                          br(),
                          
                          verbatimTextOutput("term"),
                          
                          br(),
                          
                          verbatimTextOutput("pred1"),
                          verbatimTextOutput("pred2"),
                          verbatimTextOutput("pred3"),
                          
                          br()
                          
                        )
                        )
                        
                      )
             ),
             
             tabPanel("Data Analysis",
                      fluidRow(
                        column(6, wellPanel(
                          includeHTML("Swiftkey_Model.html")
                        )
                        )
                      )
             ) 
  )
)
