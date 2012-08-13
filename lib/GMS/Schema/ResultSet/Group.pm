package GMS::Schema::ResultSet::Group;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head1 NAME

GMS::Schema::ResultSet::Group

=head1 DESCRIPTION

ResultSet class for Group.

=head1 METHODS

=head2 search_submitted_groups

Returns a ResultSet of currently submitted groups.

=cut

sub search_submitted_groups {
    my ($self) = @_;

    return $self->_search_groups_status('pending_staff');
}

=head2 search_verified_groups

Returns a ResultSet of currently verified groups.

=cut

sub search_verified_groups {
    my ($self) = @_;

    return $self->_search_groups_status(['pending_auto', 'verified']);
}

=head2 search_active_groups

Returns a ResultSet of currently active groups.

=cut

sub search_active_groups {
    my ($self) = @_;

    return $self->_search_groups_status('active');
}

=head1 INTERNAL METHODS

=head2 _search_groups_status

Returns a ResultSet of groups with the given current status.

=cut

sub _search_groups_status {
    my ($self, $status) = @_;

    return $self->search(
        { 'active_change.status' => $status },
        { join => 'active_change' }
    );
}

1;
