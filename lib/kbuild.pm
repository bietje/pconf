#!/usr/bin/perl -w

package kbuild;

use strict;
use warnings;
use Data::Dumper;

use Exporter 'import';
our $VERSION = '1.00';
our @EXPORT = qw(gen_kbuild kbuild_add_option kbuild_add_ah_option);

#
# kbuild_add_option(@array, $option, $value)
#
sub kbuild_add_option
{
	my $arr_ref = $_[0]; # ref to the array
	my $option = $_[1];
	my $type = $_[2];

	push($arr_ref, "CONFIG_$option=$type\n");
}

#
# kbuild_add_ah_option(@array, $option, $value)
#
sub kbuild_add_ah_option
{
	my $arr_ref = $_[0]; # ref to the array.
	my $option = $_[1];
	my $value = $_[2];;

	push($arr_ref, "#define CONFIG_$option $value\n");
}

sub gen_kbuild
{
	
}

"1";
