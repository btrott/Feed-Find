# $Id: Find.pm,v 1.3 2004/08/18 02:44:03 btrott Exp $

package Feed::Find;
use strict;

use base qw( Class::ErrorHandler );
use LWP::UserAgent;
use HTML::Parser;
use URI;

use vars qw( $VERSION );
$VERSION = '0.02';

use constant FEED_MIME_TYPES => [
    'application/x.atom+xml',
    'application/atom+xml',
    'text/xml',
    'application/rss+xml',
    'application/rdf+xml',
];

our $FEED_EXT = qr/\.(?:rss|xml|rdf)$/;

sub find {
    my $class = shift;
    my($uri) = @_;
    my $base_uri = $uri;
    my @feeds;
    my %is_feed = map { $_ => 1 } @{ FEED_MIME_TYPES() };
    my $find_links = sub {
        my($self, $tag, $attr) = @_;
        if ($tag eq 'link') {
            return unless $attr->{rel};
            my %rel = map { $_ => 1 } split /\s+/, lc($attr->{rel});
            (my $type = lc $attr->{type}) =~ s/^\s*//;
            $type =~ s/\s*$//;
            push @feeds, URI->new_abs($attr->{href}, $base_uri)->as_string
               if $is_feed{$type} &&
                  ($rel{alternate} || $rel{'service.feed'});
        } elsif ($tag eq 'base') {
            $base_uri = $attr->{href};
        } elsif ($tag =~ /^(?:meta|isindex|title|script|style|head|html)$/) {
            ## Ignore other valid tags inside of <head>.
        } elsif ($tag eq 'a') {
            my $href = $attr->{href} or return;
            my $uri = URI->new($href);
            push @feeds, URI->new_abs($href, $base_uri)->as_string
                if $uri->path =~ /$FEED_EXT/io;
        } else {
            ## Anything else indicates the start of the <body>,
            ## so we stop parsing.
            $self->eof if @feeds;
        }
    };
    my $p = HTML::Parser->new(api_version => 3,
        start_h => [ $find_links, "self, tagname, attr" ]);
    my $ua = LWP::UserAgent->new;
    $ua->agent(join '/', $class, $class->VERSION);
    $ua->parse_head(0);   ## We're already basically doing this ourselves.
    my $req = HTTP::Request->new(GET => $uri);
    my $res = $ua->request($req, sub {
        my($chunk, $res, $proto) = @_;
        $p->parse($chunk) or die "Done parsing";
    });
    return $class->error($res->status_line) unless $res->is_success;
    @feeds;
}

1;
__END__

=head1 NAME

Feed::Find - Syndication feed auto-discovery

=head1 SYNOPSIS

    use Feed::Find;
    my @feeds = Feed::Find->find('http://example.com/');

=head1 DESCRIPTION

I<Feed::Find> implements feed auto-discovery for finding syndication feeds,
given a URI. It (currently) passes all of the auto-discovery tests at
I<http://diveintomark.org/tests/client/autodiscovery/>.

I<Feed::Find> will discover the following feed formats:

=over 4

=item * RSS 0.91

=item * RSS 1.0

=item * RSS 2.0

=item * Atom

=back

=head1 USAGE

=head2 Feed::Find->find($uri)

Given a URI I<$uri>, use a variety of techniques to find the feeds associated
with that page.

Returns a list of feed URIs.

The following techniques are used:

=over 4

=item 1. I<E<lt>linkE<gt>> tag auto-discovery

If the page contains any I<E<lt>linkE<gt>> tags in the I<E<lt>headE<gt>>
section, these tags are examined for recognized feed content types. The
following content types are treated as feeds: I<application/x.atom+xml>,
I<application/atom+xml>, I<text/xml>, I<application/rss+xml>, and
I<application/rdf+xml>.

=item 2. Scanning I<E<lt>aE<gt>> tags

If the page does not contain any known I<E<lt>linkE<gt>> tags, the page is
then scanned for I<E<lt>aE<gt>> tags for links to URIs with certain file
extensions. The following extensions are treated as feeds: F<.rss>, F<.xml>,
and F<.rdf>.

Note that this technique is employed B<only> if the first technique returns
no results.

=back

=head1 LICENSE

I<Feed::Find> is free software; you may redistribute it and/or modify it
under the same terms as Perl itself.

=head1 AUTHOR & COPYRIGHT

Except where otherwise noted, I<Feed::Find> is Copyright 2004 Benjamin
Trott, cpan@stupidfool.org. All rights reserved.

=cut
