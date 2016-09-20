#!/usr/bin/perl
# yet another hello-world 0MQ client
# g0, 2016

=head1 Description
  A multi-threaded OMQ client

=cut

=head1 Usage
  Edit CONFIG stanza in source
  or
  pass IP_addr and Port_num in the command line

=cut

=head1 Author
  g0, 2016, github@bot.ipduh.com

=cut

use threads qw(stringify);
use threads::shared;
use v5.10;
use strict;
use warnings;
use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_REQ);
use Term::ANSIColor;

# CONFIG
my $ip = '172.17.0.1';
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
  say "CID: $num, attempting to connect to tcp://$ip:$port .";

  my $context = ZMQ::FFI->new();
  my $requestor = $context->socket(ZMQ_REQ);
  $requestor->connect("tcp://$ip:$port");

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


  print color('red') if(keys %conversations != ($THREADS*$SAYS));
  say "\n\n Jabbers in shared_mem: ", scalar(keys %conversations);
  say " $_ -> $conversations{$_}" for(keys %conversations);
  print color('reset') if(keys %conversations != ($THREADS*$SAYS));

  print color('red') if(scalar(@results) != ($THREADS*$SAYS));
  say "\n\n Jabbers returned from threads: " , scalar(@results);
  say "$_ " for(@results);
  print color('reset') if(scalar(@results) != ($THREADS*$SAYS));
  say '';
}

multi($THREADS, $SAYS);

say "\nglobal_count: $global_count";
print "sum of in_shared_mem_jabbers: ", scalar(keys %conversations), "\n";
print "sum of jabbers returned from threads: ", scalar(@results), "\n";

say "chao";

exit 0;
