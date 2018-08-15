generate_server_object <- function(input, output, ui_server_config, toolname, pkgs = NULL) {
  ui.sections <- ui_server_config[[toolname]]$ui$sections
  params <- ui_server_config[[toolname]]$paramters
  total_box_num <- length(ui.sections$order)
  for(item in ui.sections$order) {
    output <- render_input_command(input, output, params, item)
  }
  start_trigger <- sprintf("start_%s_analysis", toolname)
  observeEvent(input[[start_trigger]], {
    progress <- shiny::Progress$new()
    if (!is.null(pkgs) && input[[start_trigger]] == 1) {sapply(pkgs, function(x){
      msg <- sprintf("Loading %s ...", x)
      for (i in 1:100) {
        progress$set(message = msg, value = i/100)
        Sys.sleep(0.02)
      }
      require(x, character.only = TRUE)
    })}
    shinyjs::disable(start_trigger)
    msg <- sprintf("Running %s task steps,  waiting please...", toolname)
    for (i in 1:100) {
      progress$set(message = msg, value = 1)
      Sys.sleep(0.02)
    }
    on.exit({
      progress$close();
      shinyjs::enable(start_trigger)
    })
    item_num <- 1
    for (item in ui.sections$order) {
      check_sprintf <- params[[item]][["rcmd_last_sprintf"]]
      req_eval <- !is.null(check_sprintf) && check_sprintf
      if (params[[item]]$section_type == "input") {
        for (ui_section in params[[item]]$input_ui_order) {
          input_section <- params[[item]]$input[[ui_section]]
          if (!is.null(input_section$varname)) {
            for (var_idx in 1:length(input_section$varname)) {
                assign(input_section$varname[var_idx], input[[input_section$input_id[var_idx]]], envir = globalenv())
            }
          }
        }
        cmd <- clean_parsed_item(input[[paste0("lastcmd_", params[[item]]$render_id)]], FALSE)
        if (is.null(cmd)) {
          cmd <- clean_parsed_item(params[[item]][["rcmd_last"]], req_eval)
        }
        tryCatch(eval(parse(text = cmd), envir = globalenv()),
                 error = function(e) {shiny::showNotification(e$message, type = "error")},
                 warning = function(w){shiny::showNotification(w$message, type = "warning")})
      }
      for (rcmd in c("rcmd_preprocess")) {
        if (rcmd %in% names(params[[item]])) {
          cmd <- input[[paste0(rcmd, "_", params[[item]]$render_id)]]
          if (is.null(cmd)) {
            check_sprintf_2 <- params[[item]][[paste0(rcmd, "_sprintf")]]
            req_eval_2 <- !is.null(check_sprintf_2) && check_sprintf_2
            cmd <- clean_parsed_item(params[[item]][[rcmd]], req_eval_2)
          }
          tryCatch(eval(parse(text = cmd), envir = globalenv()),
                   error = function(e) {shiny::showNotification(e$message, type = "error")},
                   warning = function(w){shiny::showNotification(w$message, type = "warning")})
        }
      }
      render_type <- params[[item]]$render_type

        cmd <- clean_parsed_item(input[[paste0("lastcmd_", params[[item]]$render_id)]], FALSE)
      if (!is.null(render_type) && render_type == "DT::renderDataTable") {
        render_tool_DT <- function(item) {
          DT_opt <- set_DT_opt(params, item)
          if (is.null(cmd)) {
            cmd <- clean_parsed_item(params[[item]][["rcmd_last"]], req_eval)
          }
          render_dat <- tryCatch(eval(parse(text = cmd), envir = globalenv()),
                                 error = function(e) {shiny::showNotification(e$message, type = "error")},
                                 warning = function(w){shiny::showNotification(w$message, type = "warning")})
          cmd <- sprintf("output$%s <- %s({render_dat}, caption = 'Output table', rownames = FALSE, editable = FALSE, options = DT_opt, escape = FALSE, selection = 'none', extensions = c('Buttons', 'FixedColumns', 'Scroller'))",
            params[[item]]$render_id, render_type)
          tryCatch(eval(parse(text = cmd)),
                   error = function(e) {shiny::showNotification(e$message, type = "error")},
                   warning = function(w){shiny::showNotification(w$message, type = "warning")})

          output <- update_hander_from_params(input, output, toolname, params, item, update_hander_DT_func,
                                              other_object = list(DT_opt = DT_opt))

        }
        render_tool_DT(item)
      } else if (!is.null(render_type)) {
        render_tool_plot <- function(item) {
          render_params <- params[[item]]$render_params
          if (is.null(render_params))  render_params <- ""
          else render_params <- paste0(', ', render_params)
          if (is.null(cmd)) {
            cmd <- sprintf("%s({%s}%s)", params[[item]]$render_type,
                           clean_parsed_item(params[[item]]$rcmd_last, req_eval), render_params)
          } else {
            cmd <- sprintf("%s({%s}%s)", params[[item]]$render_type, cmd, render_params)
          }
          tryCatch(output[[params[[item]]$render_id]] <- eval(parse(text = cmd), envir = globalenv()),
                   error = function(e) {shiny::showNotification(e$message, type = "error")},
                   warning = function(w){shiny::showNotification(w$message, type = "warning")})
          export_id <- paste0("export_", params[[item]]$render_id)
          output <- download_hander_from_params(input, output, params, item, req_eval)
          output <- update_hander_from_params(input, output, toolname, params, item, update_hander_pdf_func)
        }
        render_tool_plot(item)
      }
      progress$set(message = params[[item]]$progressbar_message, value = 1)
      item_num <- item_num + 1
      shinyjs::enable(paste0("update_", params[[item]]$render_id))
      shinyjs::enable(paste0("export_", params[[item]]$render_id))
    }

  })
  return(output)
}

