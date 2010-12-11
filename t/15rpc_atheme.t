#!/usr/bin/env perl

use strict;
use warnings;
use Test::Most;

use GMS::Config;

my $config = GMS::Config->atheme;
my ($host, $port, $user, $pass) = @{$config}{qw/hostname port master_account master_password/};

plan skip_all => "Configure Model::Atheme in test config file to run RPC::Atheme tests" unless ($host && $port);

use_ok 'RPC::Atheme::Session';

my $session = RPC::Atheme::Session->new($host, $port);
isa_ok $session, 'RPC::Atheme::Session';

ok $session->login($user, $pass);

my $response;
$response = $session->command('NickServ', 'info', $user);

like $response, qr/Information on (.*) \(account \1\)/;

# First, explicitly grab the exception object to make sure it's what we expect.
eval {
    $response = $session->command('NickServ', 'info', '#notanickname');
    fail("NickServ info on invalid nickname should have thrown");
};
my $error = $@;
isa_ok $error, 'RPC::Atheme::Error';
is $error->code, RPC::Atheme::Error::nosuchtarget();

# Later, just use the stringify/regex match.
throws_ok {
    $response = $session->command('ChanServ', 'INFO', 'invalid channel name');
} qr/fault_badparams/;

throws_ok {
    # Relies on slightly lazy validation in chanserv info. Might need fixing later,
    # but this way we know (because it's invalid) that the channel isn't registered.
    $response = $session->command('ChanServ', 'INFO', '#not registered');
} qr/fault_nosuch_target/;

done_testing;
