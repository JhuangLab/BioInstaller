pkgs.shiny <- c("shinycssloaders", "Cairo", "shinydashboard", "configr",
                "data.table", "shinyjs", "liteq", "DT", "benchmarkme",
                "stringr", "R.utils", "shiny", "RSQLite")
tryCatch({if (!requireNamespace("pacman")) install.packages("pacman")}, warning = function(w) {
  if (!requireNamespace("devtools"))
    install.packages("devtools")
  devtools::install_url("https://cran.r-project.org/src/contrib/Archive/pacman/pacman_0.4.6.tar.gz")
})
text <- sprintf("pacman::p_load(%s)", pkgs.shiny)
eval(parse(text = text))
