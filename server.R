# *****************************************************************************
# server.R - Web app for interactive crime map
# *****************************************************************************

# Load necessary libraries
library(shinydashboard)
library(leaflet)
library(dplyr)
library(curl)
library(RSocrata)


# Make initial map of SF 
makeMap <- function() {

  # Construct initial map
  map <- leaflet() %>% addTiles()
  map <- map %>% setView(lng = -122.4167, lat = 37.7834, zoom = 12)
  map <- map %>% mapOptions(zoomToLimits = "always")
  return(map)
}


# Function to run app
shinyServer(function(input, output, session) {
  
  # Produce map when app is initially loaded
  output$myMap <- renderLeaflet( { makeMap() })

  # Dummy text for error message  
  output$Notes <- renderText ({ "" })
  
  # If input changes, don't need to remake map, just add new crime data
  observeEvent(input$Refresh, {

    # Save values
    year <- input$Year
    y <- as.numeric(year)
    month <- input$Month
    m <- as.numeric(month)
    day <- input$Day
    d <- as.numeric(day)
    hour <- input$Hour
    
    # Check for invalid dates (and account for leap years)
    leap_yrs <- c(2016,2012,2008,2004)
    if (m == 2 & d > 28 & !(y %in% leap_yrs) |
        m == 2 & d > 29 & y %in% leap_yrs |
        m == 4 & d > 30 |
        m == 6 & d > 30 |
        m == 9 & d > 30 |
        m == 11 & d > 30) {
      
      output$Notes <- renderText({"Please select a valid date"})
      leafletProxy("myMap") %>% clearShapes() %>% clearControls() 
      
    # If date is valid, proceed with API call to get crime data
    } else {
    
      # Show progress message
      withProgress(message = "Getting Data for Map...", value = 1, {
    
      # Get end of hour range
      hour2 <- as.numeric(hour) + 1
      if (hour2 < 10) {
        hour2 <- sprintf("0%s", as.character(hour2))
      } else {
        hour2 <- as.character(hour2)
      }
    
      # Clear notes text
      output$Notes <- renderText({ "" })
    
      # Get crime data for map via API call
      dateStr <- sprintf("%s-%s-%sT00:00:00", year, month, day)
      q <- sprintf("https://data.sfgov.org/resource/tmnf-yvry.json?$where=date='%s'",
                   dateStr)
      crimesData <- read.socrata(url = q)
      
      # Select hours of interest once data is imported
      crimesData <- crimesData[which(crimesData$time >= sprintf("%s:00", hour)), ]
      crimesData <- crimesData[which(crimesData$time < sprintf("%s:00", hour2)), ]
      
      
      # If there is actually data to work with, add to map
      if (nrow(crimesData) > 0) {
        
        # Make categories lower case and set color scheme
        crimesData$category <- tolower(crimesData$category)
        pal <- colorFactor("Spectral", crimesData$category)
        
        # Clear map and add new crime data + legend
        leafletProxy("myMap") %>% clearShapes() %>% clearControls() %>%
          addCircles(lng = as.numeric(crimesData$x), lat = as.numeric(crimesData$y), radius = 80, 
                     color = pal(crimesData$category), fill = TRUE,
                     opacity = 1.0, fillOpacity = 1.0) %>%
          addLegend("bottomright", pal=pal, values=crimesData$category,
                    layerId="colorLegend", opacity = 0.8) 
      
        
      # If no crimes for that selection, say so and clear map  
      } else {
        output$Notes <- renderText({"No crimes reported for this day"})
        leafletProxy("myMap") %>% clearShapes() %>% clearControls()
      }
    })
    }
  })
})