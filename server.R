

# Sección server
server <- function(input, output, session) {
         
  # Creamos un dataframe
  acciones <- reactive({
    st_as_sf(x = raw_data, 
             coords = c("longitude", "latitude"),
             crs =st_crs("EPSG:4326"))
  })
  
  # paleta para el temático, basado en los varloes de casos totales (total_casos)
  #paleta <-
  #  reactive({
  #    colorQuantile("Reds", unique(paises_total_casos()@data[,"total"]), n = 9)
  #  })
  
  #Renderizado de la tabla "paises"
  #output$paises = DT::renderDataTable({
  #  DT::datatable(paises_tabla(), selection = "single")
  #})

  # Ej 3 Función que captura los cambios en los radiobutton
  observeEvent(input$variable_to_show, {
    variable(input$variable_to_show)
  })
  
  set_popup_content <- function(country, admin1, location, notes){
    paste(sep = "<br/>",
          paste0(country, " / ", admin1, " / ", location),
          notes
    )
  }

  #Renderizado del control de mapa
  output$map <- renderLeaflet({
    p <- leaflet(filtered() %>% mutate(color=event_type_color(event_type))) %>%
      #addTiles() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addSearchOSM(options = searchOptions(autoCollapse = TRUE, minLength = 2)) %>%
      addMarkers(lng = ~longitude, lat = ~latitude, 
                 popup = ~set_popup_content(country, admin1, location, notes),
                 clusterOptions = markerClusterOptions(),
                 icon=~event_type_icon(event_type), group = "Iconos") %>% 
      addCircleMarkers(lng = ~longitude, lat = ~latitude, 
                 popup = ~set_popup_content(country, admin1, location, notes),
                 color = ~color, fillOpacity = 1, stroke=FALSE, radius=5, group = "Puntos") %>% 
      addHeatmap(lng = ~longitude, lat = ~latitude,max=100,radius=20,blur=10, group = "Mapa de calor") %>%
      addLayersControl(baseGroups = c("Iconos", "Puntos", "Mapa de calor"), options = layersControlOptions(collapsed = FALSE))
  })

  filtered <- reactive({
    rows <- (is.null(input$event_type) | acciones()$event_type %in% input$event_type) &
      (is.null(input$sub_event_type) | acciones()$sub_event_type %in% input$sub_event_type)
    
    result <- acciones()[rows,,drop = FALSE] 
    
    result <- result %>% filter(between(event_date_real, input$date_filter[1], input$date_filter[2], incbounds=TRUE))
    result
    
  })
  output$outtable <- renderDT(
    as.data.frame(filtered()) %>% mutate(location_comp=paste(country, admin1, location, sep=" / ")) %>% 
      select(event_id_cnty, event_date_real, event_type, sub_event_type, location_comp) %>% 
      rename("id"=event_id_cnty , "Date"=event_date_real , "Event type" = event_type, "Subevent type"=sub_event_type, "Location"=location_comp)
  )
  
  output$summaryplot <- renderPlotly({
    ggplot(filtered(), aes(fill=sub_event_type, x=event_type)) + 
      geom_bar(position="stack", stat="count") + labs(x = "Evento", y="Conteo", fill="Subevento") 
  })

  output$timeseriesplot <- renderPlotly({
    ggplot(filtered(), aes(colour=event_type, x=event_date_real)) + 
      geom_line(stat="count") + labs(x = "Fecha", y="Conteo", colour="Evento") + scale_color_manual(values=event_type_color(levels(factor(filtered()$event_type))))
  })
  
  output$piechartplot <- renderPlotly({
    conteo <- filtered() %>% group_by(event_type) %>% summarize(cantidad=n())
    plot_ly(conteo, labels = ~event_type, values = ~cantidad, type = 'pie',
            textposition = 'inside',
            textinfo = 'percent',
            insidetextfont = list(color = '#FFFFFF'),
            hoverinfo = 'text',
            text = ~paste(event_type, ': ', cantidad, ' casos'),
            marker = list(colors = ~event_type_color(event_type)),
            showlegend = FALSE)
  })
  
  # Función que captura el código ISO - iso_code - cuando se selecciona un registro en la tabla.
  selectedRow <- eventReactive(input$paises_rows_selected, {
    as.character(paises_tabla()[c(input$paises_rows_selected)]$iso_code[1])
  })
  
  observeEvent(input$remove_event_filtering, {
    session$sendCustomMessage("clean_event", 'null')
  })
  
  observeEvent(input$remove_map_filtering, {
    session$sendCustomMessage("clean_map", 'null')
  })

}