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
    my $group_rs = $self->result_source->schema->resultset('Group');

    return $self->search(
        {
            'active_change.group_id' => {
                'in' => $group_rs->search({
                        'active_change.status' => 'active',
                    },
                    { join => 'active_change' }
                )->get_column('me.id')->as_query,
            },
            'active_change.status' => 'pending_staff'
        },
        { join => 'active_change' }
    );
}

1;
