#!/usr/bin/perl
# 0MQ hello-server
# g0, 2016


=head1 Description
  A tiny 0MQ REP server.
  Motivation: Test if Perl-ZMQ-FFI works OK in the docker container.

=cut

=head1 Usage
  Edit CONFIG stanza in source and run without arguments.
  e.g. $ 0mq-tinysrv.pl
  or
  Pass IP_address and Port_number in the command line
  e.g. $ 0mq-tinysrv.pl 172.17.0.1 5555

=cut

=head1 Author
  g0, 2016, github@bot.ipduh.com

=cut

use strict;
#use warnings;
use v5.10;

use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_REP);

# CONFIG
my $ip = '*';
my $port = '5555';
# CONFIG IS DONE


if(scalar(@ARGV) > 0){
  if($ARGV[0] =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/ && $1<256 && $2<256 && $3<256 && $4<256){
    $ip = $ARGV[0];
  }
  if($#ARGV > 0 && $ARGV[1] > 0 && $ARGV[1] < 65536){
    $port = $ARGV[1];
  }
}

my $context = ZMQ::FFI->new();
my $responder = $context->socket(ZMQ_REP);
$responder->bind("tcp://$ip:$port");
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
