# $Id: 00-compile.t,v 1.1.1.1 2004/08/15 15:40:02 btrott Exp $

my $loaded;
BEGIN { print "1..1\n" }
use Feed::Find;
$loaded++;
print "ok 1\n";
END { print "not ok 1\n" unless $loaded }
