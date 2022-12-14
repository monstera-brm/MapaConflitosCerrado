pacotes <- c("rgdal", "leaflet", "raster", "shiny")

if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){
   instalador <- pacotes[!pacotes %in% installed.packages()]
   for(i in 1:length(instalador)) {
     install.packages(instalador, dependencies = T)
     break()}
   sapply(pacotes, require, character = T)
 } else {
   sapply(pacotes, require, character = T)
 }

library(rgdal)
library(leaflet)
library(raster)
library(shiny)
#data 
shp_conflitos <- readOGR(dsn = "conflitos_mun", 
                         layer = "conflitos_mun",
                         encoding = "UTF-8", 
                         use_iconv = TRUE)
shp_conflitos@data$Área <- as.numeric(shp_conflitos@data$Área)
#municipios
shp_municipios <- readOGR(dsn = "municipalities_cerrado_biome", 
                          layer = "municipalities_cerrado_biome",
                          encoding = "UTF-8", 
                          use_iconv = TRUE)
shp_municipios@data$Área <- as.numeric(shp_municipios@data$Área)
#conflitos informacoes completas
shp_conflitos_final <- readOGR(dsn = "conflitos_final", 
                         layer = "conflitos_municipio_infoplus_final",
                         encoding = "UTF-8", 
                         use_iconv = TRUE)
shp_conflitos_final@data$X.rea <- as.numeric(shp_conflitos_final@data$X.rea)
data_total <- shp_conflitos_final@data

#create a color palette to fill the polygons
pal <- colorQuantile("Greens", NULL, n = 5)

#create a pop up (onClick)
polygon_popup <- paste0("<strong>Municipio: </strong>", shp_conflitos_final$nm_municip, "<br>",
                        "<strong>Area conflito: </strong>", shp_conflitos_final$Area.km2.,"<br>",
                        "<strong>Tipo mineração: </strong>", shp_conflitos_final$SUBS,"<br>",
                        "<strong>Nome assentamento: </strong>", shp_conflitos_final$nome_proje,"<br>",
                        "<strong>Nome comunidade quilombola: </strong>", shp_conflitos_final$nm_comunid,"<br>",
                        "<strong>Nome terra indígena: </strong>", shp_conflitos_final$terrai_nom,"<br>",
                        "<strong>Nome unidade de conservação: </strong>", shp_conflitos_final$nome,"<br>",
                        "<strong>Tipo de uso da terra: </strong>", shp_conflitos_final$Classe)

#create app

ui <- fillPage(
  leafletOutput("my_map",height="100%", width="100%")
)


server <- function(input, output, session){
  
  output$my_map <- renderLeaflet({
    
    leaflet(shp_conflitos_final) %>% 
      addProviderTiles("Esri.WorldGrayCanvas") %>% 
      setView(-47.898654,-15.968182,
              zoom = 4) %>% 
      addPolygons(fillColor= ~pal(X.rea),
                  weight = 0.5, 
                  color = "grey",
                  popup = polygon_popup)
    
  })
  
}

shinyApp(ui, server)

#addLegend(map, title = "Mapa Conflitos SA",
          #pal = pal, values = shp_conflitos_final$X.rea,
          #position = "bottomleft" )
