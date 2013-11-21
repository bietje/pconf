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

use constant REQUIRED_ARGS => 4;

my $args_num = $#ARGV+1;
my $first_arg = $ARGV[0];
my $second_arg = $ARGV[1];
my $third_arg = $ARGV[2];
my $forth_arg = $ARGV[3];

my $help_text_short = "Usage: pconf.pl [--intree | --out-of-tree | --help] --output [output file] [config input]\n";
my $help_text = <<"END_HELP";
PConf is a perl based configure script for Linux kernel modules. To configure your kernel for out-of-tree building use:

	pconf.pl --out-of-tree --output [Kbuild file] [config input]

Where [Kbuild file] points the location where the Kbuild content should be written to. [config input], on the other hand is the input config file.

For in-tree building:

	pconf.pl --intree --output [Kconfig] [config input]

Where [Kconfig file] points the location where the Kconfig content should be written to. [config input], on the other hand is the input config file.

The [config input] argument is the path to your config.in file.
END_HELP

if($args_num == 1 && $first_arg =~ /--help/) {
	print $help_text;
	exit 0;
}

if(REQUIRED_ARGS != $#ARGV+1) {
	print $help_text_short;
	exit 1;
}

my $parser;

if($first_arg =~ /--out-of-tree/ || $third_arg =~ /--out-of-tree/) {
	$parser = "gen_kbuild";
}

if($first_arg =~ /--in-tree/ || $third_arg =~ /--in-tree/) {
	$parser = "gen_kconfig";
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
