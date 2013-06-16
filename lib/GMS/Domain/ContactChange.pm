package GMS::Domain::ContactChange;

use strict;
use warnings;
use Moose;

use GMS::Domain::Account;
use GMS::Domain::Contact;

use GMS::Exception;
use RPC::Atheme::Error;
use TryCatch;

has _dbic_contact_change_row => (
    is      => 'ro',
    isa     => 'DBIx::Class::Row',
    handles => [ qw (id contact_id time name phone email change_type affected_change change_freetext) ]
);

=head1 PACKAGE

GMS::Domain::ContactChange

=head1 DESCRIPTION

Represents a ContactChange. It contains all the
database columns from the ContactChange table,
minus the 'changed by' field (the account
that initiated the change) which is instead
a GMS::Domain::Account object,
and the contact field (the contact whose ContactChange
this is) which is instead a GMS::Domain::Contact object.

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
    $self->{_dbic_contact_change_row} = $row;

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

        my $contact_row = $row->contact;
        $self->{_contact} = GMS::Domain::Contact->new ($session, $contact_row);
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

=head2 contact

Returns a GMS::Domain::Contact object
representing the contact whose information
is being changed.

=cut

sub contact {
    my ($self) = @_;

    return $self->{_contact};
}

1;
