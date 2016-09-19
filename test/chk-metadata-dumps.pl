#!/usr/bin/perl
# g0, 2016

=head1 Description
  Check metadata dumps by looking at sequence numbers

=cut


use strict;
use v5.10;

if(scalar @ARGV != 1){
  say 'Please give me a metadata-dump file';
  say "e.g. $0 data/1474284722-1474285322.metadata.dump";
  exit 1;
}

my @sequence_numbers = ();
my @tmp = ();

open(DUMP, '<' , $ARGV[0]) or die "I was unable to open $ARGV[0].\n$!";
  while(<DUMP>){
    @tmp = split('SequenceNumber":', $_ );
    @tmp = split(',', $tmp[1], 2);
    push(@sequence_numbers, $tmp[0]);
  }
close(DUMP);

my @sorted_seq = sort {$a <=> $b} @sequence_numbers;

say     'Messages          : '. "\t" . scalar(@sorted_seq);
say     'Missing Messages  : '. "\t" . ($sorted_seq[$#sorted_seq] - $sorted_seq[0] - scalar(@sorted_seq));
print   'Missing Messages %: '. "\t" ;
printf  ("%.2f", (($sorted_seq[$#sorted_seq] - $sorted_seq[0] - scalar(@sorted_seq)) / scalar(@sorted_seq)));
say     '%';
