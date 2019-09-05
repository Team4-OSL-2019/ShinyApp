#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(rnaturalearth)
library(rnaturalearthdata)
library(rgeos)

dataDirectory<-"./data/"
ExtraFishData <- readRDS(paste(dataDirectory,"ExtraFishData.RDS", sep = ""))
AcousticSurveyCatchData <- readRDS(paste(dataDirectory,"AcousticSurveyCatchData.RDS", sep = ""))

c("None",as.character(ExtraFishData$SciName))

#speciesToUse <- "Clupea harengus"
#summaryData <- ExtraFishData[ExtraFishData$SciName==speciesToUse,]

# Define server logic required to draw a histogram
shinyServer(function(session,input, output) {
   
  # Update the species drop down
  updateSelectInput(session, "speciesInput", label = NULL, choices = c("None",as.character(ExtraFishData$SciName)), selected = NULL)
  
  # Title
  output$SpeciesTitle <- renderText({
    
    if (input$speciesInput=="None"){
      myTitle <- ""
    } else {
      myTitle <- paste("<H1>",input$speciesInput,"</H1>", sep= "")
    }
    
    myTitle
    
  })
  
  # Wikipedia URL
  output$SpeciesURL <- renderText({
    
    wikipediaURL <- ExtraFishData[as.character(ExtraFishData$SciName)==input$speciesInput,c("WikipediaPage")]
    myURL <- paste("<a href='", as.character(wikipediaURL), "' target='_blank'>", as.character(wikipediaURL), "</a>" , sep = "")
    myURL
    
  })
  
  output$RedListStatus <- renderText({
    
    myStatusHTML <- ""
    
    if(input$speciesInput!="None"){
      myStatus <- ExtraFishData[as.character(ExtraFishData$SciName)==input$speciesInput,c("RedListStatus")]

      if (myStatus != ""){
        myStatusHTML <- paste("<H3>Red list status: ",myStatus,"</H3>", sep= "")
      }
    }
    
    myStatusHTML
    
    
  })
  
  # Wikipedia image
  output$SpeciesImage <- renderText({
    
    imageURL <- ExtraFishData[as.character(ExtraFishData$SciName)==input$speciesInput,c("Image")]
    
    myImage <- paste("<img src='",as.character(imageURL),"'>", sep = "")
    #print(myImage)
    myImage

  })
  
  output$RecipeURL <- renderText({
    
    if(input$speciesInput!="None"){
    recipeURL <- ExtraFishData[as.character(ExtraFishData$SciName)==input$speciesInput,c("RecipeURL")]
    myURL <- paste("<a href='", as.character(recipeURL), "' target='_blank'>", "Recipes from BBC", "</a>" , sep = "")
    } else {
      myURL <- ""
    }
    
    myURL
    
    
  })
  
  # Abstract
  output$Abstract <- renderText({
    abstractText <- ExtraFishData[as.character(ExtraFishData$SciName)==input$speciesInput,c("Abstract")]
    as.character(abstractText)
  })
  
  # Acoustic survey hauls of that species
  output$AcousticSurvey <- renderPlot({
    
    if(input$speciesInput!="None"){
    
    aphiaID <- ExtraFishData[as.character(ExtraFishData$SciName)==input$speciesInput,c("AphiaID")]

    DataToPlot <- AcousticSurveyCatchData[AcousticSurveyCatchData$CatchSpeciesCode==aphiaID,]

    # Only continue if we have some data for this species...
    if (nrow(DataToPlot) > 0) {
    
    DataToPlot$HaulStartLongitude <- as.numeric(DataToPlot$HaulStartLongitude)
    DataToPlot$HaulStartLatitude <- as.numeric(DataToPlot$HaulStartLatitude)
    
    world <- ne_countries(scale = "medium", returnclass = "sf")
    
    minLon <- min(DataToPlot$HaulStartLongitude, na.rm = T)
    maxLon <- max(DataToPlot$HaulStartLongitude, na.rm = T)
    
    minLat <- min(DataToPlot$HaulStartLatitude, na.rm = T)
    maxLat <- max(DataToPlot$HaulStartLatitude, na.rm = T)
    
    
    p <- ggplot(data = world) +
      geom_sf() +
      ggtitle( "Observations from ICES acoustic surveys") +
      geom_point(data = DataToPlot[,], aes_string(x = "HaulStartLongitude", y = "HaulStartLatitude")) +
      coord_sf(xlim = c(minLon,maxLon ), ylim = c(minLat, maxLat), expand = TRUE)
    
    print(p)
    
    }
    
    }
    
  })
  
})
