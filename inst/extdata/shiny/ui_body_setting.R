get_setting_tabItem_ui<- function(){
  body_setting_tabItem <- tabItem("setting",
            tabsetPanel(type = 'pills',
                        tabPanel('Default',
                                 fluidRow(
                                 box(
                                   title = "Setting",
                                   status = "primary",
                                   width = 12,
                                   uiOutput("setting_ui"),
                                   actionButton("setting_confirmed", "Update", class = "btn btn-primary", style = "color:#FFFFFF")
                                 )
                                 )
                        )
             )
   )
}
setting_server <- function(input, output) {
  config.file <- Sys.getenv("BIOINSTALLER_SHINY_CONFIG", system.file("extdata", "config/shiny/shiny.config.yaml",
                                                                     package = "BioInstaller"))
  config <- read.config(config.file, file.type = "yaml")
  update_setting_default_ui <- function(input, output){
    output$setting_ui <- renderUI({
      html_string <- ""
      section_names <- names(config)
      for(section in section_names) {
        config.section <- config[[section]]
        if (html_string != "") html_string <- paste0(html_string, hr())
        for(subsection in names(config.section)) {
          if (is.numeric(config.section[[subsection]]) && length(config.section[[subsection]]) == 1) {
            html_string <- paste0(html_string, numericInput(sprintf("setting_%s_%s", section, subsection), label = subsection,
                         value = config.section[[subsection]]))
          } else if (is.character(config.section[[subsection]]) && length(config.section[[subsection]]) == 1){
            html_string <- paste0(html_string, textInput(sprintf("setting_%s_%s", section, subsection), label = subsection,
                      value = config.section[[subsection]]))
          } else {
            html_string <- paste0(html_string, selectInput(sprintf("setting_%s_%s", section, subsection),
                                                           choices = config.section[[subsection]],
                                                           selected = config.section[[subsection]],
                                                           label = subsection, multiple = TRUE))
          }
        }
      }
      HTML(html_string)
    })
    return(output)
  }
  output <- update_setting_default_ui(input, output)
  observeEvent(input$setting_confirmed, {
    for(section in section_names) {
      for(subsection in names(config.section)) {
        input_id <- sprintf("setting_%s_%s", section, subsection)
        print(input_id)
        config[[section]][[subsection]] <- input[[input_id]]
      }
    }
    configr::write.config(config.dat = config, file.path = config.file, write.type = "yaml")
    config <- configr::read.config(config.file, file.type = "yaml")
    source("global_var.R")
    shinyjs::alert("Update successful!")
  })
  return(output)
}
