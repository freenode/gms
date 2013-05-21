package GMS::Domain::GroupContact;

use strict;
use warnings;
use Moose;

use GMS::Domain::Contact;

use GMS::Exception;
use RPC::Atheme::Error;
use TryCatch;

has _dbic_group_contact_row => (
    is      => 'ro',
    isa     => 'DBIx::Class::Row',
    handles => [ qw (id group_id contact_id status active_change group) ]
);

=head1 PACKAGE

GMS::Domain::GroupContact

=head1 DESCRIPTION

Represents a Group Contact. It contains all the
database columns from the Group Contact table,
minus the contact which is instead a
GMS::Domain::Contact object.

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
    $self->{_dbic_group_contact_row} = $row;

    try {
        my $contact_row = $row->contact;
        $self->{_contact} = GMS::Domain::Contact->new ( $session, $contact_row );
    }
    catch (RPC::Atheme::Error $e) {
        die $e;
    }
    catch (GMS::Exception $e) {
        die $e;
    }

    bless $self, $class;
}

=head2 contact

Returns a GMS::Domain::Contact object.

=cut

sub contact {
    my ($self) = @_;

    return $self->{_contact};
}

1;
