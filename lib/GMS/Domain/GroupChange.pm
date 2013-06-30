package GMS::Domain::GroupChange;

use strict;
use warnings;
use Moose;

use GMS::Domain::Account;

use GMS::Exception;
use RPC::Atheme::Error;
use TryCatch;

has _dbic_group_change_row => (
    is      => 'ro',
    isa     => 'DBIx::Class::Row',
    handles => [ qw (id group_id time change_type group_type url address status affected_change change_freetext group address) ]
);

=head1 PACKAGE

GMS::Domain::GroupChange

=head1 DESCRIPTION

Represents a GroupChange. It contains all the
database columns from the GroupChange table,
minus the 'changed by' field (the account
that initiated the change) which is instead
a GMS::Domain::Account object, and the
'group' field, which is instead a
GMS::Domain::Group object.

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
    $self->{_dbic_group_change_row} = $row;

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

=head2 TO_JSON

Returns a representative object for the JSON parser.

=cut

sub TO_JSON {
    my ($self) = @_;

    return {
        'id'                      => $self->id,
        'group_id'                => $self->group->id,
        'group_name'              => $self->group->group_name,
        'url'                     => $self->url,
        'group_url'               => $self->group->url,
        'type'                    => $self->group_type->value,
        'group_type'              => $self->group->group_type->value,
        'address'                 => $self->address,
        'group_address'           => $self->group->address,
        'changed_by_account_name' => $self->changed_by->accountname,
    }
}

1;
