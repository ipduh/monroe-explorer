#!/usr/bin/perl
# 0MQ hello-server
# g0, 2016

use strict;
use warnings;
use v5.10;

use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_REP);

my $context = ZMQ::FFI->new();
my $responder = $context->socket(ZMQ_REP);
$responder->bind("tcp://*:5555");
my $received_message = 'nada';
my $message = 'nada';
my @received_message = ();

while(1){
  $received_message = $responder->recv();
  say "Received $received_message.";
  @received_message = split(':', $received_message);
  $message = "Indeed $received_message[1].";
  #$responder->send($message) if($#received_message > 0);
  $responder->send($message);
  say "Sent $message";
  sleep 1;
}
