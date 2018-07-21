source("config.R")

download_section_server <- function(input, output) {

  observeEvent(input$install_run, {
    req(input$item.name)
    req(input$download.version)

      if (input$download.dir == "") {
        download.dir <- input$download.dir.parent
      } else {
        download.dir <- input$download.dir
      }
      version <- input$download.version
      if (any(input$download.version == "")) {
        index <- input$download.version == ""
        version[index] <- BioInstaller::install.bioinfo(name = input$item.name[index],
                                                                   show.all.versions = TRUE)[1]
        input$download.version <- version
      }

      if (any(input$item.name != "")) {
        extra.params <- eval(parse(text = input$extra.paramters))
        params <- list(name = input$item.name, download.dir = download.dir,
                       verbose = TRUE, version = version)
        params <- config.list.merge(params, extra.params)
        progress <- shiny::Progress$new()
        for (i in 1:100) progress$set(message = "Submitting task...",
                                      value = i/100)
        Sys.sleep(2)
        on.exit(progress$close())
        params$req_pkgs <- "BioInstaller"
        params$qqcommand <- "BioInstaller::install.bioinfo"
        params$qqkey <- stringi::stri_rand_strings(1, 50)
        params$qqcommand_type <- "R"
        msg <- jsonlite::toJSON(params)
        queue <- liteq::ensure_queue(shiny_queue_name, db = queue_db)
        while(TRUE) {
          tryCatch({liteq::publish(queue, title = "Download", message = msg);break},
                   error = function(e) {})
        }
        output <- dashbord_section_server(input, output)
        output$task_submit_modal <- renderUI({
          html_text <- tryCatch(get("html_text_task_submit_modal", envir = globalenv()), error = function(e) {
            html_text <- paste0(readLines("www/modal.html"), collapse = "\n")
            assign("html_text_task_submit_modal", html_text, envir = globalenv())
            return(html_text)
          })
          html_text <- stringr::str_replace_all(html_text, '\\{\\{task_title\\}\\}', "Downloader")
          html_text <- stringr::str_replace_all(html_text, '\\{\\{task_key\\}\\}', params$qqkey)
          html_text <- stringr::str_replace_all(html_text, '\\{\\{task_msg\\}\\}', msg)
          html_text <- sprintf("%s<script>$('#myModal').modal('show')</script>", html_text)
          HTML(html_text)
        })
      }
  })
  observeEvent(input$item.name, {
    output$download.version.selector <- shiny::renderUI({
      selectInput("download.version", "Version of item",
                  choices = BioInstaller::install.bioinfo(input$item.name, show.all.versions = TRUE), multiple = TRUE)
    })
    output$download.dir.parent.input <- shiny::renderUI({
      textInput("download.dir.parent", "Download directory (Paraent)")
    })
    output$download.dir.input <- shiny::renderUI({
      req(input$download.dir.parent)
      selectInput("download.dir", "Download directory", choices =
                  normalizePath(dir(path = input$download.dir.parent, full.names = TRUE, include.dirs = TRUE)), selectize = TRUE)
    })
  })
  return(output)
}
