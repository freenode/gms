#!/usr/bin/perl

use strict;
use warnings;
use FindBin;
use Test::More;

use lib "$FindBin::Bin/../../lib";
use lib "$FindBin::Bin/../../t/lib";

use GMSTest::Common;
use GMSTest::Database;


my @sets = qw(approved_group basic_db new_db pending_changes staff three_contacts three_groups);

foreach my $set (@sets) {
    my $schema = need_database $set;

    my @changes = $schema->resultset('CloakChange')->all;
    my $changed  = 0;

    foreach my $change (@changes) {
        warn $change->cloak;
        warn $change->active_change->status;
        $change->status($change->active_change->status);
        $change->update;
    }

    my $config_dir = "$FindBin::Bin/../../t/etc";

    my $fixtures = DBIx::Class::Fixtures->new({
        config_dir => $config_dir
    });

    $fixtures->dump({
        config => "$set.json",
        schema => $schema,
        directory => "$config_dir/$set"
    });
}

