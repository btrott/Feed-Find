use CGI::Application::Server;
use Test::HTTP::Server::Simple;

package My::WebServer {
    use base qw/Test::HTTP::Server::Simple CGI::Application::Server/;
}

package main;

use strict;
use Test::More tests => 5;
use Feed::Find;
use LWP::UserAgent;

my $port = $ENV{CGI_APP_SERVER_TEST_PORT} || 40000 + int(rand(10000));

my $s = My::WebServer->new($port);
$s->document_root('./t/htdocs');

my $url_root = $s->started_ok("start up my web server");

# generate our anchors-only.html file to get the URL correct in the links
my $anchor_html = <<"END";
<html>
  <head>
    <link rel="alternate" title="my feed"
      href="$url_root/ok.xml" type="application/xml" />
  <head>
  <body>
    <a href="$url_root/ok.xml" type="application/xml">my feed</a>
  </body>
</html>
END

open(my $fh, ">./t/htdocs/anchors-only.html") or
  die "Cannot open file\n";
print $fh <<"END";
<html>
  <head>
    <link rel="alternate" title="my feed"
      href="$url_root/ok.xml" type="application/xml" />
  <head>
  <body>
    <a href="$url_root/ok.xml" type="application/xml">my feed</a>
  </body>
</html>
END
close $fh;

my @feeds = ();
@feeds = Feed::Find->find("$url_root/anchors-only.html");
is(scalar @feeds, 1);
is($feeds[0], "$url_root/ok.xml");

my $ua = LWP::UserAgent->new;
$ua->env_proxy;
my $req = HTTP::Request->new(GET => "$url_root/anchors-only.html");
my $res = $ua->request($req);
@feeds = Feed::Find->find_in_html(\$res->content, "$url_root/anchors-only.html");
is(scalar @feeds, 1);
is($feeds[0], "$url_root/ok.xml");
