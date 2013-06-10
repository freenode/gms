package GMS::Domain::ChannelRequestChange;

use strict;
use warnings;
use Moose;

use GMS::Domain::Account;
use GMS::Domain::ChannelRequest;

use GMS::Exception;
use RPC::Atheme::Error;
use TryCatch;

has _dbic_channel_request_change_row => (
    is      => 'ro',
    isa     => 'DBIx::Class::Row',
    handles => [ qw (id channel_request_id status affected_change time change_freetext) ]
);

=head1 PACKAGE

GMS::Domain::ChannelNamespaceChange

=head1 DESCRIPTION

Represents a ChannelNamespaceChange. It contains all the
database columns from the ChannelNamespaceChange table,
minus the 'changed by' field (the account
that initiated the change) which is instead
a GMS::Domain::Account object, and the 'channel_request'
field which is instead a GMS::Domain::ChannelRequest
object.

=cut

=head1 METHODS

=head2 new

Constructor. Takes an Atheme session object
and a database row object.

=cut

sub new {
    my ($class, $session, $row) = @_;

    my $self = { };

    $self->{_session} = $session;
    $self->{_dbic_channel_request_change_row} = $row;

    my $schema = $row->result_source->schema;

    my $accounts = GMS::Domain::Accounts->new (
        $session,
        $schema
    );

    try {
        my $account = $accounts->find_by_uid (
            $row->changed_by->id
        );

        my $request = GMS::Domain::ChannelRequest->new (
            $session,
            $row->channel_request
        );

        $self->{_changed_by} = $account;
        $self->{_request} = $request;
    }
    catch (GMS::Exception $e) {
        die $e;
    }
    catch (RPC::Atheme::Error $e) {
        die $e;
    }

    bless $self, $class;
}

=head2 changed_by

Returns a GMS::Domain::Account object
representing the services account of
the user who initiated the change.

=cut

sub changed_by {
    my ($self) = @_;

    return $self->{_changed_by};
}

=head2 channel_request

Returns a GMS::Domain::ChannelRequest object
representing the channel request that's being changed.

=cut

sub channel_request {
    my ($self) = @_;

    return $self->{_request};
}

1;
