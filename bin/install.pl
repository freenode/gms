#!/usr/bin/env perl

use strict;
use warnings;
use aliased 'DBIx::Class::DeploymentHandler' => 'DH';
use FindBin;
use lib "$FindBin::Bin/../lib";
use GMS::Schema;

my $force_overwrite = 0;


my $schema = GMS::Schema->do_connect;

my $dh = DH->new(
    {
        schema              => $schema,
        script_directory    => "$FindBin::Bin/../dbicdh",
        databases           => 'PostgreSQL',
        sql_translator_args => { add_drop_table => 0 },
        force_overwrite     => $force_overwrite,
    }
);

$dh->prepare_install;
$dh->install;

1;
