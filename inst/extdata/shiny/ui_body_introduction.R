get_introduction_tabItem_ui <- function(){
  body_introduction_tabItem <- tabItem("introduction",
            fluidRow(
              box(
                title = "Introduction",
                width = 12,
                status = "primary",
                collapsible = TRUE,
                collapsed = FALSE,
                includeMarkdown("index.md")
              )
            )
    )
}
