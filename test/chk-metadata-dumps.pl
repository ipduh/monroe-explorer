#!/usr/bin/perl
# g0, 2016

=head1 Description
  Check metadata dumps by looking at sequence numbers.
  First argument is the dump file.
  Optional: Use 'v' as the second argument to print missing sequence numbers.
  e.g. $ chk-metadata-dump.pl dump.txt v
=cut

=head1 Author
  g0, github@bot.ipduh.com
=cut

use strict;
use v5.10;

if(scalar @ARGV < 1){
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

my @missing_seq_nums = ();
my $longer_missing_range = 0;
my @longer_missing_range = ();
my $pop_missing_range = 0;
my $index = 0;
for(@sorted_seq){
  last if($_ == $sorted_seq[$#sorted_seq]);
  if(($sorted_seq[$index+1] - $_) != 1){
    my $missing_range = $sorted_seq[$index+1] - $_;
    if($missing_range > $longer_missing_range){
      $longer_missing_range = $missing_range;
      @longer_missing_range = ();
      $pop_missing_range = 1;
    }else{
      $pop_missing_range = 0;
    }
    for my $j (($_+1)..($_ + $missing_range -1)){
      push(@missing_seq_nums, $j);
      push(@longer_missing_range, $j) if($pop_missing_range);
    }

  }
  $index++;
}

if($ARGV[1] eq 'v'){
  say "\nMissing Sequence Numbers:";
  print "$_\n" for(@missing_seq_nums);
  say '';
  say "\nLonger Missing Range:";
  print "$_\n" for(@longer_missing_range);
}


say     '';
say     'Messages                        : '. "\t" . scalar(@sorted_seq);
say     'Missing Messages                : '. "\t" . ($sorted_seq[$#sorted_seq] - $sorted_seq[0] - scalar(@sorted_seq));
print   'Missing Messages %              : '. "\t" ;
printf  ("%.2f", (100 * (($sorted_seq[$#sorted_seq] - $sorted_seq[0] - scalar(@sorted_seq)) / scalar(@sorted_seq))));
say     '%';
say     'Longer Missing Range of SeqNums : '. "\t" . ($longer_missing_range-1);
say     '';
