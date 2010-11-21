#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use GMS::Schema;
use GMS::Config;

use RPC::Atheme::Session;

my ($accountname, @roles_to_add) = @ARGV;

die "Usage: $0 <account name> <roles...>" if ! $accountname;

my $db = GMS::Schema->connect($GMS::Config::dbstring,
    $GMS::Config::dbuser, $GMS::Config::dbpass);

my $session = RPC::Atheme::Session->new($GMS::Config::atheme_host,
                                               $GMS::Config::atheme_port);
$session->login($GMS::Config::atheme_master_login, $GMS::Config::atheme_master_pass)
    or die "Couldn't log in to atheme";

my $accountid = $session->command($GMS::Config::service, 'accountid', $accountname);
my $account = $db->resultset('Account')->find({ id => $accountid });

print "Found account ID ", $account->id, ", named ", $account->accountname, "\n";

foreach my $rolename (@roles_to_add) {
    my $role = $db->resultset('Role')->find({ name => $rolename });
    if (!$role) {
        warn "No such role $rolename; ignoring.\n";
        next;
    }
    $account->add_to_roles($role);
    print "Added role $rolename\n";
}

