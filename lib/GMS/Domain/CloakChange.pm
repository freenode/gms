package GMS::Domain::CloakChange;

use strict;
use warnings;
use Moose;

use GMS::Domain::Account;
use GMS::Domain::Accounts;

use GMS::Exception;
use RPC::Atheme::Error;
use TryCatch;

has _dbic_cloak_change_row => (
    is      => 'ro',
    isa     => 'DBIx::Class::Row',
    handles => [ qw (id cloak active_change namespace) ]
);

=head1 PACKAGE

GMS::Domain::CloakChange

=head1 DESCRIPTION

Represents a CloakChange. It contains all the
database columns from the CloakChange table,
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
    $self->{_dbic_cloak_change_row} = $row;

    my $schema = $row->result_source->schema;

    my $accounts = GMS::Domain::Accounts->new (
        $session,
        $schema
    );

    try {
        my $target_account = $accounts->find_by_uid (
            $row->target->id
        );

        my $requestor_account = $accounts->find_by_uid(
            $row->requestor->id
        );

        $self->{_target} = $target_account;
        $self->{_requestor} = $requestor_account;
    }
    catch (GMS::Exception $e) {
        die $e;
    }
    catch (RPC::Atheme::Error $e) {
        die $e;
    }

    bless $self, $class;
}

=head2 requestor

Returns a GMS::Domain::Account object
representing the requestor's
services account.

=cut

sub requestor {
    my ($self) = @_;

    return $self->{_requestor};
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

    my @changes = $self->target->recent_cloak_changes->all;
    my @recent;

    #We can't directly use @changes, as it'll cause an infinite recursion,
    #but we don't want all the change data anyway.
    foreach my $change (@changes) {
        push @recent, {
            'cloak'       => $change->cloak,
            'change_time' => $change->active_change->time,
        }
    }

    my $target_name    = undef;
    my $target_dropped = undef;
    my $target_id      = undef;
    my $target_uuid    = undef;
    my $target_mark    = undef;

    my $req_name    = undef;
    my $req_dropped = undef;
    my $req_id      = undef;
    my $req_uuid    = undef;
    my $req_mark    = undef;

    if ( $self->target ) {
        $target_name     = $self->target->accountname;
        $target_dropped  = $self->target->is_dropped;
        $target_id       = $self->target->id;
        $target_uuid     = $self->target->uuid;

        if (!$target_dropped) {
            $target_mark     = $self->target->mark;
        }
    }

    if ( $self->requestor ) {
        $req_name     = $self->requestor->accountname;
        $req_dropped  = $self->requestor->is_dropped;
        $req_id       = $self->requestor->id;
        $req_uuid     = $self->requestor->uuid;

        if (!$req_dropped) {
            $req_mark     = $self->requestor->mark;
        }
    }

    return {
        'id'                          => $self->id,
        'cloak'                       => $self->cloak,

        'target_id'                   => $target_id,
        'target_uuid'                 => $target_uuid,
        'target_name'                 => $target_name,
        'target_dropped'              => $target_dropped,
        'target_mark'                 => $target_mark,
        'target_recent_cloak_changes' => \@recent,

        'requestor_id'                => $req_id,
        'requestor_uuid'              => $req_uuid,
        'requestor_name'              => $req_name,
        'requestor_dropped'           => $req_dropped,
        'requestor_mark'              => $req_mark,

        'status'                      => $self->active_change->status->value,
        'change_freetext'             => $self->active_change->change_freetext,
        'change_time'                 => $self->active_change->time,
        'group_name'                  => $self->namespace->group->group_name,
        'group_url'                   => $self->namespace->group->url,
        'namespace'                   => $self->namespace->namespace,
    }
}

1;
