docker.bin <- unname(Sys.which('docker'))
if (docker.bin != '') {
  docker.pull(repo = 'learn', versiono = 'tutorial')
  docker.search('bwa')
}
