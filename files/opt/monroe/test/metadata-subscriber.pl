#!/usr/bin/perl
# g0, 2016

=head1 Description
  MONROE metadata subscriber

=cut

=head1 Usage
  To configure
    Edit config stanza in source
    or
    pass IP_address, Port, Topic and Duration as arguments in the command line
    e.g. $ metadata-subscriber.pl 172.17.0.1 5556 MONROE.META.DEVICE.MODEM 50

=cut

=head1 Author
 g0, github@bot.ipduh.com
=cut

use strict;
use v5.10;
use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_SUB);

# CONFIG
my $ip = '172.17.0.1';
my $port = '5556';
my $topic = '';

# Set to 'until_sigint' or the duration time in seconds
my $duration = 'until_sigint';

# CONFIG IS DONE


if(scalar(@ARGV) > 0){
  if($ARGV[0] =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/ && $1<256 && $2<256 && $3<256 && $4<256){
    $ip = $ARGV[0];
  }
  if($#ARGV > 0 && $ARGV[1] > 0 && $ARGV[1] < 65536){
    $port = $ARGV[1];
  }
  if($#ARGV > 1 ){
    $topic = $ARGV[2];
  }
  if($#ARGV > 2 ){
    $duration = $ARGV[3];
  }
}

my $start = time;
my $expr = "";

if($duration ne 'until_sigint' && $duration =~ /^\d+$/){
  $expr = "(time - $start) <= $duration";
}else{
  $expr = 1;
}
my $topic_description = 'no_topic_description';
if($topic eq ''){
  $topic_description = 'all topics';
}else{
  $topic_description = $topic;
}

say "Subscribing to \" $topic_description \" @ tcp://$ip:$port";
my $context = ZMQ::FFI->new();
my $subscriber = $context->socket(ZMQ_SUB);
$subscriber->connect("tcp://$ip:$port");
$subscriber->subscribe($topic);

my $received_message = 'tipota';
my @received_message = ();

while(eval $expr){
    $received_message = $subscriber->recv();
    @received_message = split(' ', $received_message, 2);
    say "topic: $received_message[0]";
    say "message: $received_message[1]";
    say '';
}

say 'bye bye';
exit 0;
