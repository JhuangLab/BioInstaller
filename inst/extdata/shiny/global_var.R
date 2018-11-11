skin <- Sys.getenv("DASHBOARD_SKIN")
auto_create <- as.logical(Sys.getenv("AUTO_CREATE_BIOINSTALLER_DIR", TRUE))
skin <- tolower(skin)

# Read configuration file and set the environment vars
config.file.template.repo <- system.file("extdata", "config/shiny/shiny.config.yaml",
                                    package = "BioInstaller")
config.file.template <- Sys.getenv("BIOINSTALLER_SHINY_CONFIG", config.file.template.repo)
if (!file.exists(config.file.template)) config.file.template <- config.file.template.repo
config <- configr::read.config(config.file.template)
db_dirname<- dirname(config$shiny_db$db_path)
config.file <- sprintf("%s/shiny.config.yaml", db_dirname)
if (!dir.exists(db_dirname) && auto_create) {
  dir.create(db_dirname)
} else if (!dir.exists(db_dirname) && !auto_create){
  stop("Please set the 'auto_create' in web() to TRUE, or AUTO_CREATE_BIOINSTALLER_DIR to TRUE.")
}
if (!file.exists(config.file) || !configr::is.yaml.file(config.file)) 
    file.copy(config.file.template, sprintf("%s/shiny.config.yaml", db_dirname))
Sys.setenv(BIOINSTALLER_SHINY_CONFIG = sprintf("%s/shiny.config.yaml", db_dirname))

shiny_plugin_dir_repo <- system.file("extdata", "config/shiny", package = "BioInstaller")
shiny_plugin_dir <- shiny_plugin_dir_repo
if (!is.null(config$shiny_plugins$shiny_plugin_dir)) {
  shiny_plugin_dir <- config$shiny_plugins$shiny_plugin_dir
}
if (!dir.exists(shiny_plugin_dir) || length(list.files(shiny_plugin_dir)) == 0) {
  BioInstaller::copy_plugins(shiny_plugin_dir, auto_create = auto_create)
}

db_type <- config$shiny_db$db_type
db_path <- normalizePath(config$shiny_db$db_path, mustWork = FALSE)
if (!dir.exists(dirname(db_path))) dir.create(dirname(db_path), recursive = TRUE)
upload_table <- config$shiny_db_table$upload_data_table_name
upload_table_colnames <- config$shiny_db_table$upload_data_table_colnames
upload_dir <- normalizePath(config$shiny_upload$upload_dir, mustWork = FALSE)
if (!dir.exists(upload_dir)) dir.create(upload_dir, recursive = TRUE)
download_dir <- normalizePath(config$shiny_download$download_dir, mustWork = FALSE)
db_dir <- download_dir
if (!dir.exists(download_dir)) dir.create(download_dir, recursive = TRUE)
task_table <- config$shiny_db_table$task_table_name
task_table_admin_key <- config$shiny_db_table$task_table_admin_key
queue_db <- normalizePath(config$shiny_queue$queue_db, mustWork = FALSE)
if (!dir.exists(dirname(queue_db))) dir.create(dirname(queue_db), recursive = TRUE)
shiny_queue_name <- config$shiny_queue$name
log_dir = config$shiny_queue$log_dir
if (!dir.exists(log_dir)) dir.create(log_dir, recursive = TRUE)
shiny_output_dir <- config$shiny_output$out_dir
shiny_output_tmp_dir <- config$shiny_output$tmp_dir
if (!dir.exists(shiny_output_dir)) dir.create(shiny_output_dir, recursive = TRUE)
if (!dir.exists(shiny_output_tmp_dir)) dir.create(shiny_output_tmp_dir, recursive = TRUE)
shiny_output_dir <- normalizePath(shiny_output_dir, mustWork = FALSE)
output_file_table_name <- config$shiny_db_table$output_file_table_name

shiny_preview <- config$shiny_preview

shiny_tools <- unname(unlist(config$shiny_tools))
shiny_tools_list <- config$shiny_tools
shiny_tools_path <- config$shiny_tools_path

options(shiny.maxRequestSize = 30000 * 1024^2)

if (skin == "") skin <- "blue"


