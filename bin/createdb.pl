#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use GMS::Schema;
use GMS::Config;

my $db = GMS::Schema->connect($GMS::Config::dbstring,
    $GMS::Config::dbuser, $GMS::Config::dbpass);

$db->deploy();


