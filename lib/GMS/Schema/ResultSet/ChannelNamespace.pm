package GMS::Schema::ResultSet::ChannelNamespace;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head1 NAME

GMS::Schema::ResultSet::ChannelNamespace;

=head1 DESCRIPTION

ResultSet class for ChannelNamespace.

=head1 METHODS

=head2 search_pending

Returns a ResultSet of channel namespaces pending approval.

=cut

sub search_pending {
    my ($self) = @_;

    return $self->search(
        { 'active_change.status' => 'pending-staff' },
        { join => 'active_change' }
    );
}

1;
