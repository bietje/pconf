#!/usr/bin/perl -w

package pconf_reader;

use strict;
use warnings;
use JSON::XS;
use IO::File;

use Exporter 'import';
our $VERSION = '1.00';
our @EXPORT = qw(read_confin);

sub read_confin($);

#
# Read the config file.
# read_confin(fname) -> file name in $_[0]
#
# Return: JSON hash
#
sub read_confin($)
{
	my $conf_file = $_[0];

	my $fd = IO::File->new($conf_file, O_RDONLY)
				or die "Couldn\'t open config input file ($conf_file)!";

	my @fcontents = <$fd>;
	my $json_in;

	foreach(@fcontents) {
		$json_in .= $_;
	}
	return decode_json($json_in);
}

"1";
