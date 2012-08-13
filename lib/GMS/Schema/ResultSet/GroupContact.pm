package GMS::Schema::ResultSet::GroupContact;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

=head1 NAME

GMS::Schema::ResultSet::GroupContact

=head1 DESCRIPTION

ResultSet class for GroupContact.

=head1 METHODS

=head2 search_status

Returns a ResultSet of group contacts with the given current status.

=cut

sub search_status {
    my ($self, $status) = @_;

    return $self->search(
        { 'active_change.status' => $status },
        { join => 'active_change' }
    );
}

=head2 search_pending

Returns a ResultSet of group contacts pending staff acceptance.

=cut

sub search_pending {
    my ($self) = @_;

    return $self->search_status ('pending_staff');
}

=head2 find_by_id

Takes an id in the format of contact->id_group->id,
splits it and finds the group contact with the specified
contact & group id combination.

=cut

sub find_by_id {
    my ($self, $id) = @_;

    my ($contact_id, $group_id) = split /\_/, $id;

    return $self->find({
        'contact_id' => $contact_id,
        'group_id' => $group_id
    });
}

1;
