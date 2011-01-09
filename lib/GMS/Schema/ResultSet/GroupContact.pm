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

1;

