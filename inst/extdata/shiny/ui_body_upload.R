get_upload_tabItem_ui <- function() {
  body_upload_tabItem <- tabItem("upload",
            fluidRow(
              box(
                title = "Upload",
                width = 12,
                status = "primary",
                # Input: Select a file ----
                fileInput("upload.file", "Choose Need Uploaded File",
                          multiple = TRUE,
                          accept = NULL),
                selectInput("upload.file.type", "FileType",
                            choices = config$shiny_upload$supported_file_type),
                selectInput("upload.genome.version", "GenomeVersion",
                            choices = config$shiny_upload$supported_genome_version),
                textAreaInput("upload.file.description", "Description", row = 10),
                actionButton("upload_save", "Save", class = "btn btn-primary", disabled = "disabled"),
                inlineCSS(list("#upload_save" = "color: white"))
                ),
              box(
                title = "Preview",
                width = 12,
                status = "primary",
                DT::dataTableOutput("upload_file_preview_DT"),
                textOutput("upload_file_preview"),
                uiOutput("upload_file_preview_ui")
                )
            )
    )
}
