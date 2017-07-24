docker.bin <- unname(Sys.which('docker'))
if (docker.bin != '') {
  docker.pull(repo = 'learn', name = 'tutorial')
  docker.search('bwa')
}