download_hander_from_params <- function(input, output, params, item, req_eval) {
  export_id <- paste0("export_", params[[item]]$render_id)
  export_dev <- params[[item]]$export_engine
  export_dev_param <- sprintf("list(%s)", params[[item]]$export_params)
  export_dev_param <- eval(parse(text = export_dev_param))
  output[[export_id]] <- downloadHandler(sprintf("%s_%s.%s",
     export_id, stringi::stri_rand_strings(1, 6), export_dev_param$type),
     function(theFile) {
       make_pdf <- function(filename){
         export_dev_param$width <- input[[paste0(export_id, "_width")]]
         export_dev_param$height <- input[[paste0(export_id, "_height")]]
         cmd <- clean_parsed_item(input[[paste0("lastcmd_", params[[item]]$render_id)]], FALSE)
         if (is.null(cmd)) {
           cmd <- clean_parsed_item(params[[item]]$rcmd_last, req_eval)
         }
         if (export_dev == "link") {
           obj_list <- tryCatch(eval(parse(text = cmd), envir = globalenv()),
                                error = function(e) {shiny::showNotification(e$message, type = "error")},
                                warning = function(w){shiny::showNotification(w$message, type = "warning")})
           file.copy(obj_list$src, filename)
         } else if (export_dev == "ggsave") {
           export_dev_param$filename <- filename
           export_dev_param$device <- export_dev_param$type
           export_dev_param$type <- NULL
           tryCatch(base::do.call(eval(parse(text = export_dev)), export_dev_param),
                    error = function(e) {shiny::showNotification(e$message, type = "error")},
                    warning = function(w){shiny::showNotification(w$message, type = "warning")})
           eval(parse(text = cmd), envir = globalenv())
         } else {
           export_dev_param$file <- filename
           tryCatch(base::do.call(eval(parse(text = export_dev)), export_dev_param),
                    error = function(e) {shiny::showNotification(e$message, type = "error")},
                    warning = function(w){shiny::showNotification(w$message, type = "warning")})
           eval(parse(text = cmd), envir = globalenv())
           dev.off()
         }
       }
         progress <- shiny::Progress$new()
         for (i in 1:100) {
           progress$set(message = "Exporting...",
                              value = i/100)
           Sys.sleep(0.01)
         }
         make_pdf(theFile)
           on.exit(progress$close())
         })
  return(output)
}

