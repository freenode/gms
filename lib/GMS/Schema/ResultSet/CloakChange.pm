package GMS::Schema::ResultSet::CloakChange;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head1 NAME

GMS::Schema::ResultSet::CloakChange

=head1 DESCRIPTION

ResultSet class for CloakChange.

=head1 METHODS

=head2 search_offered

Returns a resultset of cloak changes that have been offered but not accepted
or rejected.

=cut

sub search_created {
    my ($self) = @_;

    return $self->search(
        {
            'accepted' => undef,
            'rejected' => undef
        }
    );
}

=head2 search_pending

Returns a ResultSet of cloak changes that have been acepted ( by the user ),
but not approved or rejected by staff.

=cut

sub search_pending {
    my ($self) = @_;

    return $self->search(
        {
            'accepted' => { '!=', undef },
            'approved' => undef,
            'rejected' => undef
        }
    );
}

1;
