package GMS::Domain::ChannelRequest;

use strict;
use warnings;
use Moose;

use GMS::Domain::Account;

use GMS::Exception;
use RPC::Atheme::Error;
use TryCatch;

has _dbic_channel_request_row => (
    is      => 'ro',
    isa     => 'DBIx::Class::Row',
    handles => [ qw (id request_type requestor channel request_data active_change namespace) ]
);

=head1 PACKAGE

GMS::Domain::ChannelRequest

=head1 DESCRIPTION

Represents a ChannelRequest. It contains all the
database columns from the ChannelRequest table,
minus the target account which is instead a
GMS::Domain::Account object.

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
    $self->{_dbic_channel_request_row} = $row;
    $self->{_target} = undef;

    my $schema = $row->result_source->schema;

    my $accounts = GMS::Domain::Accounts->new (
        $session,
        $schema
    );

    if ( $row->target ) {
        try {
            my $account = $accounts->find_by_uid (
                $row->target->id
            );

            $self->{_target} = $account;
        }
        catch (GMS::Exception $e) {
            die $e;
        }
        catch (RPC::Atheme::Error $e) {
            die $e;
        }
    }

    bless $self, $class;
}

=head2 target

Returns a GMS::Domain::Account object
representing the request target's
services account.

=cut

sub target {
    my ($self) = @_;

    return $self->{_target};
}

=head2 TO_JSON

Returns a representative object for the JSON parser.

=cut

sub TO_JSON {
    my ($self) = @_;

    my $target_name    = undef;
    my $target_dropped = undef;
    my $target_id      = undef;
    my $target_mark    = undef;

    if ( $self->target ) {
        $target_name     = $self->target->accountname;
        $target_dropped  = $self->target->is_dropped;
        $target_id       = $self->target->id;

        if (!$target_dropped) {
            $target_mark     = $self->target->mark;
        }
    }

    return {
        'id'                => $self->id,
        'request_type'      => $self->request_type->value,
        'channel'           => $self->channel,
        'request_data'      => $self->request_data,
        'status'            => $self->active_change->status->value,
        'change_freetext'   => $self->active_change->change_freetext,
        'requestor_name'    => $self->requestor->account->accountname,
        'requestor_dropped' => $self->requestor->account->is_dropped,
        'requestor_id'      => $self->requestor->account->id,
        'target_id'         => $target_id,
        'target_name'       => $target_name,
        'target_dropped'    => $target_dropped,
        'target_mark'       => $target_mark,
        'namespace'         => $self->namespace->namespace,
        'group_name'        => $self->namespace->group->group_name,
        'group_url'         => $self->namespace->group->url,
    }
}

1;
