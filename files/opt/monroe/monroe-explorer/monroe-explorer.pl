#!/usr/bin/perl
#g0 , 2016

use strict;
#use warnings;
use LWP;
use File::Basename;
use Net::DNS;
use Data::Dumper;
use Socket;
require 'sys/ioctl.ph';

#use v5.10;
my $VERSION = '0.1';
my ($myname, $mypath, $mysuffix) = fileparse( $0, qr/\.[^.]*$/ );


=head1 Description
A piece of software that logs system and network setup
and runs network probes for numbers and names set in its config, viz:
traceroute, traceroute over TCP 80, httping, and DNS lookups.
It also logs your public IP address, checks if HTTP is proxied
and if your local caching DNS answer the same way with some open Internet caching DNS service.
It was written while I was getting acquainted with the Monroe testbed.

=cut

=head1 Author
g0, github@bot.ipduh.com

=cut

#Run $myname without arguments.
#Edit $myname.conf to configure.

my $USAGE =<<"EOU";
=head1 Usage
Run monroe-explorer.pl without arguments.
Edit monroe-explorer.conf to configure.

=cut
EOU

my $myua = "${myname}.v$VERSION";
my $CONFIG="${mypath}monroe-explorer.conf";
my $DEFAULT_HTTP_TIMEOUT = 60;
my $DEFAULT_DNS_TCP_TIMEOUT = 30;
my $DEFAULT_DNS_UDP_TIMEOUT = 30;
my $STANZA_SEP = "****\n";

my @debug_log=();
my @errors=();

#Run $myname without arguments.
#Edit $myname.conf to configure.

if(@ARGV > 0){
  for my $line (split /\n/, $USAGE){
    print "$line\n" unless ($line =~ /^=.*/);
  }
  exit 3;
}


sub logdebug
{
  push(@debug_log, $_[0]);
}

logdebug("$myua\n");

my %UP=();
unless (open(CONFIG, '<' , $CONFIG)){
  system("touch /monroe/results/monroe-explorer-cannot-read-his-configuration-file");
  die $!;
};
while(<CONFIG>){
  chomp;
  s/#.*//;
  s/^\s+//;
  s/\s+$//;
  next unless length;
  my ($var,$val) = split(/\s*=\s*/, $_ , 2);
  $UP{$var} = $val;
}
close(CONFIG);

logdebug("Configuration:");
while(my ($key,$val) = each(%UP)){
 logdebug("$key -> $val");
}

my $VERBOSITY = $UP{'VERBOSITY'};
my $UA_EMAIL_ADDRESS = $UP{'UA_EMAIL_ADDRESS'};
my $LOCAL_RESULTS_DIR = $UP{'LOCAL_RESULTS_DIR'};
my @CHECK_DOMAIN_NAMES = split(',', $UP{'CHECK_DOMAIN_NAMES'});
my $HTTP_TIMEOUT = $UP{'HTTP_TIMEOUT'} || $DEFAULT_HTTP_TIMEOUT;             #seconds
my $DNS_TCP_TIMEOUT = $UP{'DNS_TCP_TIMEOUT'} || $DEFAULT_DNS_TCP_TIMEOUT;
my $DNS_UDP_TIMEOUT = $UP{'DNS_UDP_TIMEOUT'} || $DEFAULT_DNS_UDP_TIMEOUT;
my @TRACE_ROUTES_TO = split(',',$UP{'TRACE_ROUTES_TO'});
my @TRACE_ROUTES_TO_NAMES = split(',',$UP{'TRACE_ROUTES_TO_NAMES'});
my @HTTPING = split(',',$UP{'HTTPING'});

my @goons = split(',', $UP{'INTERNET_CACHING_NS'});

my $VERBOSE_HTTP = 0;
my $DEBUG_LOG = "$LOCAL_RESULTS_DIR/${myname}.debug.log";
my $NETWORK_SETUP_LOG = "$LOCAL_RESULTS_DIR/${myname}.network-setup.log";
my $SYSTEM_SETUP_LOG = "$LOCAL_RESULTS_DIR/${myname}.system-setup-status.log";
my $NETWORK_PROBES_LOG = "$LOCAL_RESULTS_DIR/${myname}.network-probes.log";

