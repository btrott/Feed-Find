# $Id: Makefile.PL,v 1.2 2004/08/18 02:43:20 btrott Exp $

use inc::Module::Install;

name('Feed-Find');
abstract('Syndication Feed Discovery');
author('Benjamin Trott <cpan@stupidfool.org>');
version_from('lib/Feed/Find.pm');
license('perl');
no_index(directory => 't');
sign(1);

include('ExtUtils::AutoInstall');

requires('Class::ErrorHandler');
requires('LWP');
requires('HTML::Parser');
requires('URI');

auto_include();
auto_install();

&WriteAll;
