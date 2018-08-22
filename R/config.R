#' Create new BioInstaller items to github forum
#' @param config.file github.toml, nongithub.toml, db_annovar.toml, db_main.toml, or new
#' @param title Name of new item
#' @param description Description of new item
#' @param publication Publication of new item
#' @export
#' @examples
#' new.bioinfo('db_main.toml', 'test_item', 'Just is a test item', 'NA')
new.bioinfo <- function(config.file = "github.toml", title = "", description = "", 
  publication = "") {
  text <- sprintf("**Configuration file**:%s\n**title**:%s\n**description**:%s\n**publication**:%s\n", 
    config.file, title, description, publication)
  cat(text)
}