#Used to find out Internet IP address, http-proxy, InternetIP-for-ldns, dns-mismatch ...
my $MYIPDOMNAME = 'ipduh.com';
my $MYIPPATH='/my/ip/';
my $MYIPURI='http://'.$MYIPDOMNAME.$MYIPPATH;
my $DOMNAME = 'ipduh.com';

#Without resolv.conf, socks5, system, etc
my $testresolver = Net::DNS::Resolver->new;
my @localns = $testresolver->nameservers();
undef $testresolver;

my $getter = LWP::UserAgent->new();
$getter->agent("$myua");
$getter->from($UA_EMAIL_ADDRESS) if(length $UA_EMAIL_ADDRESS);
$getter->timeout($HTTP_TIMEOUT);
$getter->protocols_allowed(['http' , 'https']);
$getter->show_progress($VERBOSE_HTTP);
#$getter->env_proxy;
#but screw env_proxy


my @netcomout = ();
my @netcom = (
              '/sbin/ip a',
              '/sbin/route -n',
              '/sbin/ifconfig',
              '/bin/cat /etc/resolv.conf',
              '/sbin/brctl show',
              '/bin/cat /etc/iproute2/rt_tables',
              '/sbin/ip rule list',
              '/bin/cat /etc/networks',
              '/bin/cat /etc/network/interfaces',
              '/sbin/ip netns list',
              '/bin/netstat -punta',
              );

my @syscom = (
              '/usr/bin/id',
              '/bin/uname -a',
              '/bin/cat /proc/cpuinfo',
              '/bin/cat /proc/meminfo',
              '/usr/bin/free -h',
              '/usr/bin/w.procps',
              );

#Not good for interfaces with many IP addresses
sub get_if_ipa
{
my ($iface) = @_;
my $socket;
socket($socket, PF_INET, SOCK_STREAM, (getprotobyname('tcp'))[2]) || die "unable to create a socket: $!\n";
my $buf = pack('a256', $iface);
  if(ioctl($socket, SIOCGIFADDR(), $buf) && (my @address = unpack('x20 C4', $buf))){
    return join('.', @address);
  }
return undef;
}

sub network_if_names
{
my @if_names=();
opendir(DIR, '/sys/class/net'); #or
  while(my $netif = readdir(DIR)){
    next if($netif =~ m/^\./ or $netif eq 'lo');
    push(@if_names, $netif)
  }
close(DIR);
return \@if_names;
}

sub if_to_ip
{
my $ipa =`ip a`;
my @ipa = split('\n' , $ipa);

# not hash --not always 1-1
# ifname, ip_addr, ip_prefix, if_label if iface has an ip_addr
my @ifipmap=();

my $ifname='';
my $iflabel='';
my $ip='';
my $prefix='';
my @tmp=();
my $tmp='';

for my $line (@ipa){
  if($line =~ /^[0-9]/){
    @tmp = split(':', $line);
    $ifname = $tmp[1];
    $ifname =~ s/\s+//;
  }
  #speed up, skip IPv6, it appears that the tesbed does not have Internet IPv6 anyways
  #if($line =~ /^\s+inet/){
  if($line =~ /^\s+inet/ and $line !~ /^\s+inet6/){
    @tmp = split(/\s{1,}/, $line);
    my @cidr = split('/', $tmp[2]);
    $ip = $cidr[0];
    $prefix = $cidr[1];

    #not always at this index, but usually there when it matters
    $iflabel = $tmp[7];

    push(@ifipmap, "$ifname,$ip,$prefix,$iflabel");
  }
}
  return \@ifipmap;
}

sub ua_headers
{
  $Data::Dumper::Terse=1;
  my $headers = Dumper($getter->{def_headers});
  if($headers =~ /\{([^}]+)\}/){
    return $1;
  }
  return $headers;
}

