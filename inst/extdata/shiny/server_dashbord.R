source("config.R")
convertbyte2size <- function(sizes) {
  results <- sapply(sizes, function(size){
    kb <- 1024
    mb <- 1024*1024
    gb <- 1024*1024*1024
    tb <- 1024*1024*1024*1024
    pb <- 1024*1024*1024*1024*1024
    eb <- 1024*1024*1024*1024*1024*1024
    zb <- 1024*1024*1024*1024*1024*1024*1024
    yb <- 1024*1024*1024*1024*1024*1024*1024*1024

    if(size < kb){
      return(paste0(round(size,2), "B"))
    } else if(size < mb){
      return(paste0(round(size/kb,2), "KB"))
    } else if(size < gb){
      return(paste0(round(size/mb,2), "MB"))
    } else if(size < tb){
      return(paste0(round(size/gb,2), "GB"))
    } else if(size < pb){
      return(paste0(round(size/tb,2), "TB"))
    } else if(size < eb){
      return(paste0(round(size/pb,2), "PB"))
    } else if(size < zb){
      return(paste0(round(size/eb,2), "EB"))
    } else if(size < yb){
      return(paste0(round(size/zb,2), "ZB"))
    }
  })
}

convertkb2size <- function (size) {
  kb <- 1
  mb <- 1024
  gb <- 1024*1024
  tb <- 1024*1024*1024
  pb <- 1024*1024*1024*1024
  eb <- 1024*1024*1024*1024*1024
  zb <- 1024*1024*1024*1024*1024*1024
  yb <- 1024*1024*1024*1024*1024*1024*1024

  if(size < mb){
    return(paste0(round(size/kb,2), "KB"))
  } else if(size < gb){
    return(paste0(round(size/mb,2), "MB"))
  } else if(size < tb){
    return(paste0(round(size/gb,2), "GB"))
  } else if(size < pb){
    return(paste0(round(size/tb,2), "TB"))
  } else if(size < eb){
    return(paste0(round(size/pb,2), "PB"))
  } else if(size < zb){
    return(paste0(round(size/eb,2), "EB"))
  } else if(size < yb){
    return(paste0(round(size/zb,2), "ZB"))
  }
}

disk.usage <- function(path = Sys.getenv("HOME")) {
  if(length(system("which df", intern = TRUE))) {
    cmd <- sprintf("df %s", path)
    exec <- system(cmd, intern = TRUE)
    exec <- strsplit(exec[length(exec)], "[ ]+")[[1]]
    exec <- as.numeric(exec[2:4])
    structure(exec, names = c("total", "used", "available"))
  } else {
    print("'df' command not found")
  }
}

set_monitor_progress_bar <- function(id, ratio, span_text) {
  sprintf('$("#%s").attr("aria-valuenow", 100);
                 $("#%s").css("width", "%s%%");
          document.getElementById("%s-text").innerHTML= "%s";',
          id, id, ratio, id, span_text)
}

custom_render_DT <- function(input, output, input_id, cmd = NULL, func = NULL, caption = "",
                             columnDefs = list(list(width = "100px", targets = "_all")),
                             initComplete = DT::JS("function(settings, json) {",
                                                   "$(this.api().table().header()).css({'background-color': '#487ea5', 'color': '#fff'});",
                                                   "}"),
                             lengthMenu = list(list(5,10, 25, 50, -1),
                                               list(5, 10, 25, 50, "All")),
                             buttons = c("copy", "csv", "excel", "pdf", "print"),
                             extensions = c("Buttons", "FixedColumns", "Scroller")) {
    output[[input_id]] <- DT::renderDataTable({
      if (!is.null(cmd)){
        eval(parse(text = cmd))
      } else if (!is.null(func)) {
        func
      }
    }, rownames = FALSE, editable = FALSE, caption = caption,
    escape = FALSE, extensions = extensions,
    options = list(autoWidth = TRUE, dom = "Bfrtlip", deferRender = TRUE,
                   searchHighlight = TRUE, scrollX = TRUE, lengthMenu = lengthMenu,
                   buttons = buttons, columnDefs = columnDefs,
                   initComplete = initComplete), selection = "none")
  return(output)
}

