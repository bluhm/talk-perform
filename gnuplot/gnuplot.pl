#!/usr/bin/perl
# collect cvs logs between certain dates for sub branches

# Copyright (c) 2018 Alexander Bluhm <bluhm@genua.de>
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
getopts('vnC:D:T:', \%opts) or do {
    print STDERR <<"EOF";
usage: $0 [-vn] [-D date] -T tcp|make|udp|fs new_file.tex
    -v		verbose
    -n		dry run
    -D date	run date
    -T test	test name (tcp, make, upd, fs)
EOF
    exit(2);
};
my $verbose = $opts{v};
my $dry = $opts{n};
my $run = str2time($opts{D})
    or die "Invalid -D date '$opts{D}'"
    if ($opts{D});
my $test = $opts{T}
    or die "Option -T tcp|make|udp|fs missing";

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
my ($tst, $sub, undef, undef, undef, undef, $unit)  = split(/\s+/, <$fh>);
$tests{"$tst $sub"} = 1;

while (my $row = <$fh>) {
    my ($tst, $sub) = split(/\s+/, $row);
    $tests{"$tst $sub"} = 1;
}

my $testnames = join(" ", sort keys %tests);
my %q = quirks();
my $quirks = join(" ", sort keys %q);

my @plotvars = ("DATA_FILE='$testdata'",
"OUT_FILE='$out'",
"QUIRKS='$quirks'",
"TESTS='$testnames'",
"TITLE='$title'",
"UNIT='$unit'");
my @plotcmd = ("gnuplot", "-d");

push @plotvars, "RUN_DATE='$run'" if $run;
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
