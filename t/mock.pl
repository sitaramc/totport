#!/usr/bin/perl

my $t = shift;
my $f = shift;

use Time::Mock;
Time::Mock->set($t);

do $f;
