package GMS::Schema::ResultSet::CloakNamespace;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head1 NAME

GMS::Schema::ResultSet::CloakNamespace;

=head1 DESCRIPTION

ResultSet class for CloakNamespace.

=head1 METHODS

=head2 search_pending

Returns a ResultSet of cloak namespaces pending approval.

=cut

sub search_pending {
    my ($self) = @_;

    return $self->search(
        { 'active_change.status' => 'pending-staff' },
        { join => 'active_change' }
    );
}

1;
