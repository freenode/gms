package GMS::Schema::ResultSet::Group;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head1 NAME

GMS::Schema::ResultSet::Group

=head1 DESCRIPTION

ResultSet class for Group.

=head1 METHODS

=head2 search_groups_status

Returns a ResultSet of groups with the given current status.

=cut

sub search_groups_status {
    my ($self, $status) = @_;

    return $self->search(
        { 'active_change.status' => $status },
        { join => 'active_change' }
    );
}

=head2 active_groups

Returns a ResultSet of currently active groups.

=cut

sub active_groups {
    my ($self) = @_;

    return $self->search_groups_status('active');
}

1;
