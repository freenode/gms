package GMS::Schema::ResultSet::ChannelRequest;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head1 NAME

GMS::Schema::ResultSet::ChannelRequest

=head1 DESCRIPTION

ResultSet class for ChannelRequest.

=head1 METHODS

=head2 search_unapproved

Returns a ResultSet of channel requests that have not been approved
or rejected by staff.

=cut

sub search_unapproved {
    my ($self) = @_;

    return $self->_search_channel_request_status ('pending_staff');
}

=head2 search_pending

Returns a ResultSet of channel requests pending staff action.

=cut

sub search_pending {
    my ($self) = @_;

    return $self->_search_channel_request_status ( ['pending_staff', 'error'] );
}

=head2 search_unapplied

Returns a ResultSet of channel requests that have been approved by staff,
but not applied in Atheme.

=cut

sub search_unapplied {
    my ($self) = @_;

    return $self->_search_channel_request_status ('approved');
}

=head2 search_failed

Returns a ResultSet of cloak changes that failed to be applied in
Atheme.

=cut

sub search_failed {
    my ($self) = @_;

    return $self->_search_channel_request_status ('error');
}

=head1 INTERNAL METHODS

=head2 _search_channel_request_statuss

Returns a ResultSet of channel requests with the given current status.

=cut

sub _search_channel_request_status {
    my ($self, $status) = @_;

    my $namespace_rs = $self->result_source->schema->resultset('ChannelNamespace');

    return $self->search(
        {
            'active_change.status' => $status,
            'me.namespace_id' => {
                'in' => $namespace_rs->search({
                        'active_change.status' => 'active',
                    },
                    { join => 'active_change' }
                )->get_column('me.id')->as_query,
            },
        },
        { join => 'active_change' }
    );
}

1
