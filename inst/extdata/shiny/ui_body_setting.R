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
                        ),
                        tabPanel('YAML',
                                 fluidRow(
                                   box(
                                     title = "Setting (YAML)",
                                     status = "primary",
                                     width = 12,
                                     uiOutput("setting_ui_yaml"),
                                     actionButton("setting_yaml_confirmed", "Update", class = "btn btn-primary", style = "color:#FFFFFF")
                                   )
                                 )
                        )
             )
   )
}
setting_server <- function(input, output) {
  ### UI and server of setting page1
  update_setting_default_ui <- function(input, output){
    output$setting_ui <- renderUI({
      html_string <- ""
      section_names <- names(config)
      for(section in section_names) {
        config.section <- config[[section]]
        html_string <- paste0(html_string, h4(sprintf("%s", section)))
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

  ### UI and server of setting page2
  update_setting_yaml_ui <- function(input, output){
    html_text <- paste(readLines(config.file), collapse = "\n")
    text_area_js <- "<script type='text/javascript'>var setting_yaml_editor = CodeMirror.fromTextArea(setting_yaml_input, {
    lineNumbers: true,
    keyMap: 'sublime',
    theme:'monokai',
    indentUnit: 2,
    gutters: ['CodeMirror-linenumbers', 'CodeMirror-foldgutter'],
    mode: 'yaml'
  });</script>"
    output$setting_ui_yaml <- renderUI({
      HTML(
        paste0(textAreaInput("setting_yaml_input", label = "BioInstaller YAML",
                             value = html_text,
                             rows = 100, height = 500)
               ,text_area_js
               )
      )
    })
    return(output)
  }

  observeEvent(input$setting_confirmed, {
    section_names <- names(config)
    for(section in section_names) {
      config.section <- config[[section]]
      for(subsection in names(config.section)) {
        input_id <- sprintf("setting_%s_%s", section, subsection)
        config[[section]][[subsection]] <- input[[input_id]]
      }
    }
    configr::write.config(config.dat = config, file.path = config.file, write.type = "yaml")
    config <- configr::read.config(config.file, file.type = "yaml")
    source("global_var.R", encoding = "UTF-8")
    output <- update_setting_yaml_ui(input, output)
    shinyjs::alert("Update successful!")
  })

  output <- update_setting_yaml_ui(input, output)
  observeEvent(input$setting_yaml_confirmed, {
    observe({
      js$get_setting_yaml_input()
      req(input$setting_yaml_input_value)
      writeLines(input$setting_yaml_input_value, config.file)
      source("global_var.R", encoding = "UTF-8")
      output <- update_setting_default_ui(input, output)
      output <- update_setting_yaml_ui(input, output)
    })
    shinyjs::alert("Update successful!")
  })
  return(output)
}
