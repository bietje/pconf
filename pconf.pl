#!/usr/bin/perl -w

# Add local lib dir

use strict;
use warnings;
use FindBin;
use IO::File;
use File::Basename;
use Getopt::Mixed;

use Cwd;
use Cwd "abs_path";
use lib "$FindBin::Bin/lib";
use kbuild;
use kconfig;
use pconf_reader;

use constant MAKE_USER_INPUT => './Makefile.in';

my $help_text_short = "Usage: pconf.pl [--intree | --outoftree | --help] [-b [FILE] -a [FILE] || -k [FILE]] [FILE]\n";
my $help_text = <<"END_HELP";
Usage: pconf.pl [OPTIONS] [FILE]
PConf is a perl based configure script for Linux kernel modules.

	-b --kbuild=PATH        Kbuild output file (path to)
	-a --autoheader=PATH    autoheader.h output file (path to)
	-k --kconfig=PATH       Kconfig output file (path to)
	-c --confout=PATH       Output config file
	-t --outoftree          When defined, the script will configure for an out-of-tree build.
	-I --intree             When specified, the script will configure for an in-tree-build.
	-m --make-in=PATH       When specified it will use this file as Makefile input.
END_HELP

# declare some argument parsing vars
my ($kconf_set, $kbuild_set, $make_in) = (undef, undef, MAKE_USER_INPUT);
my ($kbuild_out, $ah_out, $kconf_out, $confout) = (undef, undef, undef, undef);

# parse the arguments using Getopt::Mixed
Getopt::Mixed::init(q{b=s kbuild>b
a=s autoheader>a
k=s kconfig>k
c=s confout>c
t outoftree>t
i intree>i
m make-in>m
h help>h});

my $cwd = cwd();

while( my( $option, $arg_val, $pretty ) = Getopt::Mixed::nextOption()) {
	$kbuild_out = $cwd . "/" . $arg_val if $option eq "kbuild" or $option eq 'b';
	$ah_out = $cwd . "/" . $arg_val if $option eq "autoheader" or $option eq 'a';
	$kconf_out = $cwd . "/" . $arg_val if $option eq "kconfig" or $option eq 'c';
	$confout = $cwd . "/" . $arg_val if $option eq "confout" or $option eq 'c';
	$make_in = $cwd . "/" . $arg_val if $option eq "make-in" or $option eq 'm';
	$kconf_set = 1 if $option eq 'i' or $option eq "intree";
	$kbuild_set = 1 if $option eq 't' or $option eq "outoftree";

	if($option eq 'h' || $option eq "help") {
		print $help_text;
		exit;
	}
}

Getopt::Mixed::cleanup();

my $confin = $cwd . "/" . $ARGV[0];

if(!defined $confin) {
	die $help_text_short;
}

die $help_text_short if defined $kconf_set and defined $kbuild_set; # cannot set both
die $help_text_short if !defined $kconf_set and !defined $kbuild_set; # must set one
die $help_text_short if !defined $kbuild_out and !defined $kconf_out; # must set one

if(defined $kbuild_set && !defined $ah_out) {
	die 'You must specify an autoheader path for building out of tree.';
}

# Program has been called correctly
# Call the parser
my $conf = read_confin $confin;

# We don't need to actually configure to generate a Kconfig file
if(defined $kconf_set) {
	gen_kconfig($conf);
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
	kbuild_add_option(@configfile, $conf->{$key}->{'definition'}, $answer);
	kbuild_add_ah_option(@autoheader, $conf->{$key}->{'definition'}, $value);
}

kbuild_gen($kbuild_out, $confout, $make_in);
kbuild_gen_extra($confout, @configfile, $ah_out, @autoheader);
