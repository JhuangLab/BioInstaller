source("config.R")
server_upload_file <- function(input, output, session) {
  con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
  download_file_item <- function(id){
    shinyjs::useShinyjs()
    sql <- sprintf("SELECT file_name,file_path FROM %s where id=%s",
                   upload_table, id)
    result <- DBI::dbGetQuery(con, sql)
    result <- as.data.frame(result)
    path <- stringr::str_extract(result$file_path, 'upload/.*|upload\\\\.*')
    path <- stringr::str_replace(path, basename(result$file_path),
                        sprintf("%s", result$file_name))
    suppressWarnings(file.link(normalizePath(result$file_path), normalizePath(sprintf("%s/%s",
              dirname(result$file_path),
              result$file_name), mustWork = FALSE)))
    return(path)
  }
  # File viewr section
  render_files_info_DT <- function() {
    output$files_info_DT <- DT::renderDataTable({
      info <- featch_files()
      colnames(info)[1] <- "ID"
      paths <- sapply(info[,1], download_file_item)
      Action <- sprintf("<button id = 'files_view_%s' name = 'files_view_%s' type='button' class = 'btn btn-primary action-button shiny-bound-input'><i class='fa fa-eye'></i></button>",
                        info[, 1], info[, 1])
      Action <- sprintf("%s <button id = 'files_del_%s' name = 'files_del_%s' type='button' class = 'btn btn-primary action-button shiny-bound-input'><i class='fa fa-trash'></i></button>",
                        Action, info[, 1], info[, 1])
      Action <- sprintf("%s <a id = 'files_download_%s' name = 'files_download_%s' type='button' class = 'btn btn-primary' href='%s', download><i class='fa fa-download'></i></a>",
                        Action, info[,1], info[,1], paths)
      info <- cbind(info[1], Action, info[2:ncol(info)])
      return(info)
    }, rownames = FALSE, editable = FALSE, caption = "All files stored in shinyapp Web service",
    escape = FALSE, extensions = c("Buttons", "FixedColumns", "Scroller"),
    options = list(autoWidth = TRUE, dom = "Bfrtlip", deferRender = TRUE,
                   searchHighlight = TRUE, scrollX = TRUE, lengthMenu = list(list(5,
                   10, 25, 50, -1), list(5, 10, 25, 50, "All")), buttons = c("copy",
                   "csv", "excel", "pdf", "print"), columnDefs = list(list(width = "150px",
                   targets = c(1,7))), initComplete = DT::JS("function(settings, json) {",
                   "$(this.api().table().header()).css({'background-color': '#487ea5', 'color': '#fff'});",
                   "}")), selection = "none")
  }

  render_files_info_DT()

  if (upload_table %in% DBI::dbListTables(con)) {
    sql <- sprintf("SELECT id FROM %s", upload_table)
    upload_table_data <- DBI::dbGetQuery(con, sql)
    files_ids <- upload_table_data[, 1]
    for (i in files_ids) {
      output <- set_preview(i, output = output)
      delete_file_item(i)
    }
  }

  observeEvent(input$delete_confirmed, {
    id <- getQueryString()
    status <- DBI::dbSendQuery(con, sprintf("DELETE FROM %s WHERE id=%s", upload_table,
      id))
    print(status)
    shinyjs::alert("Delete successful!")
    render_files_info_DT()
    update_configuration_files()
    output <- render_input_box_ui(input, output)
  })

  # Upload section
  output$upload_file_preview_DT <- DT::renderDataTable({

    # input$file1 will be NULL initially. After the user selects and uploads a file,
    # head of that data file by default, or all rows if selected, will be shown.
    req(input$upload.file)
    shinyjs::enable(id = "upload_save")
    if (input$upload.file.type %in% shiny_preview$browser) {
      tmp_file <- git2r::hash(paste0(basename(input$upload.file$datapath), Sys.time()))
      prefix <- str_extract(basename(input$upload.file$datapath), "\\.[0-9a-zA-Z]*$")
      tmp_file <- sprintf("%s/%s%s", shiny_output_tmp_dir, tmp_file, prefix)
      tmp_file <- normalizePath(tmp_file, mustWork = FALSE)
      file.copy(input$upload.file$datapath, tmp_file, overwrite = TRUE)
      output$upload_file_preview <- renderText(tmp_file)
      output$upload_file_preview_ui <- renderUI({
        div(
        br(),
        a(href = sprintf("/tmp/%s", basename(tmp_file)), target = "_blank", class = "btn btn-primary", "View")
        )
      }
      )
    } else if (!input$upload.file.type %in% c(shiny_preview$fread, shiny_preview$browser)) {
      output$upload_file_preview <- renderText(input$upload.file$datapath)
    }
    if (input$upload.file.type %in% shiny_preview$fread) {
      df <- fread(input$upload.file$datapath)
      return(df)
    }
  }, extensions = c("Buttons", "FixedColumns", "Responsive"), options = list(dom = "Bfrtlip",
    searchHighlight = TRUE, scrollX = TRUE, buttons = c("copy", "csv", "excel",
      "pdf", "print"), initComplete = JS("function(settings, json) {", "$(this.api().table().header()).css({'background-color': '#487ea5', 'color': '#fff'});",
      "}")), selection = "none")

  # shinyjs::addClass(class='btn btn-primary', id='upload_save')
  observeEvent(input$upload_save, {
    req(input$upload.file)

    if (db_type == "sqlite") {
      con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
      id <- get_start_id(con, upload_table)
      assign(upload_table_colnames[1], input$upload.file$name)
      destfile <- sprintf("%s/%s", upload_dir, id)
      destfile <- normalizePath(destfile, mustWork = FALSE, winslash = "/")
      print(destfile)
      assign(upload_table_colnames[7], tools::md5sum(input$upload.file$datapath))
      tryCatch(file.rename(input$upload.file$datapath, destfile),
        warning = function(w) {
        file.copy(input$upload.file$datapath, destfile, overwrite = TRUE)
      })
      assign(upload_table_colnames[2], destfile)
      assign(upload_table_colnames[3], file.size(destfile))
      print(input$upload.file.type)
      if (input$upload.file.type != "auto") {
        assign(upload_table_colnames[4], input$upload.file.type)
      } else {
        supported_file_type <- config$shiny_upload$supported_file_type
        supported_file_type <- c(supported_file_type, paste0(supported_file_type, 'gz'))
        supported_file_type <- supported_file_type[supported_file_type != "auto"]
        index <- stringr::str_detect(input$upload.file$name,
                   sprintf("%s$", supported_file_type))
        if (sum(index) == 0) {upload.file.type <- "unknown"} else {
          upload.file.type <- supported_file_type[index][
            max.col(matrix(stringr::str_length(supported_file_type[index]), nrow = 1))
          ]
        }
        assign(upload_table_colnames[4], upload.file.type)
      }
      assign(upload_table_colnames[5], input$upload.genome.version)
      assign(upload_table_colnames[6], format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
      assign(upload_table_colnames[8], input$upload.file.description)
      row_data <- NULL
      for (var in c("id", upload_table_colnames)) {
        row_data <- c(row_data, get(var))
      }
      row_data <- data.frame(row_data)
      row_data <- t(row_data)
      row_data <- as.data.frame(row_data)
      colnames(row_data) <- c("id", upload_table_colnames)


      DBI::dbWriteTable(con, upload_table,
        row_data, append = TRUE, row.names = FALSE)
      shinyjs::alert("Upload and update database successful!")
      shinyjs::reset("upload.file")
      shinyjs::toggleState(id = "upload_save")
      # update file view UI and ovserve the preview and delete event
      render_files_info_DT()
      output <- set_preview(id, output = output)
      delete_file_item(id)
      DBI::dbDisconnect(con)
      # Chose the navbar
      updateNavbarPage(session, "navbar_tabs", selected = "file_viewer")
      update_configuration_files()
      output <- render_input_box_ui(input, output)
    }
  })
  return(list(output = output, session = session))
}
