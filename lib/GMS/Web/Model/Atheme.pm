package GMS::Web::Model::Atheme;

use strict;
use warnings;

use base 'Catalyst::Model';

use RPC::Atheme::Session;

=head1 NAME

GMS::Web::Model::Atheme

=head1 DESCRIPTION

Catalyst model for GMS::Web which wraps around an L<RPC::Atheme::Session>.

=head1 METHODS

=head2 session

Returns an L<RPC::Atheme::Session> logged in as the configured GMS account.

=head1 INTERNAL METHODS

=head2 start_session

Creates a session object and logs in, then returns it. Should only be called
internally by L</session>.

=cut

sub start_session {
    my ($self) = @_;

    if ($self->{_session}) {
        $self->{_session}->logout;
        undef $self->{_session};
    }

    my $session = RPC::Atheme::Session->new(
        $self->{hostname}, $self->{port}, $self->{service}
    );

    $session->login(
        $self->{master_account}, $self->{master_password}, "GMS:internal"
    );

    $self->{_session} = $session;

    return $session;
}

sub session {
    my ($self) = @_;
    if ($self->{_session}) {
        return $self->{_session};
    }
    return $self->start_session;
}

1;
