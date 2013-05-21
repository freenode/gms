#!/usr/bin/env perl

use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);
use GMSTest::Common;
use GMS::Config;

my $config = GMS::Config->atheme;
my ($host, $port, $user, $pass) = @{$config}{qw/hostname port master_account master_password/};

plan skip_all => "Set GMS_TEST_RPC_ATHEME in the environment to run RPC::Atheme tests" unless $ENV{GMS_TEST_RPC_ATHEME};
plan skip_all => "Configure Model::Atheme in test config file to run RPC::Atheme tests" unless ($host && $port);

use_ok 'RPC::Atheme::Session';

my $session = RPC::Atheme::Session->new($host, $port);
isa_ok $session, 'RPC::Atheme::Session';

throws_ok {
    $session->login;
} qr /fault_nosuch_source/, 'Cannot login without details';

ok $session->login($user, $pass);

my $response;
$response = $session->command('NickServ', 'info', $user);

like $response, qr/Information on (.*) \(account \1\)/;

$session->{__authcookie} = 'invalid';
$response = $session->command('NickServ', 'info', $user);

like $response, qr/Information on (.*) \(account \1\)/, 'Bad authcookie error is ok';

# First, explicitly grab the exception object to make sure it's what we expect.
eval {
    $response = $session->command('NickServ', 'info', '#notanickname');
    fail("NickServ info on invalid nickname should have thrown");
};
my $error = $@;
isa_ok $error, 'RPC::Atheme::Error';
is $error->code, RPC::Atheme::Error::nosuchtarget();
ok !$error->succeeded;
like $error->description, qr/is not registered/;

# Later, just use the stringify/regex match.
throws_ok {
    $response = $session->command('ChanServ', 'INFO', 'invalid channel name');
} qr/fault_badparams/;

throws_ok {
    # Relies on slightly lazy validation in chanserv info. Might need fixing later,
    # but this way we know (because it's invalid) that the channel isn't registered.
    $response = $session->command('ChanServ', 'INFO', '#not registered');
} qr/fault_nosuch_target/;

ok $session->DESTROY;

$session = RPC::Atheme::Session->new($host, $port);
$session->login ($user, $pass);

undef $session->{__client};

ok !$session->logout, "Can't logout without a client.";

$session = RPC::Atheme::Session->new($host, $port);

$session->login ($user, $pass);

throws_ok {
    $session->{__username} = undef;
    $session->logout;
} qr/nosuch_source/, "Can't log out with invalid details";

$session->login ($user, $pass);

ok $session->logout;

ok !$session->logout, "Can't logout twice";

$session->login ($user, $pass);
$session = RPC::Atheme::Session->new();

is $session, 'RPC::Atheme::Session::new: Missing hostname';

$session = RPC::Atheme::Session->new($host);
is $session, 'RPC::Atheme::Session::new: Missing port number';

done_testing;
