#!/usr/bin/perl

use FindBin;
use lib "$FindBin::Bin/../lib";

use GMS::Schema;
use GMS::Config;

use RPC::Atheme::Session;

use TryCatch;

my ($accountname, @roles_to_do) = @ARGV;

die "Usage: $0 <account name> [--add=role]  [--remove=role]\n        You can use --add=role and --remove=role multiple times" if ! $accountname;

my $atheme_config = GMS::Config->atheme;
my $db = GMS::Schema->do_connect;

my $session = RPC::Atheme::Session->new($atheme_config->{hostname},
                                        $atheme_config->{port});
$session->login($atheme_config->{master_account}, $atheme_config->{master_password})
    or die "Couldn't log in to atheme";

my $accountid = $session->command($atheme_config->{service}, 'uid', $accountname);
my $account = $db->resultset('Account')->find({ id => $accountid });

print "Found account ID ", $account->id, ", named ", $account->accountname, "\n";

foreach my $item (@roles_to_do) {
    my ($action, $rolename) = split("=", $item, 2);
    $action = lc $action;  # Lowercasing for easier parsing
    $rolename = lc $rolename; # Roles are normally lower case, right?
    my $role = $db->resultset('Role')->find({ name => $rolename });
    if ($action eq "--add") {
        if (!$role) {
            warn "No such role $rolename; creating\n";
            $role = $db->resultset('Role')->new({ name => $rolename });
            $role->insert;
        }
        try {
            $account->add_to_roles($role);
            print "Added role $rolename to $accountname\n";
        } catch {
            print "$accountname has already $rolename\n";
        }
    } elsif ($action eq "--remove") {
        if (!$role) {
            warn "No such role $rolename; so not removing...\n";
        } elsif ($account->remove_from_roles($role) == 1) {
            print "Removed role $rolename from $accountname\n";
        } else {
            print "No role $rolename on user ", $account->accountname, "\n";
        }
    } else {
        print "Unknown action: $action\n";
    }
}

