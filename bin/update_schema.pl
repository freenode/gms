#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use GMS::Config;

use DBIx::Class::Schema::Loader qw/make_schema_at/;

my $db_config = GMS::Config->database;

make_schema_at(
    'GMS::Schema',
    {
        dump_directory => './lib',
        naming => 'v5',
        components => [ 'InflateColumn::DateTime', 'InflateColumn::Object::Enum' ],
    },
    [
        $db_config->{dsn}, $db_config->{user}, $db_config->{password}
    ],
);
