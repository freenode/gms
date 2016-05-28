#!/usr/bin/env perl

# Don't even ask, thank mst.
# Run like this: ls t/etc/**/**/*.fix  | grep -v accounts | perl bin/update_other_tables.pl

use Data::Munge qw(replace mapval list2re);
use IO::All;
use Data::Dumper;

my @dirs = qw(approved_group basic_db new_db pending_changes staff three_contacts three_groups);

foreach my $dir (@dirs) {
    my @accounts = map do($_), glob("t/etc/$dir/accounts/*.fix");
    my %id_map = map +($_->{uuid} => $_->{id}), @accounts;

    foreach my $file (mapval { chomp } <STDIN>) {
        my $data = io->file($file)->all;
        io->file($file)->print(replace($data, list2re(keys %id_map), sub { $id_map{$_[0]} }));
    }
}