sub getarecords
{
  my $resolver = Net::DNS::Resolver->new;
  $resolver->tcp_timeout($DNS_TCP_TIMEOUT);
  $resolver->udp_timeout($DNS_UDP_TIMEOUT);
  $resolver->nameservers(@{$_[1]});
  $resolver->force_v4(1);
  my @answ = ();
  my $query = $resolver->search($_[0], 'A');
  if($query){
    foreach my $rec ($query->answer){
      next unless $rec->type eq 'A';
      push (@answ, $rec->address);
    }
    return (\@answ, $resolver->errorstring);
  }
  else {
    return (undef, $resolver->errorstring);
  }
}

#use constant GETURL => qw(CONTENT HEADERS BEHINDPROXY);
sub geturl
{
  my $resp = $getter->get($_[0],
                          'Accept-Language' => 'en-US',
                          'Accept-Charset' => 'iso-8859-1,*,utf-8',
                          'Accept-Encoding' => 'gzip',
                          'Accept' =>
                          "image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png, */*",
                          #':content_file' => 'filename.html',
  );

  #logdebug(ua_headers);
  #HTTP/1.1|TE:deflate,gzip;q=0.3|Connection:TE, close|
  #Accept:image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, image/png, */*
  #|Accept-Charset:iso-8859-1,*,utf-8|
  #Accept-Encoding:gzip|
  #Accept-Language:en-US
  #|From:monroe-explorer@bot.ipduh.com|
  #Host:ipduh.com|User-Agent:monroe-explorer.v0.1

  if($resp->is_success){
    my ($peer_addr, $peer_port) = split(':', $resp->header('Client-Peer'));
    return ($resp->decoded_content, $resp->headers_as_string, $peer_addr, $resp->status_line);
  }

  #logdebug("error: $_[0] => $resp->status_line");
  push(@errors,"error: $_[0] => $resp->status_line");

  return (undef, undef, undef, $resp->status_line);
}

sub log_public_ips
{
  my $ifip = if_to_ip();
    logdebug("Public IP addresses:\n");
    logdebug("IF_name\t\t\tIP_addr\t\t\tIP_Prefix\t\t\tIF_Label\t\tPublic_Internet_IP_addr");
  for my $entry (@$ifip){
    my ($ifname, $ip_addr, $ip_prefix, $if_label) = split(',', $entry);
    next if($ifname eq 'lo');

    #speed up things
    next if($ifname =~ /metadata/);

    $getter->local_address($ip_addr);
    my ($myip, $headers, $peer_addr, $status) = geturl($MYIPURI);
    chomp($myip);
    logdebug("$ifname\t\t\t$ip_addr\t\t\t$ip_prefix\t\t\t$if_label\t\t$myip");
  }
}

sub is_http_proxied
{
  my ($ips, $status) = getarecords($_[0], \@goons);
  my ($myip, $headers, $peer_addr, $status) = geturl($MYIPURI);

  return 0 if(grep(/^$peer_addr$/, @$ips));
  return 1;
}

sub ldns_goodns_mismatch
{
  my ($ips_fromgoo, $status_fromgoo) = getarecords($_[0], \@goons);
  my ($ips, $status) = getarecords($_[0], \@localns);

  return 1 unless(scalar(@$ips_fromgoo) == scalar(@$ips));

  foreach my $ip (@$ips_fromgoo){
    return 1 unless(grep(/^$ip$/, @$ips));
  }

  return 0;
}

sub node_public_ip # default
{
  my ($content, $headers, $peer_addr, $status) = geturl($MYIPURI);
  logdebug("Node Internet IP address: $content");
  logdebug("$MYIPURI headers: \n $headers") if($VERBOSITY > 2);
  logdebug("$MYIPURI Peer-Addr: $peer_addr") if($VERBOSITY > 4);
  return $content;
}

