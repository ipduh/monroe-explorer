


## build.sh
```
Pulls a docker image (monroe/base by default) from the docker hub,
creates a .docker file,
builds a docker image
and writes helper scripts to ease testing and pushing of a docker container.

Helper Scripts:
  run.sh    : Run the docker container.
  start.sh  : Start and get console to the docker container.
  push.sh   : Push a docker container to a docker hub repository.

Aims at easing the build and testing of experiments to be deployed in the MONROE testbed.
Fights carpal tunnel syndrome and other nasty repetitive stress injuries.
```

## monroe-explorer.pl
```
A piece of software that logs system and network setup
and runs network probes for numbers and names set in its config, viz:
traceroute, traceroute over TCP 80, httping, and DNS lookups.
It also logs your public IP address(es), checks if HTTP is proxied
and if your local caching DNS answer the same way with some open Internet caching DNS service.
```
