---
layout: page
title: PConf
tagline: Linux module configure script
---
{% include JB/setup %}
<hr/>

PConf is a configure tool for Linux kernel modules.

Copying
--------
PConf is being developed by:

* Michel Megens

The kernel module is released under the GPLv3 license:

    PConf
    Copyright (C) 2013 - Michel Megens

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

Command line options
------------
Usage: pconf.pl [OPTIONS] [FILE]
PConf is a perl based configure script for Linux kernel modules.

	-b --kbuild=PATH        Kbuild output file (path to)
	-a --autoheader=PATH    autoheader.h output file (path to)
	-k --kconfig=PATH       Kconfig output file (path to)
	-c --confout=PATH       Output config file
	-t --outoftree          When defined, the script will configure for an out-of-tree build.
	-I --intree             When specified, the script will configure for an in-tree-build.
	-m --make-in=PATH       When specified it will use this file as Makefile input.

Bug fixes and contribution
--------------------
All bug fixes and patches are welcome. Bug fixes can be posted at bugs.michelmegens.net. Patches
can be mailed to me on dev[at]michelmegens.net.
