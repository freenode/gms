package RPC::Atheme;
use strict;
use warnings;

=head1 NAME

RPC::Atheme

=head1 SYNOPSIS

    my $session = RPC::Atheme::Session->new("localhost", 8080);
    $session->login($username, $password);
    $session->command('ChanServ', 'OP', '#test', $nickname);
    $session->logout;

=head1 DESCRIPTION

A wrapper around L<RPC::XML> to simplify interaction with Atheme's XML-RPC
interface.

=head1 METHODS

None; see L<RPC::Atheme::Session> and L<RPC::Atheme::Error>.

=cut

1;
