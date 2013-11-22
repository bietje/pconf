#!/usr/bin/perl -w

package PConf::Util;

use strict;
use warnings;

use Exporter 'import';
our $VERSION = '1.00';
our @EXPORT = qw(pconf_array_to_string);

#
# kbuild_array_to_string(@array)
#
sub pconf_array_to_string(\@)
{
	my @autoheader = @{$_[0]};
	my $lines = undef;

	foreach my $line (@autoheader) {
		$lines .= $line;
	}

	return $lines
}
