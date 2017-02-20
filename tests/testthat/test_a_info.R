set.biosoftwares.db(sprintf('%s/.BioInstaller', tempdir()))

flog.info('Debug:change.info(name = "demo", installed = TRUE), debug = TRUE')
status <- change.info(name = "demo", installed = "yes", debug = TRUE)
print(status)

flog.info('Debug:get.info(name = "demo")')
status <- get.info(name = "demo")
print(status)

flog.info('Debug:del.info(name = "demo")')
status <- del.info(name = "demo")
print(status)

flog.info('Debug:show.installed()')
status <- show.installed()
print(status)
