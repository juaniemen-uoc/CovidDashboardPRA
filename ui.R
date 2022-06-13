

# Sección ui
# Usamos fluidPage() para definir la interfaz. La interfaz contendrá: 
# 1. El título
# 2. Un diseño con panel lateral que contiene: 
# 2.1 El panel lateral (sidebarpanel), que contiene una tabla llamada "paises"
# 2.2 El panel principal (mainPanel), que contiene un mapa ("map") generado con Leaflet y un gráfico 
# generado con dygraph 
event_types <- sort(levels(as.factor(raw_data$event_type)))

icon_list <- c(
  sprintf("<img src='https://filedn.eu/lIadVwRzP27XLCSYuMQ6abf/icon/war.png' width=30px><div class='jhr'>%s</div></img>", "Battles"),
  sprintf("<img src='https://filedn.eu/lIadVwRzP27XLCSYuMQ6abf/icon/explosion.png' width=30px><div class='jhr'>%s</div></img>", "Explosions/Remote violence"),
  sprintf("<img src='https://filedn.eu/lIadVwRzP27XLCSYuMQ6abf/icon/civil-right-movement.png' width=30px><div class='jhr'>%s</div></img>","Protests"),
  sprintf("<img src='https://filedn.eu/lIadVwRzP27XLCSYuMQ6abf/icon/strike.png' width=30px><div class='jhr'>%s</div></img>","Riots"),
  sprintf("<img src='https://filedn.eu/lIadVwRzP27XLCSYuMQ6abf/icon/strategic-plan.png' width=30px><div class='jhr'>%s</div></img>","Strategic developments"),
  sprintf("<img src='https://filedn.eu/lIadVwRzP27XLCSYuMQ6abf/icon/bullying.png' width=30px><div class='jhr'>%s</div></img>","Violence against civilians")
)

ui <- fluidPage(
  titlePanel("Eventos ocurridos en el conflicto de Ucrania - Rusia"),
  sidebarLayout(
    sidebarPanel(
      pickerInput(inputId = "event_type",
                  label = "Tipo de evento",
                  multiple = TRUE,
                  choices = event_types,
                  choicesOpt = list(content = icon_list),
                  options = list(`actions-box` = TRUE)),
      pickerInput(inputId = "sub_event_type",
                  label = "Subtipo de evento",
                  multiple = TRUE,
                  choices = sort(unique(raw_data$sub_event_type)),
                  options = list(`actions-box` = TRUE)),
      dateRangeInput(inputId = "date_filter",
                     label = "Fecha",
                     start = '2022-02-17',
                     end = Sys.Date()
      ),
      downloadButton("downloadCSV",
                      label = "Descargar datos",
                      style = "pill", 
                      color = "danger"
      )
    ), #div(DT::dataTableOutput("paises"))
    mainPanel(leafletOutput(outputId = "map", height = "500px", width="100%"), 
              DTOutput("outtable"),
              plotlyOutput("summaryplot"),
              plotlyOutput("timeseriesplot"),
              plotlyOutput("piechartplot")
              )
  )
)