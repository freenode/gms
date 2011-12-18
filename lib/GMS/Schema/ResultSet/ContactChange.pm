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

Returns a resultset of changes that are the most recent for their contact.

=cut

sub last_changes {
    my $self = shift;

    return $self->search({
        'id' => {
            '=' => $self->search ({
                  'contact_id' => { '=' => { -ident => 'me.contact_id' } },
                },
                { alias => 'inner' }
            )->get_column('id')->max_rs->as_query
        },
    });
}


=head2 active_requests

Returns a resultset of requests that are the most recent change for their contact

=cut

sub active_requests {
    my $self = shift;

    return $self->last_changes->search ( { 'change_type' => 'request' } );
}

1;
