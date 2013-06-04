package GMS::Domain::Accounts;

use strict;
use warnings;

use GMS::Domain::Account;

use GMS::Exception;
use RPC::Atheme::Error;
use TryCatch;

=head1 PACKAGE

GMS::Domain::Accounts

=head1 DESCRIPTION

Represents the collection of all accounts.

=cut

=head1 METHODS

=head2 new

Constructor. Accepts an atheme session object and
a database schema object and stores the values.

=cut

sub new {
    my ($class, $session, $schema) = @_;

    my $self = {};

    $self->{_session} = $session;
    $self->{_schema} = $schema;

    bless $self, $class;
}

=head2 find_by_uid

Queries Atheme to find an account with the
provided uid. The GMS database is updated
accordingly, and a new GMS::Domain::Account
object is returned.
Throws an error if no such account could be
found.

=cut

sub find_by_uid {
    my ($self, $uid) = @_;

    if (!$uid) {
        die GMS::Exception->new ("Please provide a user id");
    }

    my $schema = $self->{_schema};
    my $account_rs = $schema->resultset('Account');
    my $account = $account_rs->find ({ 'id' => $uid });

    return $account if $account && $account->dropped;

    try {
        my $session = $self->{_session};
        my $name = $session->command ($session->service, 'accountname', $uid);

        my $row = $account_rs->find_or_new (
            {
                'id' => $uid
            }
        );

        $row->accountname ($name);
        my $result = $row->insert_or_update;

        return GMS::Domain::Account->new ($uid, $name, $session, $result);
    } catch (RPC::Atheme::Error $e) {
        if ($e->code == RPC::Atheme::Error::nosuchtarget) {
            if ( $account ) {
                $account->dropped(1);
                $account->update;
                return $account;
            }

            else {
                die GMS::Exception->new ("Could not find an account with that UID.");
            }
        } else {
            die $e;
        }
    }
}

=head2 find_by_name

Queries Atheme to find an account with the
provided account name. The GMS database is
updated accordingly, and a new
GMS::Domain::Account object is returned.
Throws an error if no such account could be
found.

=cut

sub find_by_name {
    my ($self, $name) = @_;

    if (!$name) {
        die GMS::Exception->new("Please provide an account name");
    }

    try {
        my $session = $self->{_session};
        my $schema = $self->{_schema};

        my $uid = $session->command ($session->service, 'uid', $name);

        # get the account name from atheme, in case this was somehow
        # called with a grouped nick.
        $name   = $session->command ($session->service, 'accountname', $uid);

        my $row = $schema->resultset('Account')->find_or_new (
            {
                'id' => $uid
            }
        );

        $row->accountname ($name);
        my $result = $row->insert_or_update;

        return GMS::Domain::Account->new ($uid, $name, $session, $result);
    } catch (RPC::Atheme::Error $e) {
        if ($e->code == RPC::Atheme::Error::nosuchtarget) {
            die GMS::Exception->new ("Could not find an account with that account name.");
        } else {
            die $e;
        }
    }
}

1;
