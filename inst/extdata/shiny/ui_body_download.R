get_download_tabItem_ui <- function(){
  body_download_tabItem <- tabItem("download",
            fluidRow(
              box(
                title = "BioInstaller",
                width = 12,
                status = "primary",
                selectInput("item.name", "Name of item",
                            choices = BioInstaller::install.bioinfo(show.all.names = TRUE), multiple = TRUE),
                shiny::uiOutput("download.version.selector"),
                shiny::uiOutput("download.dir.parent.input"),
                shiny::uiOutput("download.dir.input"),
                textInput("extra.paramters", "Extra parameters", "list(license = '')"),
                actionButton("install_run", "Run")
              )
            )
    )
}
