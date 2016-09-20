#!/usr/bin/python
# -*- coding: utf-8 -*-
# g0 ,2016

"""
  Simple Metadata Subscriber

  g0, 2016, github@bot.ipduh.com
"""

import zmq

# CONFIG

MYIP = '172.17.0.1'
MYPORT = '5556'

# Suscribe to all topics with ''
topic = ''

# CONFIG IS DONE

context = zmq.Context()
socket = context.socket(zmq.SUB)
socket.connect("tcp://{}:{}".format(MYIP, MYPORT))
socket.setsockopt(zmq.SUBSCRIBE, topic)

while True:
    topic, msgstr = socket.recv().split(" ", 1)
    print 'topic: ' + topic
    print 'message:' + msgstr + "\n"