featch_files <- function(file_types = NULL) {
  con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
  sql <- sprintf("SELECT * FROM %s", upload_table)
  if (!upload_table %in% DBI::dbListTables(con)) {
    info <- matrix(data = NA, nrow = 1, ncol = length(upload_table_colnames))
    info <- as.data.frame(info)
    colnames(info) <- upload_table_colnames
    info <- info[-1, ]
  } else {
    info <- DBI::dbGetQuery(con, sql)
  }
  if (!is.null(file_types))
    info <- info[info$file_type %in% file_types,]
  DBI::dbDisconnect(con)
  return(info)
}

update_configuration_files <- function(){

  for(toolname in shiny_tools) {
    plugin <- sprintf("%s/shiny.%s.parameters.toml", shiny_plugin_dir, toolname)
    if (!file.exists(plugin)) {warning(sprintf("Plugin %s not found.", plugin)); next}
    config <-  configr::read.config(plugin,
      rcmd.parse = TRUE, glue.parse = TRUE, file.type = "toml")
    assign(sprintf("config.%s", toolname), config, envir = globalenv())
  }
}

render_input_box_ui <- function(input, output) {
  for(tool_name in shiny_tools) {
    config <- get(sprintf("config.%s", tool_name), envir = globalenv())
    items <- config[[tool_name]]$ui$sections$order
    for(item in items) {
      if ("input_ui_order" %in% names(config[[tool_name]]$paramters[[item]])) {
        input_sections <- config[[tool_name]]$paramters[[item]]$input_ui_order
        for (input_section in input_sections) {
          input_section_dat <- config[[tool_name]]$paramters[[item]]$input[[input_section]]
          section_type <- input_section_dat$type
          title <- input_section_dat$title
          title_control <- input_section_dat$title_control
          label <- input_section_dat$label
          choices <- input_section_dat$choices
          selected <- input_section_dat$selected
          varname <- input_section_dat$varname
          input_id <- input_section_dat$input_id
          for (id_index in 1:length(input_id)) {
            render_ui <- function(id_index) {
              var <- varname[id_index]
              advanced_params <- sprintf("%s(inputId='%s', label = '%s'",
                                         section_type[id_index], input_id[id_index],
                                         label[id_index])
              for (param_name in c("choices", "selected", "width", "multiple",
                                   "buttonLabel", "placeholder", "value", "height", "rows", "cols",
                                   "resize")) {
                if (param_name %in% names(input_section_dat)) {
                  if (is.null(names(input_section_dat[[param_name]]))) var <- id_index
                  param_value <- input_section_dat[[param_name]][[var]]
                  if (is.null(param_value)) next
                  if (is.character(param_value) && length(param_value) == 1) {
                    advanced_params <- sprintf("%s, %s='%s'", advanced_params,
                                               param_name, input_section_dat[[param_name]][[var]])
                  } else if (length(param_value) == 1) {
                    advanced_params <- sprintf("%s, %s=%s", advanced_params,
                                               param_name, input_section_dat[[param_name]][[var]])
                  } else if (is.character(param_value)) {
                    val_paste <- paste0(input_section_dat[[param_name]][[var]], collapse = "','")
                    advanced_params <- sprintf("%s, %s=c('%s')", advanced_params,
                                               param_name, val_paste)
                  } else {
                    val_paste <- paste0(input_section_dat[[param_name]][[var]], collapse = ',')
                    advanced_params <- sprintf("%s, %s=c(%s)", advanced_params,
                                               param_name, val_paste)
                  }
                }
              }
              advanced_params <- sprintf("%s)", advanced_params)
              cmd <- sprintf("output$%s_ui_output <- renderUI({eval(parse(text = advanced_params))})",
                             input_id[id_index])
              eval(parse(text = cmd))
            }
            render_ui(id_index)
          }
        }
      }
    }
  }
  return(output)
}

clean_parsed_item <- function(item, req_parse = FALSE) {
  if (is.null(item)) {
    return(NULL)
  }
  item <- stringr::str_replace_all(item, "\\\\n", "\n")
  item <- stringr::str_replace_all(item, "\\\\\"", "\"")
  item <- stringr::str_replace_all(item, "‘", "'")
  item <- stringr::str_replace_all(item, "’", "'")
  item <- stringr::str_replace_all(item, "，", ", ")
  item <- stringr::str_replace_all(item, '“', '"')
  item <- stringr::str_replace_all(item, '”', '"')
  if (req_parse) {
    return(sprintf("eval(parse(text = %s))", item))
  }
  item
}

