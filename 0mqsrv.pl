#!/usr/bin/perl
# Hello World server in Perl
# g0, 2016

use strict;
use warnings;
use v5.10;

use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_REP);

# Socket to talk to clients
my $context = ZMQ::FFI->new();
my $responder = $context->socket(ZMQ_REP);
$responder->bind("tcp://*:5555");

my $received_message = 'nada';

while (1) {
    $received_message = $responder->recv();
    say "Received $received_message";
    sleep 1;
    $responder->send("Indeed");
}
