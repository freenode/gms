package GMS::Schema::ResultSet::CloakNamespaceChange;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

=head1 NAME

GMS::Schema::ResultSet::CloakNamespaceChange

=head1 DESCRIPTION

ResultSet class for CloakNamespaceChange.

=head1 METHODS

=head2 last_changes

Returns a resultset of changes that are the newer than their cloak namespace's active change.

=cut

sub last_changes {
    my $self = shift;

    my $namespace_rs = $self->result_source->schema->resultset('CloakNamespace');

    return $self->search({
        'me.id' => {
            '>=' => $namespace_rs->search ({
                  'id' => { '=' => { -ident => 'me.namespace_id' } }
                },
                { alias => 'inner' }
            )->get_column('active_change')->as_query
        },
    });
}

=head2 active_requests

Returns a resultset of requests that are newer than their cloak namespace's active change.

=cut

sub active_requests {
    my $self = shift;

    return $self->last_changes->search ( { 'change_type' => 'request' } );
}

1;
