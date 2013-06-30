package GMS::Domain::Contact;

use strict;
use warnings;
use Moose;

use GMS::Domain::Account;
use GMS::Domain::Accounts;

use GMS::Exception;
use RPC::Atheme::Error;
use TryCatch;

has _dbic_contact_row => (
    is      => 'ro',
    isa     => 'DBIx::Class::Row',
    handles => [ qw (id account_id active_change name email phone) ]
);

=head1 PACKAGE

GMS::Domain::Contact

=head1 DESCRIPTION

Represents a Contact. It contains all the
database columns from the Contact table,
minus the account which is instead a
GMS::Domain::Account object.

=cut

=head1 METHODS

=head2 new

Constructor. Takes an Atheme session object
and a database row object.

=cut

sub new {
    my ($class, $session, $row) = @_;

    my $self = { };

    $self->{_session} = $session;
    $self->{_dbic_contact_row} = $row;

    my $schema = $row->result_source->schema;

    my $accounts = GMS::Domain::Accounts->new (
        $session,
        $schema
    );

    try {
        my $account = $accounts->find_by_uid (
            $row->account->id
        );

        $self->{_account} = $account;
    }
    catch (GMS::Exception $e) {
        die $e;
    }
    catch (RPC::Atheme::Error $e) {
        die $e;
    }

    bless $self, $class;
}

=head2 account

Returns a GMS::Domain::Account object
representing the contact's services account.

=cut

sub account {
    my ($self) = @_;

    return $self->{_account};
}

1;
