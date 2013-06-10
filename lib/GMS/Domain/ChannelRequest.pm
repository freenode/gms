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
    handles => [ qw (id request_type requestor channel request_data active_change) ]
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

1;
