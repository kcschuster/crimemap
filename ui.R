# *****************************************************************************
# ui.R - Web app for interactive crime map
# *****************************************************************************

# Load necessary libraries
library(shinydashboard)
library(leaflet)


# Dashboard header
header <- dashboardHeader(
  title = "San Francisco Crime Map",
  titleWidth = 300
)

# Dashboard body
body <- dashboardBody(
  fluidRow(
    
    # Message across top of app
    p("Select DATE and TIME to visualize locations and categories 
      of crimes committed.  Click on CRIME MARKERS for more detailed
      descriptions.", 
      class = "text-muted", align = "center"),
    

    column(width = 9,
           box(width = NULL, solidHeader = TRUE, 
               leafletOutput("myMap", height = 500))),
    
    # Input to select city (currently only SF)
    column(width = 3,
           box(width = NULL, status = "warning", uiOutput("citySelect"),
               
               selectInput("City", "City",
                           choices = c("San Francisco"),
                           selected = c("San Francisco")))),
    
    # Group of inputs with date + time
    column(width = 3,
           box(width = NULL, status = "warning", uiOutput("timeSelect"),
               
               # Year input list
               selectInput("Year", "Year",
                           choices = c("2016","2015","2014","2013","2012","2011",
                                       "2010","2009","2008","2007","2006","2005",
                                       "2004","2003"),
                           selected = c("2016")),
              
               # Month input list
               selectInput("Month", "Month",
                           choices = c("January" = "01", "February" = "02",
                                       "March" = "03", "April" = "04", 
                                       "May" = "05", "June" = "06", "July" = "07",
                                       "August" = "08", "September" = "09", 
                                       "October" = "10", "November" = "11", 
                                       "December" = "12"),
                           selected = c("01")),
              
               # Day input list
              selectInput("Day", "Day",
                          choices = c("01","02","03","04","05","06","07","08",
                                      "09","10","11","12","13","14","15","16",
                                      "17","18","19","20","21","22","23","24",
                                      "25","26","27","28","29","30","31"), 
                          selected = c("01")),
              
              # Will eventually replace with slider...
              #sliderInput("Hour", "Hour Range", min = 0, max = 24, value = c(0,1), dragRange = TRUE)
              
              # Hour input list
              selectInput("Hour", "Hour",
                          choices = c("00","01","02","03","04","05","06","07",
                                      "08","09","10","11","12","13","14","15",
                                      "16","17","18","19","20","21","22","23"),
                          selected = c("00")),
              
              # Refresh button to make map after updates
              actionButton("Refresh", "Create Crime Map")
           )
    ),
    
    # Text for error messages
    h5(textOutput("Notes"), class = "text-muted", align = "center")
  )
)

# Construct dashboard page
dashboardPage(skin = "blue", 
              header, 
              dashboardSidebar(disable = TRUE), 
              body)
