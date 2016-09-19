#!/usr/bin/perl
# g0, 2016

=head1 Description
 Collect MONROE metadata for $ttl in seconds
 Configure @ # CONFIG stanza

=cut

=head1 Author
  g0, github@bot.ipduh.com

=cut

use strict;
use ZMQ::FFI;
use ZMQ::FFI::Constants qw(ZMQ_SUB);

my $start = time;

# CONFIG
my $ip = '172.17.0.1';
my $port = '5556';
my $topic = '';
my $ttl = $ARGV[0] or 600;
my $dump_is_at = "/monroe/results/$start-". ($start+$ttl) .'.metadata.dump';
#

my @dump = ();

my $context = ZMQ::FFI->new();
my $subscriber = $context->socket(ZMQ_SUB);
$subscriber->connect("tcp://$ip:$port");
$subscriber->subscribe($topic);

my $received_message = 'tipota';

while((time - $start) <= $ttl){
    $received_message = $subscriber->recv();
    push(@dump, $received_message);
}

unless(open(DUMP, '>', $dump_is_at)){
  system("touch /monroe/results/$0-cannot-write-dump");
  die $!;
}
print DUMP "$_\n" for(@dump);
close(DUMP);

exit 0;
