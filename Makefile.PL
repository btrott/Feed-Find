# $Id: Makefile.PL 1753 2005-01-01 00:57:41Z btrott $

use inc::Module::Install;

name('Feed-Find');
abstract('Syndication Feed Discovery');
author('Benjamin Trott <ben+cpan@stupidfool.org>');
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
