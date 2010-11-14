package GMS::Schema::ResultSet::Group;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub search_groups_status {
    my ($self, $status) = @_;

    return $self->search(
        { 'active_change.status' => $status },
        { join => 'active_change' }
    );
}

sub active_groups {
    my ($self) = @_;

    return $self->search_groups_status('active');
}

1;
