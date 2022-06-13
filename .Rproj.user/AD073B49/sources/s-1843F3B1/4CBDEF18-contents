#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here: #
# http://shiny.rstudio.com/
#

if (!require('shiny')) install.packages('shiny'); library(shiny)
if (!require('leaflet')) install.packages('leaflet'); library(leaflet)
if (!require('readxl')) install.packages('readxl'); library(readxl)
if (!require('dplyr')) install.packages('dplyr'); library(dplyr)
if (!require('shinycssloaders')) install.packages('shinycssloaders'); library(shinycssloaders)
if (!require('rgdal')) install.packages('rgdal'); library(rgdal)
if (!require('plotly')) install.packages('plotly'); library(plotly)
if (!require('htmltools')) install.packages('htmltools'); library(htmltools)
if (!require('DT')) install.packages('DT'); library(DT)
if (!require('shinyjs')) install.packages('shinyjs'); library(shinyjs)
if (!require('data.table')) install.packages('data.table'); library(data.table)
if (!require('leaflet.extras')) install.packages('leaflet.extras'); library(leaflet.extras)
if (!require('dygraphs')) install.packages('dygraphs'); library(dygraphs)
if (!require('shinyWidgets')) install.packages('shinyWidgets'); library(shinyWidgets)
#if (!require('leafem')) install.packages('leafem'); library(leafem)
if (!require('sf')) install.packages('sf'); library(sf)
if (!require('terra')) install.packages('terra', repos='https://rspatial.r-universe.dev'); library(terra)

# Deployment
if (!require('rsconnect')) install.packages('rsconnect'); library(rsconnect)

#Sys.setlocale("LC_TIME", "en_GB.UTF-8")

## Acceso de ACLED
raw_data <-
  read_excel('ACLEDRusiaUcrania.xlsx')

raw_data$longitude <- unlist(lapply(raw_data$longitude, function(x){
  if(substr(x,1,1)=="1"){
    as.numeric(sub("(\\d{3})([^\\.].*)$", "\\1.\\2", x))
  } else{
    as.numeric(sub("(\\d{2})([^\\.].*)$", "\\1.\\2", x))
  }
}
))

raw_data$latitude <- as.numeric(sub("^(\\d{2})[^\\.](.*)$", "\\1.\\2", raw_data$latitude))

raw_data <- raw_data %>% filter(!(is.na(longitude) | is.na(latitude)))
coordinates(raw_data) = cbind(raw_data$longitude, raw_data$latitude)

raw_data$event_date_real <- as.Date(raw_data$event_date, tryFormats= c('%d %B %Y'))

# There are some missing iso3 values
raw_data$iso3[is.na(raw_data$iso3) & raw_data$country=="Russia"] <- "RUS"
raw_data$iso3[is.na(raw_data$iso3) & raw_data$country == "Ukraine"] <- "UKR"


## Acceso a la capa de países en formato GeoJSON
# paises <-
#   rgdal::readOGR(
#     "https://raw.githubusercontent.com/datasets/geo-countries/master/data/countries.geojson"
#   )
# 
# paises$centroid_x <-  sapply(paises@polygons, function(x) slot(x, name = "labpt"))[1,]
# paises$centroid_y <-  sapply(paises@polygons, function(x) slot(x, name = "labpt"))[2,]
# 


# Utils
event_type_icon <- function(event_type){
  makeIcon(
    iconUrl = ifelse(event_type=="Protests",
                     'icons/civil-right-movement.png',
                     ifelse(event_type=="Riots",
                            'icons/strike.png',
                            ifelse(event_type=="Strategic developments",
                                   'icons/strategic-plan.png',
                                   ifelse(event_type=="Violence against civilians",
                                          'icons/bullying.png',
                                          ifelse(event_type=="Explosions/Remote violence",
                                                 'icons/explosion.png',
                                                 ifelse(event_type=="Battles",
                                                        'icons/war.png', 'icons/war.png'))))))
  )
}

event_type_color <- function(event_type){
    ifelse(event_type=="Protests",
       '#D320E0',
       ifelse(event_type=="Riots",
              '#1B9479',
              ifelse(event_type=="Strategic developments",
                     '#46B4E0',
                     ifelse(event_type=="Violence against civilians",
                            '#E0284C',
                            ifelse(event_type=="Explosions/Remote violence",
                                   '#940420',
                                   ifelse(event_type=="Battles",
                                          '#6028E0', '#6028E0'))))))
}
