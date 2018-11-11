# source UI required code config.R sourced in the body_upload_ui.R
files <- list.files(".", "^ui_")
files <- c("deps.R", files, "config.R")
for (i in files) {
  source(i, encoding = "UTF-8")
}

get_tabItems <- function () {
  source("config.R")
  items <- c("introduction", "dashbord",
             "file_viewer",
             "upload", "download", "setting")
  body_items <- sprintf("get_%s_tabItem_ui()", items)
  items_auto <- c("pipeline", "instant")
  body_items <- c(body_items, sprintf("get_tabItem_ui('%s')", items_auto))
  cmd <- sprintf("tabItems(%s)", paste0(body_items, collapse = ", "))
  eval(parse(text = cmd))
}

header <- dashboardHeader(title = "BioInstaller Shiny APP", messages, notifications,
  tasks)

sidebar <- dashboardSidebar(
  sidebarSearchForm(label = "Search...", "searchText", "searchButton"),
  sidebarMenu(id = "navbar_tabs",
    menuItem("Introduction", tabName = "introduction", icon = icon("home")),
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    menuItem("Upload", tabName = "upload", icon = icon("cloud-upload")),
    menuItem("File Viewer", tabName = "file_viewer", icon = icon("file")),
    menuItem("Pipeline", tabName = "pipeline", icon = icon("diamond")),
    menuItem("Instant", tabName = "instant", icon = icon("delicious")),
    menuItem("Installer", icon = icon("cloud-download"), tabName = "download"),
    menuItem("Setting", icon = icon("gears"), tabName = "setting"),
    menuItem("Source code for app", icon = icon("file-code-o"),
             href = "https://github.com/JhuangLab/BioInstaller/blob/master/inst/extdata/shiny/app.R")
  )
)

set_extend_shinyjs <- function (id) {
  js_code <- sprintf('shinyjs.get_%s_input = function(params) {
      var input_value = %s_editor.getValue();
  Shiny.onInputChange("%s_input_value", input_value);
}', id, id, id)
}

extend_js_objs <- list()
for(tool in c(config$shiny_tools$pipeline, config$shiny_tools$instant)){
  if (!tool == "setting_yaml"){
    config.tool <- get(sprintf("config.%s", tool))
    id <- sprintf("lastcmd_%s_%s", names(config.tool),
                  names(config.tool[[tool]]$paramters))
  }
  json_code <- set_extend_shinyjs(id)
  extend_js_objs <- config.list.merge(
    extend_js_objs, list(extendShinyjs(text = json_code, functions = sprintf("get_%s_input", id))))
}

body <- dashboardBody(
  shinyjs::useShinyjs(),
  extendShinyjs(text = set_extend_shinyjs("setting_yaml"),
                functions = sprintf("get_setting_yaml_input", id)),
  extend_js_objs,
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "codemirror/lib/codemirror.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "codemirror/addon/dialog/dialog.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "codemirror/theme/monokai.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "codemirror/addon/fold/foldgutter.css"),
    tags$script(type = "text/javascript", src = "codemirror/lib/codemirror.js"),
    tags$script(type = "text/javascript", src = "codemirror/addon/search/search.js"),
    tags$script(type = "text/javascript", src = "codemirror/addon/search/searchcursor.js"),
    tags$script(type = "text/javascript", src = "codemirror/addon/search/jump-to-line.js"),
    tags$script(type = "text/javascript", src = "codemirror/addon/dialog/dialog.js"),
    tags$script(type = "text/javascript", src = "codemirror/keymap/sublime.js"),
    tags$script(type = "text/javascript", src = "codemirror/addon/fold/foldcode.js"),
    tags$script(type = "text/javascript", src = "codemirror/addon/fold/brace-fold.js"),
    tags$script(type = "text/javascript", src = "codemirror/mode/yaml/yaml.js"),
    tags$script(type = "text/javascript", src = "codemirror/mode/r/r.js"),
    tags$script(type = "text/javascript", src = "custom.js")
    ),
  shiny::uiOutput("task_submit_modal"),
  shiny::actionButton("dashbord_auto_update", label = "dashbord_auto_update",
                        style = "display:none;"),
  get_tabItems()
)

# Defined shiny UI
ui <- dashboardPage(header, sidebar, body, skin = skin)

server <- function(input, output, session) {
  files <- c("server_utils.R", "server_download.R", "server_upload_file.R", "server_dashbord.R")
  for (i in files) {
    source(i, encoding = "UTF-8")
  }
  output <- render_input_box_ui(input, output)
  for(tool in unlist(shiny_tools_list)) {
    eval(parse(text = sprintf('output <- %s_server(input, output)', tool)))
  }
  output <- setting_server(input, output)
  out <- server_upload_file(input, output, session)
  output <- out$output
  session <- out$session
  output <- dashbord_section_server(input, output)
  observeEvent(input$dashbord_auto_update, {
    last_update_time <- Sys.getenv('last_dashbord_update_time')
    if (last_update_time == "") {
      last_update_time <- Sys.time()
      output <- update_system_monitor(input, output)
    } else if (as.numeric(Sys.time() - last_update_time) >= 10) {
      output <- update_system_monitor(input, output)
    }
  })
  output <- download_section_server(input, output)
}
shinyApp(ui, server)
