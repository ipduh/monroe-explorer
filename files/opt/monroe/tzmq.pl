#!/usr/bin/perl
# yet another hello-world 0MQ client
# g0, 2016

use threads qw(stringify);
use threads::shared;
use v5.10;
use strict;
use warnings;
use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_REQ);
use Term::ANSIColor;

my $srvsocket='tcp://172.17.0.1:5555';
my @threads = ();
my @results = ();
my %conversations :shared = ();
my $global_count :shared = 0;

my $THREADS = 3;
my $SAYS = 10;

sub talktosrv
{
  my ($num, $reps) = @_;
  my $message = 'niente';
  my $received_message = 'niente';
  my @jabbers = ();
  say "CID: $num, attempting to connect to 0mqlsrv.pl ($srvsocket) in your host.";

  my $context = ZMQ::FFI->new();
  my $requestor = $context->socket(ZMQ_REQ);
  $requestor->connect($srvsocket);

  for my $count (1..($reps-1)) {
    $global_count++;
    say "$global_count";
    $message = "CID:$num:Il $count:$global_count";
    print "Sending $message ..";
    $requestor->send("$message");
    say '.';
    $received_message = $requestor->recv();
    say "Received $received_message";
    $conversations{$global_count} = "$message -> $received_message";
    push(@jabbers, " $message -> $received_message");
  }

  if($reps > 9){
    $global_count++;
    $message = "CID:$num:Il more than cats buddy!:$global_count";
    print "Sending $message ..";
    $requestor->send("$message");
    say '.';
    $received_message = $requestor->recv();
    say "Received $received_message";
    $conversations{$global_count} = "$message -> $received_message";
    push(@jabbers, " $message -> $received_message");
  }

  #return $num;
  return @jabbers;
}

sub multi
{
  my ($cnum, $reps) = @_;
  say "$cnum threads, $reps repetitions";

  for(my $i=1; $i<=$cnum; $i++){
    my $t = threads->create({'context' => 'list'}, \&talktosrv, $i, $reps);
    say "CID $i ", $t->tid(), " is a go." if($t);

    #nope
    #my $tr = $t->join();
    #say "CID: $tr .";

    push(@threads,$t);
  }

  for(@threads){
    #$nt = $_->join;
    if(my $err = $_->error()){ warn("$_->tid thread error:$err\n"); }
    push(@results, $_->join);
    #say "CID $nt is done.";
  }

#  for(@threads){
#    while($_->is_running()){
#      sleep 1;
#    }
#  }


  print color('red') if(keys %conversations != ($THREADS*$SAYS));
  say "\n\n Jabbers: ", scalar(keys %conversations);
  say " $_ -> $conversations{$_}" for(keys %conversations);
  print color('reset') if(keys %conversations != ($THREADS*$SAYS));

  print color('red') if(scalar(@results) != ($THREADS*$SAYS));
  say "\n\n results:" , scalar(@results);
  say "$_ " for(@results);
  print color('reset') if(scalar(@results) != ($THREADS*$SAYS));
  say '';
}

multi($THREADS, $SAYS);

say "\nglobal_count: $global_count";
print "sum of in_shared_mem_jabbers: ", scalar(keys %conversations), "\n";
print "sum of jabbers returned by threads: ", scalar(@results), "\n";

say "chao";

exit 0;
