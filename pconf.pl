#!/usr/bin/perl -w

# Add local lib dir


use strict;
use warnings;
use FindBin;
use IO::File;

use lib "$FindBin::Bin/lib";
use kbuild;
use kconfig;
use pconf_reader;

use constant REQUIRED_ARGS => 2;

my $args_num = $#ARGV+1;
my $first_arg = $ARGV[0];
my $second_arg = $ARGV[1];
my $help_text = <<"END_HELP";
PConf is a perl based configure script for Linux kernel modules. To configure your kernel for out-of-tree building use:

	pconf.pl --out-of-tree [config input]

For in-tree building:

	pconf.pl --intree [config input]

The [config input] argument is the path to your config.in file.
END_HELP

if($args_num == 1 && $first_arg =~ /--help/) {
	print $help_text;
	exit 0;
}

if(REQUIRED_ARGS != $#ARGV+1) {
	print "Usage: pconf.pl [--intree | --out-of-tree | --help] [config input]\n";
	exit 1;
}

# Program has been called correctly
# Call the parser
my $conf = read_confin $second_arg;
my $answer;

for my $key (keys(%$conf)) {
	if($conf->{$key}->{'type'} =~ /tristate/) {
		print "Enable option \"$key\"? (Y/M/N) ";
	} else {
		print "Enable option \"$key\"? (Y/N) ";
	}
	$answer = <STDIN>;
}
