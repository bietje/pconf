#!/usr/bin/perl -w

# Add local lib dir

use strict;
use warnings;
use FindBin;
use IO::File;
use Data::Dumper;
use Getopt::Mixed;

use lib "$FindBin::Bin/lib";
use kbuild;
use kconfig;
use pconf_reader;

use constant REQUIRED_ARGS => 4;

my $help_text_short = "Usage: pconf.pl [--intree | --outoftree | --help] [-b [FILE] -a [FILE] || -k [FILE]] -i [FILE]\n";
my $help_text = <<"END_HELP";
Usage: pconf.pl [OPTIONS] -i [FILE]
PConf is a perl based configure script for Linux kernel modules.

	-b --kbuild=PATH        Kbuild output file (path to)
	-a --autoheader=PATH    autoheader.h output file (path to)
	-k --kconfig=PATH       Kconfig output file (path to)
	-i --confin=PATH        Input config file
	-t --outoftree          When defined, the script will configure for an out-of-tree build.
	-I --intree             When specified, the script will configure for an in-tree-build.
END_HELP

# declare some argument parsing vars
my ($kconf_set, $kbuild_set) = (undef, undef);
my ($kbuild_out, $ah_out, $kconf_out, $confin) = (undef, undef, undef, undef);

# parse the arguments using Getopt::Mixed
Getopt::Mixed::init(q{b=s kbuild>b
a=s autoheader>a
k=s kconfig>k
i=s confin>i
t outoftree>t
I intree>I
h help>h});


while( my( $option, $arg_val, $pretty ) = Getopt::Mixed::nextOption()) {
	$kbuild_out = $arg_val if $option eq "kbuild" or $option eq 'b';
	$ah_out = $arg_val if $option eq "autoheader" or $option eq 'a';
	$kconf_out = $arg_val if $option eq "kconfig" or $option eq 'c';
	$confin = $arg_val if $option eq "confin" or $option eq 'i';
	$kconf_set = 1 if $option eq 'I' or $option eq "intree";
	$kbuild_set = 1 if $option eq 't' or $option eq "outoftree";

	if($option eq 'h' || $option eq "help") {
		print $help_text;
		exit;
	}
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
	kbuild_add_option(\@configfile, $conf->{$key}->{'definition'}, $answer);
	kbuild_add_ah_option(\@autoheader, $conf->{$key}->{'definition'}, $value);
}

print Dumper(@configfile) . "\n";
print Dumper(@autoheader) . "\n";
