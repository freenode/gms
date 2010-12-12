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
            address_one => 'test',
            city => 'test',
            country => 'test',
            phone => 'invalid',
            phone2 => 'invalid'
        });
};
$error = $@;
isa_ok $error, 'GMS::Exception::InvalidAddress';

is_deeply $error->message, [
    "Telephone number contains non-digit characters",
    "Alternate telephone number contains non-digit characters",
], "Test more field validation";

done_testing;
