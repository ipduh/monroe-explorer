##monroe-explorer
```
	README.md
	added_bytes.pl
	build.sh
	mdnator.pl
	files/opt/monroe/monroe-explorer/monroe-explorer.conf
	files/opt/monroe/monroe-explorer/monroe-explorer.pl
	files/opt/monroe/test/0mq-test-1.pl
	files/opt/monroe/test/0mq-test.pl
	files/opt/monroe/test/metadata-collector.pl
	files/opt/monroe/test/metadata-subscriber.pl
	files/opt/monroe/test/metadata-subscriber.py
	files/preferences
	files/vimrc
	test/0mq-tinysrv.pl
	test/chk-metadata-dumps.pl
	test/data/1229.1474360673-1474362473.metadata.dump
	test/data/1231.1474360708-1474362508.metadata.dump
	test/data/1474284722-1474285322.metadata.dump
	test/data/63047.1474359893-1474361693.metadata.dump
	test/data/63047.1474360295-1474362095.metadata.dump
	test/data/metadata-00.dump
	test/metadata-publisher.py
```

## added_bytes.pl
```
Description
  Used to find the diff in Bytes of two docker images
  e.g. monroe-explorer and it's base image (monroe/base)
Usage
  Run with no arguments to get docker image names from build.sh
  or
  pass explicitly the two images to compare
  e.g. $ added_bytes monroe-explorer monroe/base
Author
  g0, 2016 <github@bot.ipduh.com>
```

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
      Logs
        container system and network info and setup,
        and the container's public IP address(es)
        without relying on the MONROE 'Metadata'.

      Runs and logs output of
        network probes for numbers and names set in its config, viz:
        traceroute, traceroute over TCP 80, httping, and DNS lookups.

      Performs various checks, i.e.;
        checks if HTTP is proxied
        checks if your caching DNS answers the same way with some open Internet caching DNS service.

      Subscribes to a Monroe Metadata Publisher
        and collects metadata for COLLECT_METADATA_FOR seconds asynchronously.

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
  A  OMQ client;
  test OMQ in the container
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
 Collect MONROE metadata for $ttl in seconds.
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
  To configure;
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
  Run without arguments in the root directory of your repository.
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
