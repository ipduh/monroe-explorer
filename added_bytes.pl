#!/usr/bin/perl
#g0, 2016

use strict;
use v5.10;
use Cwd;

my $pwd = getcwd;
my @dirs = split('/', $pwd);

my $BUILD_FILE = './build.sh';
my $DOCKER_IMAGE = $ARGV[0] || $dirs[$#dirs];
my $DOCKER_BASE_IMAGE = $ARGV[1] || base_image_name_from_build() ;

=head1 Description
  Used to find the diff in Bytes of two docker images
  e.g. monroe-explorer and it's base image (monroe/base)

=cut

=head1 Usage
  Run with no arguments to get docker image names from build.sh
  or
  pass explicitly the two images to compare
  e.g. $ added_bytes monroe-explorer monroe/base

=cut

=head1 Author
  g0, 2016 <github@bot.ipduh.com>

=cut

#Breaks if we add comments to the docker image
#my $MAINTAINER_TAG = $ARGV[1] || marktag();
#sub marktag
#{
#  open(BUILD, '<', $BUILD_FILE) or die "$0 could not open $BUILD_FILE\n $!";
#    for(<BUILD>){
#      if ($_ =~ /^MAINTAINER='.*/){
#        chomp;
#        my @maint = split("'", $_);
#        $maint[1] =~  s/'//;
#        close(BUILD);
#        return "MAINTAINER $maint[1]";
#      }
#    }
#  close(BUILD);
#
#  return undef;
#}
#
#my @intel = `docker history --no-trunc -H=false $DOCKER_IMAGE`;
#my $measure = 0;
#my $bytes = 0;
#
#for(reverse @intel){
#
#  chomp;
#
#  if($measure){
#
#    if($_ =~ /^.*\s+([\d]+)/ ){
#      $bytes += $1;
#      next;
#    }
#
#  }
#
#  next if($_ =~ /^IMAGE/);
#
#  $measure = 1 if($_ =~ /^.*$MAINTAINER_TAG/);
#
#}
#
#say "$DOCKER_IMAGE is ${bytes} Bytes larger than it's base.";


#A better way
sub image_size
{
  my @dockermeta = `docker inspect $_[0]`;
  for(@dockermeta){
    chomp;
    if($_ =~ /^\s+\"Size\":/){
       my @fields = split(':', $_);
       $fields[1] =~ s/\s//;
       $fields[1] =~ s/,//;
       return $fields[1];
    }
  }
}

sub base_image_name_from_build
{
  open(BUILD, '<', $BUILD_FILE) or die "$0 could not open $BUILD_FILE\n $!";
    for(<BUILD>){
      if ($_ =~ /^BASEIMAGE='.*/){
        chomp;
        my @fields = split("'", $_);
        $fields[1] =~  s/'//;
        close(BUILD);
        return "$fields[1]";
      }
    }
  close(BUILD);

  return undef;
}

say "$DOCKER_IMAGE is ". (image_size($DOCKER_IMAGE) - image_size($DOCKER_BASE_IMAGE)) . " Bytes larger than $DOCKER_BASE_IMAGE.";

exit 0;
