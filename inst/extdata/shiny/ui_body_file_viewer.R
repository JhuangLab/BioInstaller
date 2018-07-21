get_file_viewer_tabItem_ui<- function(){
  body_file_viewer_tabItem <- tabItem("file_viewer",
        fluidRow(
          box(
            title = "File List",
            status = "primary",
            width = 12,
            DT::dataTableOutput("files_info_DT")
          ),
          actionButton("delete_confirmed", "", class = "btn btn-primary", style = "display:none"),
          box(
            title = "File Preview",
            width = 12,
            status = "primary",
            DT::dataTableOutput("file_preview_DT"),
            textOutput("file_preview")
            )
        )
   )
}