generate_boxes_object <- function(config, tool_name) {
  items <- config[[tool_name]]$ui$sections$order
  sapply(items, function(item) {
    basic_params <- config[[tool_name]]$ui$sections$ui_basic[[item]]
    section_type <- config[[tool_name]]$paramters[[item]]$section_type
    if (section_type == "input") {
      input_sections <- config[[tool_name]]$paramters[[item]]$input_ui_order
      advanced_params <- ""
      for (input_section in input_sections) {
        input_section_dat <- config[[tool_name]]$paramters[[item]]$input[[input_section]]
        section_type <- input_section_dat$type
        title <- input_section_dat$title
        title_control <- input_section_dat$title_control
        label <- input_section_dat$label
        choices <- input_section_dat$choices
        selected <- input_section_dat$selected
        varname <- input_section_dat$varname
        input_id <- input_section_dat$input_id
        if (!is.null(title) && !is.null(title_control)) {
          advanced_params <- sprintf("%s, shiny::p('%s', %s)", advanced_params,
                                     title, title_control)
        } else if (!is.null(title)) {
          advanced_params <- sprintf("%s, shiny::p('%s')", advanced_params)
        }
        for (id_index in 1:length(input_id)) {

          var <- varname[id_index]
          advanced_params <- sprintf("%s, shiny::uiOutput(outputId = '%s_ui_output')", advanced_params,
                                     input_id[id_index])
        }
      }
      advanced_params <- sprintf("%s, hr(), shiny::uiOutput('lastcmd_ui_%s')",
                                 advanced_params, config[[tool_name]]$paramters[[item]]$render_id)
    } else {
      render_id <- config[[tool_name]]$paramters[[item]]$render_id
      render_type <- config[[tool_name]]$paramters[[item]]$render_type
      output_type <- config[[tool_name]]$paramters[[item]]$output_type

      advanced_params <- sprintf(", withSpinner(%s(outputId = '%s'), type = 8)",
                                 output_type, render_id)
      if (render_type %in% c("shiny::renderImage", "shiny::renderPlot")) {

        export_params <- config[[tool_name]]$paramters[[item]]$export_params
        width <- stringr::str_replace(stringr::str_extract(export_params,
                                                           "width = [0-9]*"), "width = ", "")
        height <- stringr::str_replace(stringr::str_extract(export_params,
                                                            "height = [0-9]*"), "height = ", "")
        advanced_params <- sprintf("%s, shiny::uiOutput('rcmd_preprocess_ui_%s')",
                                   advanced_params, render_id)
        advanced_params <- sprintf("%s, shiny::uiOutput('lastcmd_ui_%s')",
                                   advanced_params, render_id)
        if (tool_name != "gvmap") {
          advanced_params <- sprintf("%s, shiny::column(6, wellPanel (shiny::sliderInput('export_%s_height', min = 0, max = 100, value = %s, label = 'height (cm)')))",
                                     advanced_params, render_id, height)
          advanced_params <- sprintf("%s, shiny::column(6, wellPanel (shiny::sliderInput('export_%s_width', min = 0, max = 100, value = %s, label = 'width (cm)')))",
                                     advanced_params, render_id, width)
        }
        advanced_params <- sprintf("%s, shiny::downloadButton('export_%s', label = 'Export', disabled = 'disabled')",
                                   advanced_params, render_id)
        advanced_params <- sprintf("%s, shiny::actionButton('update_%s', label = 'Update plot', icon = icon('refresh'), disabled = 'disabled')",
                                   advanced_params, render_id)
      } else {
        advanced_params <- sprintf("%s, shiny::uiOutput('rcmd_preprocess_ui_%s')",
                                   advanced_params, render_id)
        advanced_params <- sprintf("%s, shiny::uiOutput('lastcmd_ui_%s')",
                                   advanced_params, render_id)
        advanced_params <- sprintf("%s, shiny::actionButton('update_%s', label = 'Update output', icon = icon('refresh'), disabled = 'disabled')",
                                   advanced_params, render_id)
      }
    }

    cmd <- sprintf("box(%s%s)", basic_params, advanced_params)
    return(cmd)
  })
}

get_start_id <- function(con, table_name) {
  sql <- sprintf("select id from %s", table_name)
  ids <- DBI::dbGetQuery(con, sql)
  if (nrow(ids) == 0) {
    id <- 1
  } else {
    id <- RSQLite::dbGetQuery(con,
                              sprintf("SELECT seq from sqlite_sequence where name = '%s'",
                                      table_name))
    id <- as.numeric(id) + 1
  }
  return(id)
}

