#!/usr/bin/perl

use lib $ENV{SITE}.'/lib';
use UTIL qw(fname get_localip);
use IPFS qw(ipfsrun);

my $file = shift;
my ($fpath,$fname,$bname,$ext) = &fname($file);
my $fnamep = $fname; $fnamep =~ s/"/%22/g;

my $dotip = &get_localip();
my $mh = &ipfsrun(sprintf'add -w --raw-leaves --chunker size-1048576 --trickle "%s"',$file);
use YAML::Syck; printf "mh: %s...\n",YAML::Syck::Dump($mh);
my $qm58 = $mh->{$fname};
my $wrap = $mh->{wrap};


# ----------------------------------------------
# one item playlist (m3u)
my $m3u = sprintf "#EXTM3U\n#EXTINF:30,%s\n",$bname;
   $m3u .= sprintf "http://gateway.ipfs.io/ipfs/%s\n",$qm58;
   $m3u .= sprintf "http://%s:8046/ipfs/%s\n",'ocean',$qm58;
   $m3u .= sprintf "http://%s:8083/ipfs/%s\n",$dotip,$qm58;
   $m3u .= sprintf "http://127.0.0.1:8080/ipfs/%s\n",$qm58;

   $m3u .= sprintf "http://ipfs.gc-bank.org/ipfs/%s\n".
   "http://dweb.link/ipfs/%s\n".
   "http://ipns.co/ipfs/%s\n",$qm58,$qm58,$qm58;
printf "%s\n",$m3u if $dbug;
use MIME::Base64;
my $m3u64 = &MIME::Base64::encode_base64($m3u,'');
printf "data:audio/x-mpegurl;base64,%s\n",$m3u64;
# ----------------------------------------------

local *Y;
open Y,'>','_data/video5.yml';
printf Y <<'EOF',$bname,$qm58,$wrap,$m3u64;
--- # video5 parameters
VNAME: "%s"
QM58: %s
wrap: %s
M3U64: "%s"
EOF

exit $?;

1; # made with Love ♡
