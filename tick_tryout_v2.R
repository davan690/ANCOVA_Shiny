library("shiny")
library("highcharter")

#import tick figure data
tick <- read.csv("./data/tickdata.csv", header=T)

ui <- shinyUI(
  fluidPage(
    column(width = 8, plotOutput("hcontainer", height = "500px")),
    column(width = 4, textOutput("text"))
  )
)

server <- function(input, output) {

  a <- data.frame(metre2 = tick$Max_2m, max25cm = tick$Max_25cm, HLL = tick$HLL, emetre2 = tick$Max_2m)

  output$hcontainer <- renderPlot({

    canvasClickFunction <- JS("function(event) {Shiny.onInputChange('canvasClicked', [this.name, event.point.category]);}")
    legendClickFunction <- JS("function(event) {Shiny.onInputChange('legendClicked', this.name);}")

    highchart() %>%
      hc_xAxis(categories = a$b) %>%
      hc_add_series(name = "metre2", data = a$metre2) %>%
      hc_add_series(name = "max25cm", data = a$max25cm) %>%
      hc_add_series(name = "HLL", data = a$HLL) %>%
      hc_plotOptions(series = list(stacking = FALSE, events = list(click = canvasClickFunction, legendItemClick = legendClickFunction))) %>%
      hc_chart(type = "column")

  })

  makeReactiveBinding("outputText")

  observeEvent(input$canvasClicked, {
    outputText <<- paste0("You clicked on series ", input$canvasClicked[1], " and the bar you clicked was from category ", input$canvasClicked[2], ".")
  })

  observeEvent(input$legendClicked, {
    outputText <<- paste0("You clicked into the legend and selected series ", input$legendClicked, ".")
  })

  output$text <- renderText({
    outputText
  })
}

shinyApp(ui, server)
