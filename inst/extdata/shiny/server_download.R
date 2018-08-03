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
        extra.params <- clean_parsed_item(input$extra.paramters, FALSE)
        extra.params <- eval(parse(text = extra.params))
        if ("extra.list" %in% extra.params){
          print(input$download.buildver)
          extra.params$extra.list <- config.list.merge(extra.params$extra.list,
                                                       list(buildber = input$download.buildver))
        } else {extra.params$extra.list <- list(buildver = input$download.buildver)}
        for(i in input$download.logical) {extra.params <- config.list.merge(extra.params,
                                                            eval(parse(text = sprintf('list(%s=TRUE)', i))))}
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
      textInput("download.dir.parent", "Download directory (Hints)", value = config$shiny_download$download_dir)
    })
    output$download.dir.input <- shiny::renderUI({
      req(input$download.dir.parent)
      selectInput("download.dir", "Download directory", choices =
                  normalizePath(list.dirs(path = input$download.dir.parent, full.names = TRUE)), selectize = TRUE)
    })
  })

  observeEvent(input$download.version, {
    output$download.buildver.selector <- shiny::renderUI({
      textInput("download.buildver", "Buildver version (Database needed, e.g. hg19, hg38)",
                  value = "hg19")
    })
  })


  return(output)
}
