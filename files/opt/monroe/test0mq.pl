#!/usr/bin/perl
# 0MQ Hello World client
# g0, 2016

use strict;
use warnings;
use v5.10;

use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_REQ);

say "Connecting to 0mqlsrv.pl in your host.";
my $context = ZMQ::FFI->new();
my $requestor = $context->socket(ZMQ_REQ);
$requestor->connect("tcp://172.17.0.1:5555");

my $message = 'nada';
my $count=0;

for my $request_nbr (0..9) {
  $count++;
  say "Sending il $count ...";
  $requestor->send("il $count");
  $message = $requestor->recv();
  say "Received $message";
}


my $last = 'more than cats buddy!';
say "Sending $last ...";
$requestor->send("$count, $last");
$message = $requestor->recv();
say "Received $message";

exit 0;
