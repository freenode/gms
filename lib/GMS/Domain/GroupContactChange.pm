package GMS::Domain::GroupContactChange;

use strict;
use warnings;
use Moose;

use GMS::Domain::Account;

use GMS::Exception;
use RPC::Atheme::Error;
use TryCatch;

has _dbic_group_contact_change_row => (
    is      => 'ro',
    isa     => 'DBIx::Class::Row',
    handles => [ qw (id group_id contact_id primary status change_type affected_change) ]
);

=head1 PACKAGE

GMS::Domain::GroupContactChange

=head1 DESCRIPTION

Represents a GroupContactChange. It contains all the
database columns from the GroupContactChange table,
minus the 'changed by' field (the account
that initiated the change) which is instead
a GMS::Domain::Account object and the 'group_contact'
field which is instead a GMS::Domain::GroupContact
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
    $self->{_dbic_group_contact_change_row} = $row;

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

        my $gc_row = $row->group_contact;
        $self->{_group_contact} = GMS::Domain::GroupContact->new ( $session, $gc_row );
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

=head2 group_contact

Returns a GMS::Domain::GroupContact
object representing the change's affected
group contact.

=cut

sub group_contact {
    my ($self) = @_;

    return $self->{_group_contact};
}

=head2 TO_JSON

Returns a representative object for the JSON parser.

=cut

sub TO_JSON {
    my ($self) = @_;

    return {
        'id'                      => $self->id,
        'group_id'                => $self->group_contact->group_id,
        'group_name'              => $self->group_contact->group->group_name,
        'group_url'               => $self->group_contact->group->url,
        'contact_account_id'      => $self->group_contact->contact->account->id,
        'contact_account_name'    => $self->group_contact->contact->account->accountname,
        'contact_account_dropped' => $self->group_contact->contact->account->is_dropped,
        'status'                  => $self->status->value,
        'gc_status'               => $self->group_contact->status->value,
        'primary'                 => $self->primary,
        'gc_primary'              => $self->group_contact->active_change->primary,
        'changed_by_account_name' => $self->changed_by->accountname,
    }
}

1;
