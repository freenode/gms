package GMS::Schema::ResultSet::ContactChange;


use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

=head1 NAME

GMS::Schema::ResultSet::ContactChange

=head1 DESCRIPTION

ResultSet class for ContactChange.

=head1 METHODS

=head2 last_changes

Returns a resultset of changes that are the newer than their contact's active change.

=cut

sub last_changes {
    my $self = shift;

    my $contact_rs = $self->result_source->schema->resultset('Contact');

    return $self->search({
        'me.id' => {
            '>=' => $contact_rs->search ({
                  'id' => { '=' => { -ident => 'me.contact_id' } }
                },
                { alias => 'inner' }
            )->get_column('active_change')->as_query
        },
    });
}

=head2 active_requests

Returns a resultset of requests that are newer than their contact's active change.

=cut

sub active_requests {
    my $self = shift;

    return $self->last_changes->search ( { 'change_type' => 'request' } );
}

1;
