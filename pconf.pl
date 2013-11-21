#!/usr/bin/perl -w

# Add local lib dir

use strict;
use warnings;
use FindBin;
use IO::File;
use Data::Dumper;

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
my $conf = read_confin $forth_arg;

# We don't need to actually configure to generate a Kconfig file
if($parser =~ /gen_kconfig/) {
	&$parser($conf);
	exit 0;
}

# Ask a series of questions to eventually generate a Kbuild file.
my $answer;
my $value;
my $question;
my @autoheader = ();
my @configfile = ();

for my $key (keys(%$conf)) {
	if($conf->{$key}->{'type'} =~ /tristate/) {
		print "Enable option \"$key\"? (Y/M/N/help) ";
		$question = "Enable option \"$key\"? (Y/M/N/help) ";
	} else {
		print "Enable option \"$key\"? (Y/N/help) ";
		$question = "Enable option \"$key\"? (Y/N/help) ";
	}
	$answer = <STDIN>;

	if($answer =~ /help/ || $answer =~ /h/ || $answer =~ /H/) {
		print $conf->{$key}->{'info'} . "\n";
		$question =~ s/\/help//g;
		print $question;
		$answer = <STDIN>;
	}

	if(!($conf->{$key}->{'type'} =~ /tristate/) && ($answer =~ /m/ || $answer =~ /M/)) {
		# if its not a tristate, don't set it as module, you bloody idiot.. asume Y
		$answer = 'y';
	}

	print "What value should be assigned to it? ";
	$value = <STDIN>;

	# cut off the new line feeds
	chomp $answer;
	chomp $value;

	# now save the option
	kbuild_add_option(\@configfile, $conf->{$key}->{'definition'}, $answer);
	kbuild_add_ah_option(\@autoheader, $conf->{$key}->{'definition'}, $value);
}

print Dumper(@configfile) . "\n";
print Dumper(@autoheader) . "\n";
