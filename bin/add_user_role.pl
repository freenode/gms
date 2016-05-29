#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use GMS::Schema;
use GMS::Config;

use RPC::Atheme::Session;

my ($accountname, @roles_to_add) = @ARGV;

die "Usage: $0 <account name> <roles...>" if ! $accountname;

my $atheme_config = GMS::Config->atheme;
my $db = GMS::Schema->do_connect;

my $session = RPC::Atheme::Session->new($atheme_config->{hostname},
                                        $atheme_config->{port});
$session->login($atheme_config->{master_account}, $atheme_config->{master_password})
    or die "Couldn't log in to atheme";

my $accountid = $session->command($atheme_config->{service}, 'uid', $accountname);
my $account = $db->resultset('Account')->find({ uuid => $accountid });

print "Found account ID ", $account->id, ", named ", $account->accountname, "\n";

foreach my $rolename (@roles_to_add) {
    my $role = $db->resultset('Role')->find({ name => $rolename });
    if (!$role) {
        warn "No such role $rolename; creating\n";
        $role = $db->resultset('Role')->new({ name => $rolename });
        $role->insert;
    }
    $account->add_to_roles($role);
    print "Added role $rolename\n";
}

