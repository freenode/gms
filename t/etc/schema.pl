#!/usr/bin/perl
# Configuration for Test::DBIx::Class to set up test database

{
    schema_class => 'GMS::Schema',
    resultsets => [
        'Account', 'Contact', 'GroupContact', 'Group'
    ],
    fixture_sets => {
        basic => {
            Account => [
                [ 'id', 'accountname' ],
                [ 1, 'test01' ],
                [ 2, 'test02' ],
            ],
        },
    },
};
