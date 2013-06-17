package GMS::Web::Model::Client;

use strict;
use warnings;

use base 'Catalyst::Model';

=head1 NAME

GMS::Web::Model::Client

=head1 DESCRIPTION

Catalyst model for GMS::Web which wraps around an L<RPC::Atheme::Client>.


=head1 METHODS

=head2 client

Returns an L<RPC::Atheme::Client> that can carry out atheme operations.

=cut

sub client {
    my ($self, $c) = @_;

    if (!$self->{_client}) {
        return $self->{_client} = Atheme::Client->new($c->model('Atheme')->session);
    } else {
        return $self->{_client};
    }
}

=head2 ACCEPT_CONTEXT

=cut

sub ACCEPT_CONTEXT {
    my ($class, $c) = @_;

    return client ($c);
}

1;
