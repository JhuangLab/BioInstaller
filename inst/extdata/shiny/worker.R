shiny_config_file =
  Sys.getenv("BIOINSTALLER_SHINY_CONFIG", system.file("extdata", "config/shiny/shiny.config.yaml",
                                                  package = "BioInstaller"))

config <- configr::read.config(shiny_config_file)
db_type <- config$shiny_db$db_type
db_path <- normalizePath(config$shiny_db$db_path, mustWork = FALSE)
queue_db <- normalizePath(config$shiny_queue$queue_db, mustWork = FALSE)
task_table <- config$shiny_db_table$task_table_name
shiny_queue_name <- config$shiny_queue$name
log_dir <- config$shiny_queue$log_dir
output_file_table_name <- config$shiny_db_table$output_file_table_name
shiny_output_dir <- config$shiny_output$out_dir
get_start_id <- function(con, table_name) {
    id <- RSQLite::dbGetQuery(con,
                              sprintf("SELECT seq from sqlite_sequence where name = '%s'",
                                      table_name))
    if (nrow(id) == 0) {id <- 1} else {id <- as.numeric(id[,1]) + 1}
  return(id)
}
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


while (TRUE) {
  queue <- NULL
  tryCatch(queue <- liteq::ensure_queue(shiny_queue_name, queue_db),
           error = function(e) {})
  if (is.list(queue)) {
    break
  }
}

while (TRUE) {
  task <- liteq::try_consume(queue)
  if (!is.null(task)) {
    params <- jsonlite::fromJSON(task$message)
    for (item in c("qqcommand", "qqkey", "qqcommand_type", "req_pkgs",
                   "input2var", "input", "boxes", "toolname",
                   "last_cmd")) {
      assign(item, params[[item]])
      params[[item]] <- NULL
    }
    log_file <- sprintf("%s/%s.log", log_dir, qqkey)
    log_con <- file(log_file)
    sink(log_con, append = TRUE)
    sink(log_con, append = TRUE, type = "message")
    cat(sprintf("@@Task start at:@@ %s\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
    cat(sprintf("@@Worker nodename:@@ %s\n", Sys.info()[["nodename"]]))
    cat(sprintf("@@Worker user:@@ %s\n", Sys.getenv("USER")))
    cat(sprintf("@@Worker locale:@@ %s\n", Sys.getlocale()))
    cat(sprintf("@@Worker PID:@@ %s\n", Sys.getpid()))
    con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
    need.initial <- nrow(DBI::dbGetQuery(con, sprintf("SELECT * FROM %s WHERE key = \"%s\"",
                                                      task_table, qqkey))) == 0
    if (need.initial) {
      id <- RSQLite::dbGetQuery(con, sprintf("SELECT seq from sqlite_sequence where name = \"%s\"", task_table))
      if (nrow(id) == 0) {
        id <- 1
      } else {
        id <- as.numeric(id) + 1
      }

      dt <- data.frame(id = id, msgid = task$id, key = qqkey, status = "READY",
        log = log_file)
      DBI::dbWriteTable(con, task_table, dt, append = TRUE)
    }
    DBI::dbSendQuery(con, sprintf("UPDATE %s SET status = \"RUNNING\" WHERE key = \"%s\";",
                                  task_table, qqkey))

    if (is.null(qqcommand_type))
      qqcommand_type <- "r"
    status <- FALSE
    if (tolower(qqcommand_type) == "r") {
      cat(sprintf("%s Running R command for key %s
", format(Sys.time(), "%Y %m-%d %X"), qqkey))
      worker_do_env <- new.env()
      if (is.null(req_pkgs) | req_pkgs == "") {cmd <- ""} else {
        cmd <- 'sapply(req_pkgs, function(x){require(x, character.only = TRUE)})'
      }

      if (qqcommand != "") {
        status <- tryCatch({
          cat(sprintf("@@CMD:@@ %s\n", cmd))
          eval(parse(text = cmd), envir = worker_do_env)
          cat(sprintf("@@CMD:@@ %s\n", qqcommand))
          cat("@@Params:@@\n")
          print(params)
          do.call(eval(parse(text = qqcommand), envir = worker_do_env), params,
                  envir = worker_do_env)},
                           error = function(e) {
                             message(e$message)
                             FALSE
                           })
        if (is.character(status) || is.numeric(status)) {cat(status)} else {print(status)}
      } else {
        status <- tryCatch({
         eval(parse(text = cmd), envir = worker_do_env)
         sapply(1:length(input2var), function(x) {
           message(sprintf("%s => ", names(input2var)[[x]]))
           print(input[[input2var[[x]]]])
           assign(names(input2var)[[x]], input[[input2var[[x]]]], envir = worker_do_env)
         })
         sapply(1:length(last_cmd), function(x){
           message(last_cmd[[x]])
           eval(parse(text = last_cmd[[x]]), envir = worker_do_env)
         })
        }, error = function(e) {message(e$message)})
        if (is.character(status) || is.numeric(status)) {cat(status)} else {print(status)}
      }
      sink()
      sink(type = "message")
    }
    if (is.logical(status) && !status) {
      DBI::dbSendQuery(con, sprintf("UPDATE %s SET status = \"FAILD\" WHERE key = \"%s\";",
                                    task_table, qqkey))
    } else {
      DBI::dbSendQuery(con, sprintf("UPDATE %s SET status = \"FINISHED\" WHERE key = \"%s\";",
                                    task_table, qqkey))
    }

    if (dir.exists(sprintf("%s/%s", shiny_output_dir, qqkey))) {
      files <- list.files(sprintf("%s/%s", shiny_output_dir, qqkey), recursive = TRUE)
      if (!length(files) == 0) {
        files <- sprintf("%s/%s/%s", shiny_output_dir, qqkey, files)
        filesinfo <- file.info(files)
        id <- get_start_id(con, output_file_table_name)
        print(id)
        print(files)
        if (length(files) != 1)
          id = id:(id+(length(files) - 1))
        result <- data.frame(id = id, file_basename = basename(files),
                             file_dir = dirname(files),
                             file_size = convertbyte2size(filesinfo$size),
                             file_mtime = format(filesinfo$mtime, "%Y-%m-%d %H:%M:%S"),
                             key = rep(qqkey, length(files)))
        DBI::dbWriteTable(con, output_file_table_name,
                          result, append = TRUE, row.names = FALSE)
      }
    }

    DBI::dbDisconnect(con)
    liteq::ack(task)
    liteq::remove_failed_messages(queue)
  } else {
    Sys.sleep(10)
  }
}
