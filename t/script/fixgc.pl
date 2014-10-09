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

    my @contacts = $schema->resultset('GroupContact')->all;

    foreach my $contact (@contacts) {
        warn $contact->contact->account->accountname;

        $contact->status($contact->active_change->status);
        $contact->primary($contact->active_change->primary);

        $contact->update;
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

