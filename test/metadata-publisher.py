#!/usr/bin/python
# -*- coding: utf-8 -*-
# g0, 2016
# Much stolen from https://github.com/MONROE-PROJECT/Experiments/commit/d0a0328d22c14f9bb4a1f3771640742f9c706e1d#diff-e8a15385974eaf4e3c3f0118638eaaca

"""
MONROE Metadata Publisher Simulator
--Publish a metadata dump.
"""

from os import stat, path
import zmq
import time
import sys
import json

# CONFIG
FILENAME = "data/metada-00.dump"
TIMESCALE = 1.0
MYIP = '172.17.0.1'
MYPORT = '5556'
#

if not path.isfile(FILENAME):
    raise Exception("Data file {} does not exist".format(FILENAME))

if stat(FILENAME).st_size == 0:
    raise Exception("{} is empty".format(FILENAME))

try:
    context = zmq.Context()
    socket = context.socket(zmq.PUB)
    print "I am attempting to bind on tcp://{}:{}".format(MYIP, MYPORT)
    socket.bind("tcp://{}:{}".format(MYIP, MYPORT))
except Exception as e:
    print "I was unable to create a ZMQ PUB Socket : {}".format(e)
    print "Bye."
    sys.exit(1)

print "I am listening-publishing on tcp://{}:{}".format(MYIP, MYPORT)

SEQCOUNTER = 0

while True:
    try:
        with open(FILENAME, 'r') as f:
            for line in f:
                topic, msgstr = line.split(" ", 1)

                msg = json.loads(msgstr)

                if SEQCOUNTER == 0:
                    last_ts = msg["Timestamp"]

                wait = msg["Timestamp"] - last_ts
                if wait > 0:
                    time.sleep(wait/TIMESCALE)

                last_ts = msg["Timestamp"]

                msg["SequenceNumber"] = SEQCOUNTER
                SEQCOUNTER += 1
                msg["Timestamp"] = int(time.time())

                zmqstr = "{} {}".format(topic, json.dumps(msg))
                print "topic: " + topic
                print "message: " + json.dumps(msg) +"\n"
                socket.send(zmqstr)

    except Exception as e:
        print "{}".format(e)
