#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Species data"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       selectInput("speciesInput", "Select a species", choices=c("None"))
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      htmlOutput("SpeciesTitle"),
      htmlOutput("SpeciesURL"),
      htmlOutput("RedListStatus"),
      htmlOutput("SpeciesImage"),
      htmlOutput("RecipeURL"),
      htmlOutput("Abstract"),
      imageOutput("AcousticSurvey")
    )
  )
))
