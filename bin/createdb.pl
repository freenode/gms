#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use GMS::Schema;

my $db = GMS::Schema->do_connect;

$db->deploy({ add_drop_table => 1 });
