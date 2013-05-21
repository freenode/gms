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

sub search_offered {
    my ($self) = @_;

    return $self->_search_cloak_change_status ('offered');
}

=head2 search_pending

Returns a ResultSet of cloak changes that have been acepted ( by the user ),
but not approved or rejected by staff.

=cut

sub search_pending {
    my ($self) = @_;

    return $self->_search_cloak_change_status ('accepted');
}

=head2 search_unapplied

Returns a ResultSet of cloak changes that have been approved ( by staff ),
but not applied in Atheme.

=cut

sub search_unapplied {
    my ($self) = @_;

    return $self->_search_cloak_change_status ('approved');
}

=head2 search_failed

Returns a ResultSet of cloak changes that failed to be applied in
Atheme.

=cut

sub search_failed {
    my ($self) = @_;

    return $self->_search_cloak_change_status ('error');
}

=head2 last_change

Returns the newest change for the cloak change

=cut

sub last_change {
    my $self = shift;

    return $self->search({
        'me.id' => {
            '=' => $self->search ({
                  'cloak_change.id' => {  -ident => 'me.cloak_change_id' }
                },
                { alias => 'inner' }
            )->get_column('id')->max_rs->as_query
        },
    });
}

=head1 INTERNAL METHODS

=head2 _search_cloak_change_status

Returns a ResultSet of cloak changes with the given current status.

=cut

sub _search_cloak_change_status {
    my ($self, $status) = @_;

    return $self->search(
        { 'active_change.status' => $status },
        { join => 'active_change' }
    );
}

1;
