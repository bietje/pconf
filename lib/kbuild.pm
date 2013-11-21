#!/usr/bin/perl -w

package kbuild;

use strict;
use warnings;
use IO::File;

use Exporter 'import';
our $VERSION = '1.00';
our @EXPORT = qw(kbuild_gen kbuild_gen_extra kbuild_add_option kbuild_add_ah_option);

#
# kbuild_add_option(@array, $option, $value)
#
sub kbuild_add_option(\@$$)
{
	my $arr_ref = $_[0]; # ref to the array
	my $option = $_[1];
	my $type = $_[2];

	push($arr_ref, "CONFIG_$option=$type\n");
}

#
# kbuild_add_ah_option(@array, $option, $value)
#
sub kbuild_add_ah_option(\@$$)
{
	my $arr_ref = $_[0]; # ref to the array.
	my $option = $_[1];
	my $value = $_[2];;

	push($arr_ref, "#define CONFIG_$option $value\n");
}

#
# kbuild_gen($kbuild_input)
#
sub kbuild_gen($)
{
	
}

#
# gen_kbuild($conf_out, @config_data, $ah_file, @autoheader_data)
#
sub kbuild_gen_extra($\@$\@)
{
	my $conf_out = $_[0];
# 	my $kbuild_file = $_[0];
	my $config_data = $_[1];
	my $ah_file = $_[2];
	my $ah_data = $_[3];
	
	#auto header data
	my $autoheader_prefix = <<"AUTOHEADER_END";
/*
 * DO NOT EDIT - Generated by PConf
 */

#ifndef __AUTOHEADER_H_
#define __AUTOHEADER_H_

AUTOHEADER_END
	my $autoheader_suffix = "#endif\n";

	#kbuild data
	my $kbuild_prefix = "#\n#DO NOT EDIT - generated by PConf.\n#\n\n";

	my $kfd = IO::File->new($conf_out, O_WRONLY | O_CREAT | O_TRUNC)
				or die 'Couldn\'t open the specified output file!';
	my $afd = IO::File->new($ah_file, O_WRONLY | O_CREAT | O_TRUNC)
				or die 'Couldn\'t open the specified output file!';
	my $cfd = IO::File->new($conf_out, O_WRONLY | O_CREAT | O_TRUNC)
				or die 'Couldn\'t open the specified output file!';

	# print the .config file
	print $cfd $kbuild_prefix;
	print $cfd @$config_data;

	# print the autoheader
	print $afd $autoheader_prefix;
	print $afd @$ah_data;
	print $afd $autoheader_suffix;

	# TODO: print the Kbuild file
	
	# close files and done!
	$afd->close;
	$kfd->close;
	$cfd->close;
}

"1";
