get_download_tabItem_ui <- function(){
  download.github.cfg <- system.file("extdata",
                                    "config/github/github.toml", package = "BioInstaller")
  download.non.github.cfg <- c(system.file("extdata", "config/nongithub/nongithub.toml",
                               package = "BioInstaller"), system.file("extdata", "config/db/db_main.toml",
                               package = "BioInstaller"), system.file("extdata", "config/db/db_annovar.toml",
                               package = "BioInstaller"), system.file("extdata", "config/db/db_blast.toml",
                               package = "BioInstaller"))
  body_download_tabItem <- tabItem("download",
            fluidRow(
              box(
                title = "BioInstaller",
                width = 12,
                status = "primary",
                selectInput("item.name", "Name of item",
                            choices = BioInstaller::install.bioinfo(show.all.names = TRUE), multiple = TRUE),
                shiny::uiOutput("download.version.selector"),
                shiny::uiOutput("download.buildver.selector"),
                shiny::uiOutput("download.dir.parent.input"),
                shiny::uiOutput("download.dir.input"),
                shiny::selectInput("download.github.cfg", label = "Github Configuration File",
                                  choices = download.github.cfg, selected = download.github.cfg,
                                  multiple = TRUE),
                shiny::selectInput("download.nongithub.cfg", label = "Other Configuration File",
                                   choices = download.non.github.cfg, selected = download.non.github.cfg,
                                   multiple = TRUE),
                shiny::textInput("download.license", label = "License"),
                shiny::checkboxGroupInput("download.logical", label = "Logical Values",
                                          choiceNames = c(
                                                      "Download only",
                                                      "Save the installtion info", "Overwrite the installtion dir"),
                                          selected = c("info.db", "rcmd.parse", "bash.parse", "glue.parse",
                                                       "save.to.db"),
                                          choiceValues =  c("download.only",
                                                            "save.to.db", "overwrite")
                                            ),
                shiny::textInput("extra.paramters", "Extra parameters", "list()"),
                actionButton("install_run", "Submit")
              ),
              box(
                title = "Conda",
                width = 12,
                status = "primary",
                uiOutput("conda_installer_ui"),
                collapsible = TRUE,
                collapsed = TRUE
              ),
              box(
                title = "Spack",
                width = 12,
                status = "primary",
                uiOutput("spack_installer_ui"),
                collapsible = TRUE,
                collapsed = TRUE
              )
            )
    )
}
