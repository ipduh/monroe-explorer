#!/usr/bin/perl
# 0MQ Hello World client
# g0, 2016

use strict;
use warnings;
use v5.10;
use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_REQ);

my $ip = '172.17.0.1';
my $port = '5555';

if(scalar(@ARGV) > 0){
  if($ARGV[0] =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/ && $1<256 && $2<256 && $3<256 && $4<256){
    $ip = $ARGV[0];
  }
  if($#ARGV > 0 && $ARGV[1] > 0 && $ARGV[1] < 65536){
    $port = $ARGV[1];
  }
}


say "Connecting to tcp://$ip:$port ";
my $context = ZMQ::FFI->new();
my $requestor = $context->socket(ZMQ_REQ);
$requestor->connect("tcp://$ip:$port");

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
