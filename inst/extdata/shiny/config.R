source("global_var.R", encoding = "UTF-8")
# initial upload_table in sqlite database

if (db_type == "sqlite") {
  con <- DBI::dbConnect(RSQLite::SQLite(), db_path)
  if (!upload_table %in% DBI::dbListTables(con)) {
    sql <- system.file("extdata", "sql/upload_table.sql", package = "BioInstaller")
    statements <- paste0(readLines(sql), collapse = '\n')
    annovarR::sql2sqlite(statements = statements, dbname = db_path)
  }
  if (!task_table %in% DBI::dbListTables(con)) {
    sql <- system.file("extdata", "sql/task_table.sql", package = "BioInstaller")
    statements <- paste0(readLines(sql), collapse = '\n')
    annovarR::sql2sqlite(statements = statements, dbname = db_path)
  }
  if (!output_file_table_name %in% DBI::dbListTables(con)) {
    sql <- system.file("extdata", "sql/output_file_table.sql", package = "BioInstaller")
    statements <- paste0(readLines(sql), collapse = '\n')
    annovarR::sql2sqlite(statements = statements, dbname = db_path)
  }
  DBI::dbDisconnect(con)
}
addResourcePath('output', shiny_output_dir)
addResourcePath('upload', upload_dir)
update_configuration_files()


