
## build.sh
```

Run build.sh without arguments.
To Configure see first CONFIG section in source.

Aims at easing the build of docker images to be deployed in the MONROE testbed.
Fights carpal tunnel syndrome and other nasty repetitive stress injuries.

Pulls a docker image from the docker hub and extends it.
Creates the container .docker file.
Builds the docker image.
Writes helper scripts that ease local testing and pushing to a repository.

Helper Scripts:
  run.sh    : Run the docker container
              and get hints that may help you to set;
              Duration, Active-data-quota and Log-files-quota
              for your experiment.

  start.sh  : Start and get console into the container.

  push.sh   : Push the docker image to your docker hub repository.



Author:
  g0, 2016, github@bot.ipduh.com


```

## monroe-explorer.pl
```
Description
  Logs system and network setup.
      Runs network probes for numbers and names set in its config, viz:
      traceroute, traceroute over TCP 80, httping, and DNS lookups.

      Logs your public IP address, checks if HTTP is proxied
      and if your local caching DNS answers the same way with some open Internet caching DNS service.

Usage
  Run monroe-explorer.pl without arguments.
  Edit monroe-explorer.conf to configure.
Author
  g0, 2016, github@bot.ipduh.com
```

## 0mq-test-1.pl
```
Description
  A multi-threaded OMQ client
Usage
  Edit CONFIG stanza in source
  or
  pass IP_addr and Port_num in the command line
Author
  g0, 2016, github@bot.ipduh.com
```

## 0mq-test.pl
```
Description
  A  OMQ client
  Test OMQ in the container
Usage
  Edit CONFIG stanza in source
  or
  pass IP_addr and Port_num in the command line
Author
  g0, 2016, github@bot.ipduh.com
```

## metadata-collector.pl
```
Description
 Collect MONROE metadata for $ttl in seconds
Usage
  You may pass ttl as the first argument in the command line.
  BUT Edit CONFIG stanza in source to configure for deployment in the MONROE testbed.
Author
  g0, github@bot.ipduh.com
```

## metadata-subscriber.pl
```
Description
  MONROE metadata subscriber
Usage
  To configure
    Edit config stanza in source
    or
    pass IP_address, Port, Topic and Duration as arguments in the command line
    e.g. $ metadata-subscriber.pl 172.17.0.1 5556 MONROE.META.DEVICE.MODEM 50
Author
 g0, github@bot.ipduh.com
```

## metadata-subscriber.py
```
  Simple Metadata Subscriber

  g0, 2016, github@bot.ipduh.com
```

## mdnator.pl
```
Description
  Create README.md for this repository
Usage
  Run without arguments in your repository root directory.
Author
  g0, github@bot.ipduh.com
```

## 0mq-tinysrv.pl
```
Description
  A tiny 0MQ REP server.
  Motivation: Test if Perl-ZMQ-FFI works OK in the docker container.
Usage
  Edit CONFIG stanza in source and run without arguments.
  e.g. $ 0mq-tinysrv.pl
  or
  Pass IP_address and Port_number in the command line
  e.g. $ 0mq-tinysrv.pl 172.17.0.1 5555
Author
  g0, 2016, github@bot.ipduh.com
```

## chk-metadata-dumps.pl
```
Description
  Check metadata dumps by looking at sequence numbers.
Usage
  First argument is the dump file.
  Optional: Use 'v' as the second argument to print missing sequence numbers.
  e.g. $ chk-metadata-dump.pl dump.txt v
Author
  g0, github@bot.ipduh.com
```

## metadata-publisher.py
```

Simulates a MONROE Metadata Publisher in local tests.
Publishes a metadata dump.

To configure edit CONFIG stanza in source.
Much stolen from https://github.com/MONROE-PROJECT/Experiments/commit/d0a0328d22c14f9bb4a1f3771640742f9c706e1d#diff-e8a15385974eaf4e3c3f0118638eaaca

Author: g0, 2016, github@bot.ipduh.com

```