update_hander_pdf_func <- function(input, output, params, item, render_type, render_id, other_object = NULL) {
  cmd <- clean_parsed_item(input[[paste0("rcmd_preprocess_", render_id)]], FALSE)
  render_params <- params[[item]]$render_params
  if (is.null(render_params))  render_params <- ""
  else render_params <- paste0(', ', render_params)
  if (!is.null(cmd)) eval(parse(text = cmd), envir = globalenv())
  cmd <- clean_parsed_item(input[[paste0("lastcmd_", render_id)]], FALSE)
  cmd <- sprintf("%s({%s}%s)", render_type, cmd, render_params)
  tryCatch(output[[render_id]] <- eval(parse(text = cmd)),
           error = function(e) {shiny::showNotification(e$message, type = "error")},
           warning = function(w){shiny::showNotification(w$message, type = "warning")})
  return(output)
}

update_hander_DT_func <- function(input, output, params, item, render_type, render_id, other_object = NULL) {
  DT_opt <- other_object$DT_opt
  cmd <- clean_parsed_item(input[[paste0("rcmd_preprocess_", render_id)]], FALSE)
  if (!is.null(cmd)) eval(parse(text = cmd), envir = globalenv())
  cmd <- clean_parsed_item(input[[paste0("lastcmd_", render_id)]], FALSE)
  render_dat <- tryCatch(eval(parse(text = cmd), envir = globalenv()),
                         error = function(e) {shiny::showNotification(e$message, type = "error")},
                         warning = function(w){shiny::showNotification(w$message, type = "warning")})

  cmd <- sprintf("%s({render_dat}, options = DT_opt)", render_type, cmd)
  output[[render_id]] <- tryCatch(eval(parse(text = cmd)),
                                  error = function(e) {shiny::showNotification(e$message, type = "error")},
                                  warning = function(w){shiny::showNotification(w$message, type = "warning")})
  return(output)
}

set_DT_opt <- function(params, item) {
  DT_opt <- list(autoWidth = TRUE, dom = "Bfrtlip", deferRender = TRUE,
                 searchHighlight = TRUE, scrollX = TRUE, lengthMenu = list(list(5,
                 10, 25, 50, -1), list(5, 10, 25, 50, "All")), buttons = c("copy",
                 "csv", "excel", "pdf", "print"), columnDefs = list(list(width = "100px",
                 targets = "_all")), initComplete = DT::JS("function(settings, json) {",
                 "$(this.api().table().header()).css({'background-color': '#487ea5', 'color': '#fff'});",
                 "}"))
}

update_hander_from_params <- function(input, output, toolname = "maftools", params, item, eval_func, other_object = NULL) {
  render_id <- params[[item]]$render_id
  update_id <- paste0("update_", render_id)
  render_type <- params[[item]]$render_type
  start_trigger <- sprintf("start_%s_analysis", toolname)
  if (input[[start_trigger]] == 1) {
    observeEvent(input[[update_id]], {
      shinyjs::disable(update_id)
      progress <- shiny::Progress$new()
      for (i in 1:100) {
        progress$set(message = "Updating...",
                     value = i/100)
        Sys.sleep(0.01)
      }
      on.exit({
        progress$close()
        shinyjs::enable(update_id)
      })

      output <- do.call(eval_func, list(input = input,
                        output = output, params = params, item = item,
                        render_type = render_type,
                        render_id = render_id, other_object = other_object))
    })
  }
  return(output)
}

render_input_command <- function (input, output, params, item, use_codemirror = FALSE){
  render_id <- params[[item]]$render_id
  check_sprintf <- params[[item]][["rcmd_last_sprintf"]]
  req_eval <- !is.null(check_sprintf) && check_sprintf
  cmd <- clean_parsed_item(params[[item]][["rcmd_last"]], req_eval)
  label = "R commands for task"
  text_area_js <- sprintf("<script type='text/javascript'>var %s_editor = CodeMirror.fromTextArea(%s, {
    lineNumbers: true,
  keyMap: 'sublime',
  theme:'monokai',
  indentUnit: 2,
  gutters: ['CodeMirror-linenumbers', 'CodeMirror-foldgutter'],
  mode: 'r'
});</script>", paste0("lastcmd_", render_id), paste0("lastcmd_", render_id))
  if (!use_codemirror) text_area_js <- ""
  if (cmd != "")
  output[[paste0("lastcmd_ui_", render_id)]] <- renderUI({
    HTML(paste0(shiny::textAreaInput(inputId = paste0("lastcmd_", render_id), label = label,
                         value = cmd, rows = (2 + stringr::str_count(cmd, "\n") * 1.1), resize = "vertical"),
                text_area_js
        )
    )
  })
  check_sprintf_2 <- params[[item]][["rcmd_preprocess_sprintf"]]
  req_eval_2 <- !is.null(check_sprintf_2) && check_sprintf_2
  cmd_2 <- clean_parsed_item(params[[item]][["rcmd_preprocess"]], req_eval)
  if (length(cmd_2) != 0)
    output[[paste0("rcmd_preprocess_ui_", render_id)]] <- renderUI({
      shiny::textAreaInput(inputId = paste0("rcmd_preprocess_",render_id), label = "R commands for preprocess",
                           value = cmd_2, rows = stringr::str_count(cmd_2, "\n") * 1.5, resize = "vertical")
    })
  return(output)
}