delete_file_item <- function(id, id_prefix = "files_del_", dt_id = "files_info_DT",
                             query_string = "?delete_id=", confimed_id = "delete_confirmed") {
  shinyjs::onclick(sprintf("%s%s", id_prefix, id), function(event) {
    shinyjs::runjs(sprintf("
                           if(!confirm('Confirm to delete？')){
                           window.event.returnValue = false;
                           } else {
                           var tb_id = $('#%s :first').attr('id').replace('_wrapper', '')
                           tb_id = eval(tb_id)
                           tb_id.deleteRow($('#%s%s').closest('tr').index() + 1);
                           $('#%s').click();
                           };", dt_id, id_prefix, id, confimed_id))
        updateQueryString(sprintf("%s%s", query_string, id), mode = "push")
  })
}

set_preview <- function(id, id_prefix = "files_view_", dt_id = "file_preview_DT",
                        output = "", con = "") {
  shinyjs::onclick(sprintf("%s%s", id_prefix, id), function(event) {
    con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
    shinyjs::reset(dt_id)
    tryCatch({
      output[[dt_id]] <- DT::renderDataTable({
        sql <- sprintf("SELECT file_path,file_type FROM %s where id=%s",
                       upload_table, id)
        upload_table_data <- DBI::dbGetQuery(con, sql)
        DBI::dbDisconnect(con)
        file_content <- fread(upload_table_data$file_path)
        return(file_content)
      }, rownames = FALSE, editable = FALSE, caption = "All files stored in shinyapp Web service",
      escape = FALSE, extensions = c("Buttons", "Scroller"), options = list(dom = "Bfrtlip",
      searchHighlight = TRUE, scrollX = TRUE, buttons = c("copy", "csv",
      "excel", "pdf", "print"), lengthMenu = list(list(5, 10, 25, 50, -1),
      list(5, 10 , 25, 50, "All")), initComplete = DT::JS("function(settings, json) {",
      "$(this.api().table().header()).css({'background-color': '#487ea5', 'color': '#fff'});",
      "}")), selection = "single")
    }, error = function(e){})
  })
  return(output)
}

set_preview_2 <- function(id, id_prefix = "output_files_view_", dt_id = "task_table_output_preview_DT",
                        output = "") {
  shinyjs::onclick(sprintf("%s%s", id_prefix, id), function(event) {
    output$task_table_hr4 <- renderUI(HTML(paste0(h4("Output of preview"), hr())))
    con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
    shinyjs::reset(dt_id)
    tryCatch({
      output[[dt_id]] <- DT::renderDataTable({
        sql <- sprintf("SELECT file_basename,file_dir FROM %s where id=%s",
                       output_file_table_name, id)
        output_file_table_dat <- DBI::dbGetQuery(con, sql)
        DBI::dbDisconnect(con)
        tryCatch({
          file_content <- fread(sprintf("%s/%s", output_file_table_dat$file_dir,
                                        output_file_table_dat$file_basename))
        }, error = function(e){})
      }, rownames = FALSE, editable = FALSE, caption = "Output files preview",
      escape = FALSE, extensions = c("Buttons", "Scroller", "FixedColumns"), options = list(dom = "Bfrtlip",
      searchHighlight = TRUE, scrollX = TRUE, buttons = c("copy", "csv",
      "excel", "pdf", "print"), lengthMenu = list(list(5, 10, 25, 50, -1),
          list(5, 10 , 25, 50, "All")), initComplete = DT::JS("function(settings, json) {",
      "$(this.api().table().header()).css({'background-color': '#487ea5', 'color': '#fff'});",
      "}")), selection = "single")
    }, error = function(e){})
  })
  return(output)
}

update_ui_coices <- function() {
  tools <- unname(unlist(config$shiny_tools))
  for(tool in tools) {
    config.tmp <- get(sprintf("config.%s", tool))
    config.tmp <- config.tmp[[tool]]$paramters
    box_names <- names(config.tmp)
    for(box in box_names) {
      if ("input" %in% names(config.tmp[[box]])) {
        for(input_item in names(config.tmp[[box]]$input)) {
          if ("choices" %in% names(config.tmp[[box]]$input[[input_item]])) {
            choices <- config.tmp[[box]]$input[[input_item]]$choices
            varname <- config.tmp[[box]]$input[[input_item]]$varname
            input_id <- config.tmp[[box]]$input[[input_item]]$input_id
            #shinyjs::runjs("")
          }
        }

      }
    }
  }
}

sql2sqlite <- function (sql.file = "", statements = "", dbname = "",
          ...)
{
  out.sqlite <- dbname
  if (sql.file != "") {
    message(sprintf("Converting SQL file %s to %s sqlite database.",
                     sql.file, out.sqlite))
  }
  else {
    message(sprintf("Converting SQL statements to %s sqlite database.",
                     out.sqlite))
    message(statements)
  }
  if (statements != "") {
    con <- do.call(dbConnect, list(SQLite(), out.sqlite))
    statements <- str_split(statements, ";\n")[[1]]
    func <- function(line) {
      rs <- dbSendQuery(con, line, ...)
      dbClearResult(rs)
    }
    sapply(statements, func)
    dbDisconnect(con)
  }
  else {
    sqlite <- Sys.which(c("sqlite3", "sqlite"))
    sqlite <- sqlite[sqlite != ""][1]
    sqlite <- unname(sqlite)
    if (is.na(sqlite)) {
      return(FALSE)
    }
    sqlite <- normalizePath(sqlite, "/")
    cmd <- sprintf("%s %s < %s", sqlite, out.sqlite, sql.file)
    message(sprintf("Running CMD:%s", cmd))
    system2(sqlite, args = out.sqlite, stdin = sql.file)
  }
}

submit_task_modal <- function(input, output, params) {
  msg <- jsonlite::toJSON(params)
  queue <- liteq::ensure_queue(shiny_queue_name, db = queue_db)
  while(TRUE) {
    tryCatch({liteq::publish(queue, title = "Tasks", message = msg);break},
             error = function(e) {})
  }
  output <- dashbord_section_server(input, output)
  output$task_submit_modal <- renderUI({
    html_text <- tryCatch(get("html_text_task_submit_modal", envir = globalenv()), error = function(e) {
      html_text <- paste0(readLines("www/modal.html"), collapse = "\n")
      assign("html_text_task_submit_modal", html_text, envir = globalenv())
      return(html_text)
    })
    html_text <- stringr::str_replace_all(html_text, '\\{\\{task_title\\}\\}', "Message")
    html_text <- stringr::str_replace_all(html_text, '\\{\\{task_key\\}\\}', params$qqkey)
    html_text <- stringr::str_replace_all(html_text, '\\{\\{task_msg\\}\\}', encodeString(msg))
    html_text <- sprintf("%s<script>$('#myModal').modal('show')</script>", html_text)
    HTML(html_text)
  })
  return(output)
}

get_tabItem_ui <- function(tabitem = "instant") {
  cmd <- sprintf("body_%s_tabItem <- tabItem('%s', tabsetPanel(type = 'pills', ",
                 tabitem, tabitem)

  count <- 1
  for(tool in shiny_tools_list[[tabitem]]) {
    assign(sprintf("%s_boxes", tool),
           generate_boxes_object(get(sprintf("config.%s", tool)), tool))
    if (count == length(shiny_tools_list[[tabitem]])) {
      cmd <- paste0(cmd, sprintf("tabPanel('%s', fluidRow(%s))", tool,
                                 paste0(unname(get(sprintf("%s_boxes", tool))), collapse = ",")))
    } else {
      cmd <- paste0(cmd, sprintf("tabPanel('%s', fluidRow(%s)),", tool,
                                 paste0(unname(get(sprintf("%s_boxes", tool))), collapse = ",")
      )
      )
    }
    count <- count + 1
  }
  cmd <- paste0(cmd, "))")
  eval(parse(text = cmd))
}

get_bioinstaller_installed <- function() {
  items_db <- Sys.getenv('BIO_SOFTWARES_DB_ACTIVE')
  if (!file.exists(items_db) || file.size (items_db) == 0 || 
      configr::get.config.type (items_db) == FALSE) return(data.frame())
  x <- configr::read.config(items_db)
  if (is.list(x)) {item_name <- names(x);x <- data.table::rbindlist(x, fill = TRUE)} else {return(data.frame())}
  return(cbind(item_name, x))
}
