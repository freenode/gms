package GMS::Web::Model::Channels;

use strict;
use warnings;
use GMS::Domain::Channels;

use base 'Catalyst::Model';

=head1 NAME

GMS::Web::Model::Channels

=head1 DESCRIPTION

Catalyst model for GMS::Web which wraps around L<GMS::Domain::Channels>.

=head1 INTERNAL_METHODS

=head2 ACCEPT_CONTEXT

Returns a new GMS::Domain::Channels object.

=cut

sub ACCEPT_CONTEXT {
    my ($class, $c) = @_;

    return GMS::Domain::Channels->new ($c->model('Atheme')->session, $c->model('DB')->schema);
}

1;
