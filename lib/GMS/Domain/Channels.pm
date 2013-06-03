package GMS::Domain::Channels;

use strict;
use warnings;

use GMS::Domain::ChannelRequest;

use GMS::Exception;
use RPC::Atheme::Error;
use TryCatch;

=head1 PACKAGE

GMS::Domain::Channel

=head1 DESCRIPTION

Represents the collection of all channels.

=cut

=head1 METHODS

=head2 new

Constructor. Accepts an atheme session object and
a database schema object and stores the values.

=cut

sub new {
    my ($class, $session, $schema) = @_;

    my $self = {};

    $self->{_session} = $session;
    $self->{_schema} = $schema;

    bless $self, $class;
}

=head2 request

Creates a new channel request to take over
or drop the given channel if it is registered,
with the arguments provided.
If it's not registered, an error is thrown.

=cut

sub request {
    my ($self, $args) = @_;

    try {
        my $session = $self->{_session};
        my $schema = $self->{_schema};
        my $rs = $schema->resultset('ChannelRequest');

        my $client = GMS::Atheme::Client->new($session);
        my $channel = $args->{channel};

        if ( !$client->chanexists ( $channel ) ) {
            die GMS::Exception::InvalidChannelRequest->new ("$channel isn't registered!");
        }

        return $rs->create ($args);
    } catch (RPC::Atheme::Error $e) {
        die $e;
    }
}

1;
