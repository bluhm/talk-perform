#!/usr/bin/perl
# collect cvs logs between certain dates for sub branches

# Copyright (c) 2018-2020 Alexander Bluhm <bluhm@genua.de>
# Copyright (c) 2018-2019 Moritz Buhl <mbuhl@genua.de>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

use strict;
use warnings;
use Cwd;
use Date::Parse;
use File::Basename;
use Getopt::Std;
use POSIX;
use Time::Local;

use lib dirname($0);
use Buildquirks;
my $scriptname = "$0 @ARGV";

my %opts;
getopts('vnC:D:N:T:X:x:Y:y:', \%opts) or do {
    print STDERR <<"EOF";
usage: $0 [-vn] [-D date] [-N number] -T test
[-x min] [X max] [-y min] [Y max] new_file.tex
    -v		verbose
    -n		dry run
    -D date	run date
    -N number	test number
    -T test	test name (tcp|tcp6|linux|linux6|make|udp|udp6|fs)
    -x min	x range minimum
    -X max	x range maximum
    -y min	y range minimum
    -Y max	y range maximum
EOF
    exit(2);
};
my $verbose = $opts{v};
my $dry = $opts{n};
my ($run, $date);
if ($opts{D}) {
    $run = str2time($opts{D})
	or die "Invalid -D date '$opts{D}'";
    $date = $opts{D};
}
my $tstnum = $opts{N};
my $test = $opts{T}
    or die "Option -T test missing";
my ($xmin, $xmax, $ymin, $ymax);
if (defined $opts{x}) {
    $opts{x} =~ /^\d+$/
	or die "x min '$opts{x}' not a number";
    $xmin = $opts{x}
}
if (defined $opts{X}) {
    $opts{X} =~ /^\d+$/
	or die "X max '$opts{X}' not a number";
    $xmax = $opts{X}
}
if (defined $opts{y}) {
    $opts{y} =~ /^\d+$/
	or die "y min '$opts{y}' not a number";
    $ymin = $opts{y}
}
if (defined $opts{Y}) {
    $opts{Y} =~ /^\d+$/
	or die "Y max '$opts{Y}' not a number";
    $ymax = $opts{Y}
}

my $out = $ARGV[-1]
    or die "new_file.tex missing";

# better get an errno than random kill by SIGPIPE
$SIG{PIPE} = 'IGNORE';


my $plotfile = "plot.gp";
-f $plotfile
    or die "No gnuplot file '$plotfile'";
my $testdata = "test-$test.data";
-f $testdata
    or die "No test data file '$testdata'";

my $title = uc($test). " Performance";
my %tests;
open (my $fh, '<', $testdata)
    or die "Open '$testdata' for reading failed: $!";

<$fh>; # skip file head
my ($tst, $sub, undef, undef, undef, undef, $unit)  = split(" ", <$fh>);
$tests{"$tst $sub"} = 1;
while (<$fh>) {
    ($tst, $sub) = split;
    $tests{"$tst $sub"} = 1;
}

my @tests = sort keys %tests;
@tests = $tests[$tstnum] if $tstnum;
my @quirks = sort keys %{{quirks()}};

my @plotvars = (
    "DATA_FILE='$testdata'",
    "OUT_FILE='$out'",
    "QUIRKS='@quirks'",
    "TESTS='@tests'",
    "TITLE='$title'",
    "UNIT='$unit'"
);
push @plotvars, "RUN_DATE='$run'" if $run;
push @plotvars, "XRANGE_MIN='$xmin'" if defined $xmin;
push @plotvars, "XRANGE_MAX='$xmax'" if defined $xmax;
push @plotvars, "YRANGE_MIN='$ymin'" if defined $ymin;
push @plotvars, "YRANGE_MAX='$ymax'" if defined $ymax;
my @plotcmd = ("gnuplot", "-d");
if ($dry) {
    push @plotcmd, (map { ("-e", "\"$_\"") } @plotvars);
    push @plotcmd, $plotfile;
    print "@plotcmd\n";
} else {
    push @plotcmd, (map { ("-e", $_) } @plotvars);
    push @plotcmd, $plotfile;
    print "Command '@plotcmd' started\n" if $verbose;
    system(@plotcmd)
	and die "system @plotcmd failed: $?";
    print "Command '@plotcmd' finished\n" if $verbose;
}
