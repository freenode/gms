package GMS::Schema::ResultSet::GroupChange;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

=head1 NAME

GMS::Schema::ResultSet::GroupChange

=head1 DESCRIPTION

ResultSet class for GroupChange.

=head1 METHODS

=head2 last_changes

Returns a resultset of changes that are the newer than their group's active change.

=cut

sub last_changes {
    my $self = shift;

    my $group_rs = $self->result_source->schema->resultset('Group');

    return $self->search({
        'me.id' => {
            '>=' => $group_rs->search ({
                  'id' => { '=' => { -ident => 'me.group_id' } }
                },
                { alias => 'inner' }
            )->get_column('active_change')->as_query
        },
    });
}

=head2 active_requests

Returns a resultset of requests that are newer than their group's active change.

=cut

sub active_requests {
    my $self = shift;

    return $self->last_changes->search ( { 'change_type' => 'request' } );
}

1;