update_system_monitor <- function(input, output) {
  output$system_monitor <- renderUI({
    # disk monitor
    disk.usage.values <- tryCatch(disk.usage(), error = function(e) {
      NULL
    })
    html_text <- tryCatch(get("html_text_update_system_monitor", envir = globalenv()), error = function(e) {
      html_text <- paste0(readLines("./www/system_monitor.html"), collapse = "\n")
      assign("html_text_update_system_monitor", html_text, envir = globalenv())
      return(html_text)
    })
    if (!is.null(disk.usage.values)) {
      disk.used <- disk.usage.values[2]
      if (stringr::str_detect(version$os, 'darwin')){
        disk.total <- disk.usage.values[1] /2
        disk.used <- disk.used / 2
      } else {
        disk.total <- disk.usage.values[1]
      }
      ratio <- round(disk.used/disk.total, 2) * 100
      span_text <- sprintf("%s%% (%s/%s)", ratio, convertkb2size(disk.used),
                           convertkb2size(disk.total))

      html_text <- sprintf('%s\n<script>%s',
                           html_text,
                           set_monitor_progress_bar("diskmonitor", ratio, span_text))
    } else {
      html_text <- sprintf('%s\n<script>', html_text)
    }
    # memory monitor

    memory.info <- as.data.frame(gc())
    total_ram <- as.numeric(stringr::str_extract(benchmarkme::get_ram(), "[0-9.]*"))
    total_ram <- total_ram / 1024
    used_ram <- sum(memory.info[,2]) * 1024
    ratio <- round(used_ram / total_ram, 2) * 100
    span_text <- sprintf("%s / %s", convertkb2size(used_ram),
                         convertkb2size(total_ram))
    html_text <- sprintf("%s\n%s", html_text,
                         set_monitor_progress_bar("memory-monitor", ratio, span_text))
    # tasks monitor
    while(TRUE) {
      queue_obj <- tryCatch({
        ensure_queue(shiny_queue_name, db = queue_db)
      }, error = function(e) {
        FALSE
      })
      if (!is.logical(queue_obj)) break
    }

    tasks_tb <- list_messages(queue_obj)
    tasks.total <- nrow(tasks_tb)
    tasks.queue <- nrow(tasks_tb[tasks_tb$status == "READY",])
    tasks.running <- tasks.total - tasks.queue
    if (tasks.total == 0) {
      ratio <- 0
      span_text <- "No task"
    } else {
      ratio <- round(tasks.running / tasks.total, 2) * 100
      span_text <- sprintf("Running(%s) / Total(%s)", tasks.running, tasks.total)
    }
    html_text <- sprintf("%s\n%s;", html_text,
                         set_monitor_progress_bar("queue-tasks", ratio, span_text))
    if (input$dashbord_auto_update == 0){
      html_text <- sprintf("%s\nfunction dashbord_auto_update()
                           {$('#dashbord_auto_update').click();}; setInterval(dashbord_auto_update,'10000');</script>", html_text)
    } else {html_text <- sprintf("%s</script>", html_text)}
    HTML(html_text)
    })
  return(output)
}

dashbord_section_server <- function(input, output) {

  output <- update_system_monitor(input, output)

  output$r_session_info_monitor <- renderPrint({
    print(sessionInfo())
  })

  output <- custom_render_DT(input, output, "r_packages_info_monitor", "installed.packages()")
  output <- custom_render_DT(input, output, "r_env_info_monitor", "x <- Sys.getenv(); y <- unname(x); attributes(y) <- NULL; data.frame(var=names(x), value=y)")

  output <- custom_render_DT(input, output, "files_of_path_monitor",
"result <- NULL; for(x in str_split(Sys.getenv('PATH'), ':')[[1]]) {
  files <- list.files(x)
  files <- file.path(x, files)
  result <- rbind(result, data.frame(files, file.info(files)))
  result <- result[!is.na(result[,2]),]
  row.names(result) <- NULL
}; result[,c(1:3, 5:ncol(result))]")
  render_task_table <- function() {
    req(input$task_table_key)
    con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
    result <- NULL
    if (input$task_table_key == task_table_admin_key) {
      sql <- sprintf("SELECT * FROM %s", task_table)
      result <- DBI::dbGetQuery(con, sql)
    } else {
      sql <- sprintf("SELECT * FROM %s WHERE key = '%s'", task_table, input$task_table_key)
      result <- DBI::dbGetQuery(con, sql)
    }
    DBI::dbDisconnect(con)
    return(result)
  }
  render_task_output_table <- function() {
    req(input$task_table_key)
    con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
    result <- NULL
    if (input$task_table_key == task_table_admin_key) {
      sql <- sprintf("SELECT * FROM %s", output_file_table_name)
      result <- DBI::dbGetQuery(con, sql)
    } else {
      sql <- sprintf("SELECT * FROM %s WHERE key = '%s'", output_file_table_name, input$task_table_key)
      result <- DBI::dbGetQuery(con, sql)
    }
    file_dir <- stringr::str_extract(result[, 3], 'output/.*')
    Action <- sprintf("<button id = 'output_files_view_%s' name = 'output_files_view_%s' type='button' class = 'btn btn-primary action-button shiny-bound-input'><i class='fa fa-eye'></i></button>",
                      result[, 1], result[, 1])
    Action <- sprintf("%s <button id = 'output_files_del_%s' name = 'output_files_del_%s' type='button' class = 'btn btn-primary action-button shiny-bound-input'><i class='fa fa-trash'></i></button>",
                      Action, result[, 1], result[, 1])
    Action <- sprintf("%s <a id = 'output_files_download_%s' name = 'output_files_download_%s' type='button' class = 'btn btn-primary' href = '%s/%s', download><i class='fa fa-download'></i></a>",
                      Action, result[, 1], result[, 1], file_dir, result[, 2])
    result <- data.frame(result[1], Action, result[2:ncol(result)])
    for(id in result[,1]) {
      delete_file_item(id, "output_files_del_", "task_table_output_DT",
                       "?file_delete_id=", "outfn_delete_confirmed")
      output <- set_preview_2(id, output = output)
    }
    DBI::dbDisconnect(con)

    return(result)
  }

  observeEvent(input$outfn_delete_confirmed, {
    con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
    id <- getQueryString()
    status <- DBI::dbSendQuery(con, sprintf("DELETE FROM %s WHERE id=%s", output_file_table_name,
                                            id))
    print(status)
    shinyjs::alert("Delete successful!")
    update_configuration_files()
    output <- render_input_box_ui(input, output)
    DBI::dbDisconnect(con)
  })

  observeEvent(input$task_table_button, {
    output$task_table_hr1 <- renderUI(HTML(paste0(br(), h4("Task information"), hr())))
    output$task_table_hr2 <- renderUI(HTML(paste0(br(), h4("Output of output files"), hr())))
    output$task_table_hr3 <- renderUI(HTML(paste0(h4("Output of log"),hr())))
    func1 <- render_task_table()
    output <- custom_render_DT(input, output, "task_table_DT", func = func1,
                               caption = "Task information")

    func2 <- render_task_output_table()
    output <- custom_render_DT(input, output, "task_table_output_DT", func = func2,
                               caption = "Output files",
                               columnDefs = list(list(width = "150px",
                               targets = c(1,5))))
    output$task_table_output_preview_DT <- renderDataTable(NULL)
    output$task_table_hr4 <- renderUI(NULL)
    output$task_table_log <- renderPrint({
      for(fn in eval(func1)$log) {
         if (file.exists(fn)) {
           cat(sprintf("\n\n-------------------------- %s ------------------------\n", fn))
           cat(paste0(readLines(fn), collapse = '\n'))
         }
      }
    })
  })

  output <- custom_render_DT(input, output, "bioinstaller_items_monitor",
                             "get_bioinstaller_installed()")
  output <- custom_render_DT(input, output, "conda_envlist_monitor",
                             "tryCatch(BioInstaller::conda.env.list(), warning=function(w){data.frame()})")
  output$conda_env_name_ui <- renderUI({
    conda_envs <- BioInstaller::conda.env.list()
    if (is.data.frame(conda_envs)) conda_envs <- conda_envs[,1]
    selectInput("conda_env_name", "Environment name",
                choices = conda_envs,
                selected = conda_envs[1])
  })
  output <- custom_render_DT(input, output, "conda_items_monitor",
                             "tryCatch(BioInstaller::conda.list(env_name = input$conda_env_name), warning = function(w){data.frame()})")

  output$spack_items_monitor <- renderPrint({
    cat(BioInstaller::spack("find"))
  })
  return(output)
}
