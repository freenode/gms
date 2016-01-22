#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

my $schema = need_database 'basic_db';

eval {
    $schema->resultset('Address')->create({ });
};
my $error = $@;
isa_ok $error, 'GMS::Exception::InvalidAddress';

is_deeply $error->message, [
    "Address 1 is missing",
    "City is missing",
    "Country is missing",
    "Telephone number is missing",
], "Test field validation";

eval {
    $schema->resultset('Address')->create({
        address_one => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in dui dolor, vitae interdum lacus. Mauris rhoncus pretium sem, vel euismod quam vehicula eu. Suspendisse vitae erat ipsum, non venenatis leo. Donec diam odio, tincidunt sit amet congue nullam.',
        address_two => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in dui dolor, vitae interdum lacus. Mauris rhoncus pretium sem, vel euismod quam vehicula eu. Suspendisse vitae erat ipsum, non venenatis leo. Donec diam odio, tincidunt sit amet congue nullam.',
        city => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in dui dolor, vitae interdum lacus. Mauris rhoncus pretium sem, vel euismod quam vehicula eu. Suspendisse vitae erat ipsum, non venenatis leo. Donec diam odio, tincidunt sit amet congue nullam.',
        state => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam in dui dolor, vitae interdum lacus. Mauris rhoncus pretium sem, vel euismod quam vehicula eu. Suspendisse vitae erat ipsum, non venenatis leo. Donec diam odio, tincidunt sit amet congue nullam.',
        code => 'Lorem ipsum dolor sit amet metus.',
        phone => '012345678901234567890123456789123',
        phone2 => '012345678901234567890123456789123',
        country => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit volutpat.',
    });
};
$error = $@;
isa_ok $error, 'GMS::Exception::InvalidAddress';

is_deeply $error->message, [
    "Address 1 can be up to 255 characters.",
    "Address 2 can be up to 255 characters.",
    "City can be up to 255 characters.",
    "Phone can be up to 32 characters.",
    "Alternate Phone can be up to 32 characters.",
    "State can be up to 255 characters.",
    "Postcode can be up to 32 characters.",
    "Country can be up to 64 characters."
], "Test errors on invalid field lengths.";

ok $schema->resultset ('Address')->create({
        address_one => 'Valid datta',
        city => 'Valid data',
        state => 'Valid data',
        code => 'Valid data',
        phone => '+0(123)45-67 ex 89 ',
        country => 'Valid data',
    }), 'Inserting valid data works';

done_testing;
