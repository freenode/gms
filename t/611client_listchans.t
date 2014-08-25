#!/usr/bin/perl

use strict;
use warnings;

use lib qw(t/lib);
use GMS::Atheme::Client;
use Test::More;
use Test::MockObject;

my $mockAtheme = new Test::MockObject;

$mockAtheme->mock ( 'command', sub {
    shift @_;

    my ($service, $command, $param1, $param2) = ( @_ );

    if ($service eq 'ChanServ' && $command eq 'list' && $param1 eq 'pattern') {
        if ($param2 eq '#example') {
            return "\n- #example (test)\n \n";
        } elsif ($param2 eq '#example-*') {
            return "\n- #example-1 (test)\n- #example-2 (test)\n \n";
        } elsif ($param2 eq '#test') {
            return "\n- #test (test)\n \n";
        } elsif ($param2 eq '#test-*') {
            return "\n- #test-1 (test)\n- #test-2 (test)\n \n";
        }

    }

});

$mockAtheme->mock ( 'service', sub { 'GMSServ' } );

my $client = GMS::Atheme::Client->new($mockAtheme);

my $chans = $client->listchans('#example');

is_deeply $chans, ['#example'], "Listing individual channels works";

$chans = $client->listchans('#example-*');

is_deeply $chans, ['#example-1', '#example-2'], "Listing individual channels works";

my $mockNS1 = Test::MockObject->new;
$mockNS1->mock('namespace', sub { 'example' });

my $mockNS2 = Test::MockObject->new;
$mockNS2->mock('namespace', sub { 'test' });

$chans = $client->list_group_chans(($mockNS1, $mockNS2));

is_deeply $chans, [
    '#example',
    '#example-1',
    '#example-2',
    '#test',
    '#test-1',
    '#test-2'
], 'Listing namespaces works';

done_testing;
