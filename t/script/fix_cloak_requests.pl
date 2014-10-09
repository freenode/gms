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

    my @requests = $schema->resultset('CloakChange')->all;
    my $changed  = 0;

    foreach my $request (@requests) {
        my @parts = split /\//, $request->cloak;
        my $cloak = $parts[0];

        warn "$cloak\n";

        my $namespace = $schema->resultset('CloakNamespace')->find({
                namespace => $cloak
            });

        if ($namespace) {
            print "updating " . $cloak . "\n";
            $request->namespace_id($namespace->id);
            $request->update;
            $changed = 1;
        }
    }

    if ($changed) {
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
}

