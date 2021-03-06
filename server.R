library(shiny)
library(dplyr)
library(ggplot2)
library(randomcoloR)
library(ggmap)
library(plotly)
library(Hmisc)
source("spatial_utils.R")

data.race <- read.csv("data/race.csv", stringsAsFactors = F)
data.race.df <- as.data.frame(data.race)
data.income <- read.csv("data/income.csv", stringsAsFactors = F)
data.age <- read.csv("data/age_groups_washington.csv", stringsAsFactors = F)
data.age.df <- as.data.frame(data.age) %>%
  select(Area.Name:Female)
#global variable for selected county to compare in bar graphs. needed for filter
#STILL NOT WORKING
selectedCounty <- ""
color.frame <- data.frame(data.income$County, randomColor(39), stringsAsFactors = F)
colnames(color.frame) <- c("subregion", "color")

# Define server logic required
shinyServer(function(input, output) {
  

  filtered <- reactive({
    
    if(input$parameter.key == "Overview"){
      
      test.run <- input$parameter.key
      
    } else if(input$parameter.key == "Income"){
      
      data.filtered <- data.income
      
    } else if(input$parameter.key == "Crime Rate") {
  
      test.run <- input$parameter.key
      
    } else if(input$parameter.key == "Ethnicity") {
      
      data.filtered <- 0 
      test.run <- input$parameter.key
      
    } else {
      
      test.run <- paste(input$parameter.key, "change")
      
    }
    return(test.run)
  })
  
  # Return the rendered Test Text  
  output$out.text <- renderText({
    input.county <- GetCountyAtPoint(input$plot_click$x, input$plot_click$y)
    
  
    
    selectedCounty <- capitalize(substr(input.county, 12, 1000000))
    ############## FOR TESTING PURPOSES ONLY ##############
    print(selectedCounty)
    #######################################################
    return( paste0(capitalize(substr(input.county, 12, 1000000)), " County") )
    
  })
  
  # Creates Base Map
  output$base.map <- renderPlot({
    states <- map_data("state")
    west_coast <- subset(states, region %in% c("washington"))
    only_wa <- subset(states, region == "washington")
    
    #creates Data Frame of Washington County with information about different counties that will sever as main data to create map 
    all.counties <- map_data("county")
    washington_county <- subset(all.counties, region == "washington")
    head(washington_county)
    #Adds the different colour values to the respective counties in washington. 
    washington_county <- left_join(washington_county, color.frame)
    
    
    #Creates the actual map 
    create_base <- ggplot(data = only_wa, mapping = aes(x = long, y = lat, group = group)) +
      coord_fixed(1.3) +
      geom_polygon(color = "black", fill = "white") #color = perimeter of map , fill = whole map color fill 
    final_base <- create_base + theme_nothing() +
      geom_polygon(data = washington_county, fill = washington_county$color, color = NA) + # color = color of county outline
      geom_polygon(color = "black", fill = NA) # color = perimeter of map that should be kept same as previous color
    return(final_base)
    })
  
  output$pie <- renderPlotly({
    plot_ly(mtcars, x = ~mpg, y = ~wt)
    
  })
  
  #creates a bar graph for age distrtibution for a county
  output$county.age.bar <- renderPlotly({
    curr.county.age.df <- filter(data.age.df, Area.Name == selectedCounty & Age.Group != "Total")
    totals.num <- as.numeric(gsub(",","",curr.county.age.df$Total))
    plot_ly(
      x = curr.county.age.df$Age.Group,
      y = totals.numb,
      type = "bar"
    ) %>%
      layout(yaxis = list(title = 'Population'), xaxis = list(title = 'Age Group'))
  })
  
  #creates bar graph for race distribution for a county
  output$county.race.bar <- renderPlotly({
    curr.county.race.df <- filter(data.race.df, County.name == paste(selectedCounty, "County"))
    race.stats <- c(curr.county.race.df$X2010.White.population, curr.county.race.df$X2010.Black.population, curr.county.race.df$X2010.Native.population, 
      curr.county.race.df$X2010.Asian.population, curr.county.race.df$X2010.Islander.population, curr.county.race.df$X2010.Hispanic.population)
    race.stats.num <- as.numeric(gsub(",","",race.stats))
    
    plot_ly(
      x = c("White.Population", "Black.Population", "Native.Population", "Asian.Population", "Islander.Population", "Hispanic.Population"),
      y = race.stats.num,
      type = "bar"
    ) %>%
      layout(yaxis = list(title = 'Population'), xaxis = list(title = 'Race'))
  })
})