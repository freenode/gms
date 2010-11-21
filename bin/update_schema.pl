#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use GMS::Config;

use DBIx::Class::Schema::Loader qw/make_schema_at/;

make_schema_at(
    'GMS::Schema',
    {
        dump_directory => './lib',
        naming => 'v5',
        components => 'InflateColumn::DateTime',
    },
    [
        $GMS::Config::dbstring, $GMS::Config::dbuser, $GMS::Config::dbpass
    ],
);
