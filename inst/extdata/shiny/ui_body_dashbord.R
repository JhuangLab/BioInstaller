featch_all_keys <- function() {
  con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
  sql <- sprintf("SELECT key from %s", task_table)
  result <- DBI::dbGetQuery(con, sql)
  DBI::dbDisconnect(con)
  return(result[,1])
}
get_dashbord_tabItem_ui <- function() {
  body_dashbord_tabItem <- tabItem("dashboard",
      fluidRow(
        box(
          title = "Status of system",
          width = 12,
          status = "primary",
          collapsible = TRUE,
          uiOutput("system_monitor")
          ),
        box(
          title = "Task table query",
          width = 12,
          status = "primary",
          collapsible = TRUE,
          collapsed = FALSE,
          textInput("task_table_key", "Key", value = task_table_admin_key),
          actionButton("task_table_button", "Query"),
          uiOutput("task_table_hr1"),
          DT::dataTableOutput("task_table_DT"),
          uiOutput("task_table_hr2"),
          DT::dataTableOutput("task_table_output_DT"),
          uiOutput("task_table_hr4"),
          DT::dataTableOutput("task_table_output_preview_DT"),
          uiOutput("task_table_hr3"),
          verbatimTextOutput("task_table_log"),
          actionButton("outfn_delete_confirmed", "", class = "btn btn-primary", style = "display:none")

        ),
        box(
          title = "Session info of R service",
          width = 12,
          status = "primary",
          collapsible = TRUE,
          collapsed = TRUE,
          withSpinner(verbatimTextOutput("r_session_info_monitor"), type = 8)
        ),
        box(
          title = "Installed packages of R service",
          width = 12,
          status = "primary",
          collapsible = TRUE,
          collapsed = TRUE,
          withSpinner(DT::dataTableOutput("r_packages_info_monitor"), type = 8)
        ),
        box(
          title = "Environment variables of R service",
          width = 12,
          status = "primary",
          collapsible = TRUE,
          collapsed = TRUE,
          withSpinner(DT::dataTableOutput("r_env_info_monitor"), type = 8)
        )
      )
  )
}
