package GMS::Domain::CloakChangeChange;

use strict;
use warnings;
use Moose;

use GMS::Domain::Account;

use GMS::Exception;
use RPC::Atheme::Error;
use TryCatch;

has _dbic_cloak_change_change_row => (
    is      => 'ro',
    isa     => 'DBIx::Class::Row',
    handles => [ qw (id cloak_change_id time status change_freetext) ]
);

=head1 PACKAGE

GMS::Domain::CloakChangeChange

=head1 DESCRIPTION

Represents CloakChangeChange. It contains all the
database columns from the CloakChangeChange table,
minus the 'changed by' field (the account
that initiated the change) which is instead
a GMS::Domain::Account object, and the 'cloak_change'
feld, which is instead a GMS::Domain::CloakChange
object.

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
    $self->{_dbic_cloak_change_change_row} = $row;

    my $schema = $row->result_source->schema;

    my $accounts = GMS::Domain::Accounts->new (
        $session,
        $schema
    );

    try {
        my $account = $accounts->find_by_uid (
            $row->changed_by->id
        );

        $self->{_changed_by} = $account;

        my $cloak_change_row = $row->cloak_change;
        $self->{_cloak_change} = GMS::Domain::CloakChange->new ( $session, $cloak_change_row );
    }
    catch (GMS::Exception $e) {
        die $e;
    }
    catch (RPC::Atheme::Error $e) {
        die $e;
    }

    bless $self, $class;
}

=head2 changed_by

Returns a GMS::Domain::Account object
representing the services account of
the user who initiated the change.

=cut

sub changed_by {
    my ($self) = @_;

    return $self->{_changed_by};
}

=head2 cloak_change

Returns a GMS::Domain::CloakChange object
representing the CloakChange affected.

=cut

sub cloak_change {
    my ($self) = @_;

    return $self->{_cloak_change};
}

1;
