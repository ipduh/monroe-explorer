#!t/usr/bin/perl
# g0, 2016

use strict;
#use v5.10;

=head1 Description
  Create README.md for this repository

=cut

=head1 Usage
  Run without arguments in your repository root directory.

=cut

=head1 Author
  g0, github@bot.ipduh.com

=cut


my @paths = ();
my %files = ();
my @md = ();
my @files = `git ls-files`;

for my $path (@files){

  chomp $path;

  if($path =~ /^.*\.sh$/ ){
    if($path =~ /^.*\/(.*\.sh)$/){
      $files{$1} = $path;
      shmd($1, $path);
      next;
    }else{
      $path =~ /([\w\-]+\.sh)/;
      $files{$1} = './';
      shmd($1, $path);
      next;
    }
  }


  if($path =~ /^.*\.pl$/ ){
    if($path =~ /^.*\/(.*\.pl)$/){
      $files{$1} = $path;
      plmd($1, $path);
      next;
    }else{
      $path =~ /([\w\-]+\.pl)/;
      $files{$1} = './';
      plmd($1, $path);
      next;
    }
  }

  if($path =~ /^.*\.py$/ ){
    if($path =~ /^.*\/(.*\.py)$/){
      $files{$1} = $path;
      pymd($1, $path);
      next;
    }else{
      $path =~ /([\w\-]+\.py)/;
      $files{$1} = './';
      pymd($1, $path);
      next;
    }
  }


}


#for(keys %files){
# say "$_ -> $files{$_}";
#}


sub shmd
{
  my $procflag = 0;

  push(@md, "\n");
  push(@md, "## $_[0]\n");
  push(@md, "```\n");

  open(SHELL, '<', $_[0]) or die "$0 could not open $_[0]\n $!";
    for(<SHELL>){
      if($_ =~ /^#=go.*/){
        $procflag = 1;
        next;
      }

      if($_ =~ /^#=cut.*/){
        $procflag = 0;
      }

      if($procflag){
        next if($_ =~ /^DESCRIPTION.*/);
        next if($_ =~ /^cat\s<<DESCRIPTION.*/);
        push(@md, $_);
      }

    }
  close(SHELL);

  push(@md, "```\n");

}

sub plmd
{
  push(@md, "\n");
  push(@md, "## $_[0]\n");
  push(@md, "```\n");
  my @blah = `pod2text $_[1]`;
  push(@md, @blah);
  push(@md, "```\n");
}

sub pymd
{
  my $procflag = 0;

  push(@md, "\n");
  push(@md, "## $_[0]\n");
  push(@md, "```\n");

  open(PYTHON, '<', $_[1]) or die "$0 could not open $_[1]\n $!";
    for(<PYTHON>){

      if($_ =~ /^""".*/ && $procflag){
        $procflag = 0;
        last;
      }

      if($_ =~ /^""".*/){
        $procflag = 1;
      }

      push(@md, $_) if($procflag && $_ !~ /^""".*/);

    }
  close(PYTHON);

  push(@md, "```\n");

}


open(MD, '>', "README.md") or die "$0 could not write README.md\n $!";
  print MD for(@md);
close(MD);

exit 0;
