#!/usr/bin/perl
# 0MQ subscriber
# g0, 2016

use strict;
use v5.10;
use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_SUB);

# CONFIG
my $ip = '172.17.0.1';
my $port = '5556';
my $topic = '';
#

my $topic_description = 'no_topic_description';
if($topic eq ''){
  $topic_description = 'all topics';
}else{
  $topic_description = $topic;
}

if(scalar(@ARGV) > 0){
  if($ARGV[0] =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/ && $1<256 && $2<256 && $3<256 && $4<256){
    $ip = $ARGV[0];
  }
  if($#ARGV > 0 && $ARGV[1] > 0 && $ARGV[1] < 65536){
    $port = $ARGV[1];
  }
}

say "Subscribing to \" $topic_description \" @ tcp://$ip:$port";
my $context = ZMQ::FFI->new();
my $subscriber = $context->socket(ZMQ_SUB);
$subscriber->connect("tcp://$ip:$port");
$subscriber->subscribe($topic);

my $received_message = 'tipota';
my @received_message = ();

while(1){
    $received_message = $subscriber->recv();
    @received_message = split(' ', $received_message, 2);
    say "topic: $received_message[0]";
    say "message: $received_message[1]";
    say '';
}