generate_submit_server_object <- function(input, output, ui_server_config, toolname, pkgs = NULL) {
  ui.sections <- ui_server_config[[toolname]]$ui$sections
  ui_params <- ui_server_config[[toolname]]$paramters
  total_box_num <- length(ui.sections$order)
  for(item in ui.sections$order) {
    output <- render_input_command(input, output, ui_params, item, TRUE)
  }
  start_trigger <- sprintf("start_%s_analysis", toolname)
  observe({
  observeEvent(input[[start_trigger]], {
    progress <- shiny::Progress$new()
    msg <- sprintf("Submiting task.")
    for (i in 1:100) {
      progress$set(message = msg, value = i/100)
      Sys.sleep(0.02)
    }
      needed.var <- c()
      needed.input_id <- c()
      for(box in ui.sections$order) {
        for(input_section in names(ui_params[[box]]$input)) {
          needed.var <- c(needed.var, ui_params[[box]]$input[[input_section]]$varname)
          needed.input_id <- c(needed.input_id, ui_params[[box]]$input[[input_section]]$input_id)
        }
      }
      names(needed.input_id) <- needed.var
      needed.input_id <- needed.input_id[!is.na(names(needed.input_id))]
      params.1 <- as.list(needed.input_id)
      params.2 <- reactiveValuesToList(input)
      params.2 <- params.2[names(params.2) %in% needed.input_id]
      params <- configr::config.list.merge(list(input2var = params.1),
                                           list(input=params.2))
      on.exit(progress$close())
      if (is.null(pkgs)) pkgs <- ""
      params$req_pkgs <- pkgs
      params$qqcommand <- ""
      params$qqkey <- stringi::stri_rand_strings(1, 50)
      params$qqcommand_type <- "R"
      params$boxes <- ui.sections$order
      params$toolname <- ui.sections$toolname
      observe({
        for(box in ui.sections$order) {
            id <- sprintf("lastcmd_%s_%s", toolname, box)
            eval(parse(text = sprintf("js$get_%s_input()", id)))
            params$last_cmd[[box]] <- input[[sprintf("%s_input_value", id)]]
        }
        if (!is.null(input[[sprintf("%s_input_value", id)]]))
          output <- submit_task_modal(input, output, params)
      })
    })
  })
  return(output)
}

pipeline_tools <- config$shiny_tools$pipeline
for(pipeline_tool in pipeline_tools) {
  pkgs <- config$shiny_tools_params$require[[pipeline_tool]]
  cmd <- sprintf("%s_server <- function(input, output){
  output <- generate_submit_server_object(input, output, config.%s, '%s', pkgs = c(%s))
}", pipeline_tool, pipeline_tool, pipeline_tool,
                 sprintf("'%s'", paste0(pkgs, collapse = "', '")))
  eval(parse(text = cmd))
}


instant_tools <- config$shiny_tools$instant
for(instant_tool in instant_tools) {
  pkgs <- config$shiny_tools_params$require[[instant_tool]]
  cmd <- sprintf("%s_server <- function(input, output){
                 output <- generate_server_object(input, output, config.%s, '%s', pkgs = c(%s))
}", instant_tool, instant_tool, instant_tool,
                 sprintf("'%s'", paste0(pkgs, collapse = "', '")))
  eval(parse(text = cmd))
}
