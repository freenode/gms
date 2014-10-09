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

    my @contacts = $schema->resultset('Contact')->all;

    foreach my $contact (@contacts) {
        warn $contact->account->accountname;

        $contact->name($contact->active_change->name);
        $contact->email($contact->active_change->email);
        $contact->phone($contact->active_change->phone);

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

