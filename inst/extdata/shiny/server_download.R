source("config.R")

download_section_server <- function(input, output) {

  observeEvent(input$install_run, {
    req(input$item.name)
    req(input$download.version)

      if (input$download.dir == "") {
        download.dir <- input$download.dir.parent
      } else {
        download.dir <- input$download.dir
      }
      version <- input$download.version
      if (any(input$download.version == "")) {
        index <- input$download.version == ""
        version[index] <- BioInstaller::install.bioinfo(name = input$item.name[index],
                                                                   show.all.versions = TRUE)[1]
        input$download.version <- version
      }

      if (any(input$item.name != "")) {
        extra.params <- clean_parsed_item(input$extra.paramters, FALSE)
        extra.params <- eval(parse(text = extra.params))
        if ("extra.list" %in% extra.params){
          print(input$download.buildver)
          extra.params$extra.list <- config.list.merge(extra.params$extra.list,
                                                       list(buildber = input$download.buildver))
        } else {extra.params$extra.list <- list(buildver = input$download.buildver)}
        for(i in input$download.logical) {extra.params <- config.list.merge(extra.params,
                                                            eval(parse(text = sprintf('list(%s=TRUE)', i))))}
        params <- list(name = input$item.name, download.dir = download.dir,
                       verbose = TRUE, version = version)
        params <- config.list.merge(params, extra.params)
        progress <- shiny::Progress$new()
        for (i in 1:100) progress$set(message = "Submitting task...",
                                      value = i/100)
        Sys.sleep(2)
        on.exit(progress$close())
        params$req_pkgs <- "BioInstaller"
        params$qqcommand <- "BioInstaller::install.bioinfo"
        params$qqkey <- stringi::stri_rand_strings(1, 50)
        params$qqcommand_type <- "R"
        submit_task_modal(input, output, params)
      }
  })
  observeEvent(input$item.name, {
    output$download.version.selector <- shiny::renderUI({
      selectInput("download.version", "Version of item",
                  choices = BioInstaller::install.bioinfo(input$item.name, show.all.versions = TRUE), multiple = TRUE)
    })
    output$download.dir.parent.input <- shiny::renderUI({
      textInput("download.dir.parent", "Download directory (Hints)", value = config$shiny_download$download_dir)
    })
    output$download.dir.input <- shiny::renderUI({
      req(input$download.dir.parent)
      selectInput("download.dir", "Download directory", choices =
                  normalizePath(list.dirs(path = input$download.dir.parent, full.names = TRUE)), selectize = TRUE)
    })
  })

  observeEvent(input$download.version, {
    output$download.buildver.selector <- shiny::renderUI({
      textInput("download.buildver", "Buildver version (Database needed, e.g. hg19, hg38)",
                  value = "hg19")
    })
  })


  output$conda_installer_ui <- renderUI({
    conda_envs <- BioInstaller::conda.env.list()
    if (is.data.frame(conda_envs)) conda_envs <- conda_envs[,1]
    HTML(
    paste0(shiny::selectInput("installer_conda_sub_command", "Conda subcommands",
                       c("clean", "config", "create",
                         "info", "install",
                         "list", "package",
                         "remove", "uninstall",
                         "search", "update", "upgrade"),
                       selected = "list"),
    shiny::selectInput("installer_conda_env_name", label = "Conda environment",
                       choices = conda_envs,
                       selected = "base"),
    shiny::textAreaInput("installer_conda_parameters", label = "Conda parameters"),
    actionButton("installer_conda_run", label = "Submit")
    ), collapse = "\n")
  })

  output$spack_installer_ui <- renderUI({
    conda_envs <- BioInstaller::conda.env.list()
    if (is.data.frame(conda_envs)) conda_envs <- conda_envs[,1]
    HTML(
      paste0(shiny::selectInput("installer_spack_sub_command", "Sub command of spack",
                                c("list", "info", "find",
                                  "install", "uninstall",
                                  "spec", "load",
                                  "module", "unload",
                                  "view", "create", "edit",
                                  "arch", "compilers"),
                                selected = "find"),
             shiny::textAreaInput("installer_spack_parameters", label = "Parameters"),
             actionButton("installer_spack_run", label = "Submit")
      ), collapse = "\n")
  })

  observeEvent(input$installer_conda_run, {
    params <- list()
    params$req_pkgs <- "BioInstaller"
    params$qqcommand <- "BioInstaller::conda"
    params$qqkey <- stringi::stri_rand_strings(1, 50)
    params$qqcommand_type <- "R"
    params$prefix_params <- sprintf("source activate %s;", input$installer_conda_env_name)
    params$suffix_params <- sprintf("%s %s", input$installer_conda_sub_command,
                                    input$installer_conda_parameters)
    submit_task_modal(input, output, params)
  })

  observeEvent(input$installer_spack_run, {
    params <- list()
    params$req_pkgs <- "BioInstaller"
    params$qqcommand <- "BioInstaller::spack"
    params$qqkey <- stringi::stri_rand_strings(1, 50)
    params$qqcommand_type <- "R"
    params$suffix_params <- sprintf("%s %s", input$installer_spack_sub_command,
                                    input$installer_spack_parameters)
    submit_task_modal(input, output, params)
  })

  return(output)
}
