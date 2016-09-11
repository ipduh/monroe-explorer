


## build.sh
Pulls a docker image (monroe/base by default) from the docker hub,
creates your .docker file,
builds your docker image
and writes helper scripts to ease the testing and pushing of your image.

Helper Scripts:
  run.sh    : run the docker image
  start.sh  : start and get console to the docker image
  push.sh   : push the docker image to your docker hub repository

Aims at easing the build of docker images to be deployed in the MONROE testbed.
Fights carpal tunnel syndrome and other nasty repetitive stress injuries.


## monroe-explorer.pl
A little piece of software that logs system and network setup
and runs a few network probes for numbers and names set in its config, viz:
traceroute, traceroute over TCP 80, httping, DNS lookups
along with logging your public IP address, checking if HTTP is proxied
and if your local caching DNS answers the same way with some open Internet caching DNS service.
It was written while I was getting acquainted with the Monroe testbed.