sub write_debug_log
{
  unless(open(DEBUG_LOG, '>' , $DEBUG_LOG)){
    system("touch ${LOCAL_RESULTS_DIR}/monroe-explorer-cannot-write-debug-log");
    die $!;
  }
  print DEBUG_LOG "$_\n" foreach(@debug_log);
  close(DEBUG_LOG);
}

sub write_a_log
{
  unless(open(A_LOG, '>' , $_[0])){
    system("touch ${LOCAL_RESULTS_DIR}/${myua}-cannot-write-$_[0]-log");
    #die $!;
  }
  print A_LOG foreach(@{$_[1]});
  close(A_LOG);
}

sub write_a_com_log
{
  my @comout = ("$myua:\n");

  for my $com(@{$_[1]}){
    push(@comout, $STANZA_SEP);
    push(@comout, "$com\n");
    my $stat = system("$com > /dev/null");
    my $out = `$com`;
    push(@comout, "$stat\n");
    push(@comout, $out);
    push(@comout, $STANZA_SEP);
  }

  write_a_log($_[0],\@comout);
}

sub network_probes
{
  my $traceroute = 'traceroute --mtu --back -e -m 20';
  my $traceroute_tcp80 = 'traceroute --mtu --back -e -m 20 -T -p 80';
  my $httping = "httping -r -c 3 -I $myua -G -b -t $HTTP_TIMEOUT";

  my @nprobes_out = ("$myua:\n");

  if(scalar @TRACE_ROUTES_TO > 0){
    for my $ipaddr (@TRACE_ROUTES_TO){
      push(@nprobes_out, $STANZA_SEP);
      push(@nprobes_out, `$traceroute $ipaddr`);
      push(@nprobes_out, $STANZA_SEP);
    }
  }

  if(scalar @TRACE_ROUTES_TO_NAMES > 0){
    for my $name (@TRACE_ROUTES_TO_NAMES){
      my ($ips, $status) = getarecords($name, \@localns);
      push(@nprobes_out, $STANZA_SEP);
      push(@nprobes_out, "traceroute TCP 80: $name\n");
      push(@nprobes_out, `$traceroute_tcp80 $_`) foreach(@{$ips});
      push(@nprobes_out, $STANZA_SEP);
    }
  }

  if(scalar @HTTPING > 0){
    for my $ip (@HTTPING){
      push(@nprobes_out, $STANZA_SEP);
      push(@nprobes_out, "httping: $ip\n");
      push(@nprobes_out, `$httping $ip`);
      push(@nprobes_out, $STANZA_SEP);
    }
  }

  write_a_log($NETWORK_PROBES_LOG, \@nprobes_out);
}

logdebug("\nRun:");

node_public_ip;

logdebug("Local NS:" . (join " - ", @localns) ."\n");

for my $name ($MYIPDOMNAME,@CHECK_DOMAIN_NAMES){
  my ($ips, $status) = getarecords($name, \@goons);
  #Can't use an undefined value as an ARRAY reference at /opt/monroe/monroe-explorer/monroe-explorer.pl line 292
  eval {
    logdebug("A records for $name: " . (join " - ", @{$ips}) . "\n");
  } or do {
    logdebug("No A records for $name\n");
  };
  logdebug("$name DNS query status : $status\n") if($VERBOSITY > 3);
  if(ldns_goodns_mismatch($name)){
    logdebug("local and INTERNET_CACHING_NS mismatch for $name\n");
    my ($arecs, $arecstatus) = getarecords($name, \@localns);
    logdebug("A records for $name from local NS: " . (join " - ", @$arecs). "\n") if($VERBOSITY > 2);
  }
}

(is_http_proxied($MYIPDOMNAME)) ? logdebug("http may be proxied\n") : logdebug("http is not proxied for $MYIPDOMNAME\n");

#write_network_setup_log;

write_a_com_log($SYSTEM_SETUP_LOG, \@syscom);

write_a_com_log($NETWORK_SETUP_LOG, \@netcom);

log_public_ips();

network_probes();

logdebug(@errors);
logdebug("${myname}.v$VERSION: I am done.");

write_debug_log;

exit 0;
