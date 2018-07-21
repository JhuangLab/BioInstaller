get_pipeline_tabItem_ui <- function() {
  for(tool in annovarR_shiny_tools_list$pipeline) {
    assign(sprintf("%s_boxes", tool),
           generate_boxes_object(get(sprintf("config.%s", tool)), tool))
  }

  body_pipeline_tabItem <- tabItem("pipeline",
                                   tabsetPanel(type = 'pills',
                                               tabPanel('CEMiTool',
                                                        fluidRow(eval(parse(text = paste0(unname(CEMiTool_boxes), collapse = ",")))))
                                   )
  )
}

