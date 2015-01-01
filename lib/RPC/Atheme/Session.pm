package RPC::Atheme::Session;
use strict;

use subs qw(new DESTROY login command logout);

use TryCatch;

use RPC::XML;
use RPC::XML::Client;
use RPC::Atheme;
use RPC::Atheme::Error;

=head1 NAME

RPC::Atheme::Session

=head1 SYNOPSIS

    my $session = RPC::Atheme::Session->new("localhost", 8080);
    $session->login($username, $password);
    $session->command('ChanServ', 'OP', '#test', $nickname);
    $session->logout;

=head1 DESCRIPTION

An Atheme XML-RPC login session.

=head1 METHODS

=head2 new

    my $session = RPC::Atheme::Session->new("localhost", 8080);

Constructor. Takes the hostname and port number of an Atheme XML-RPC server.
This method will connect to the services daemon, but not log in or execute any
commands. Throws L<RPC::Atheme::Error> on failure.

=cut

sub new {
    my ($class, $host, $port, $service, $attrs) = @_;

    $class = ref $class || $class;

    return "${class}::new: Missing hostname" unless $host;
    return "${class}::new: Missing port number" unless $port;

    my $self = { };

    $self->{_service} = $service;

    $self->{__url} = "http://" . $host . ":" . $port . "/xmlrpc";

    $self->{__client} = RPC::XML::Client->new($self->{__url});
    die RPC::Atheme::Error->new(RPC::Atheme::Error::rpc_error, $RPC::XML::ERROR)
        unless $self->{__client};

    $self->{__authcookie} = $attrs->{'authcookie'} if $attrs->{'authcookie'};
    $self->{__username} = $attrs->{'username'} if $attrs->{'username'};
    $self->{__persistent} = $attrs->{'persistent'} || 0;

    $self->{__source} = '::0';

    bless $self, $class;
}

sub DESTROY {
    my ($self) = @_;
    if ($self->{__authcookie} && !$self->{__persistent}) {
        $self->logout;
    }
}

=head2 authcookie

Returns the authcookie.

=cut

sub authcookie {
    my ($self) = @_;

    return $self->{__authcookie};
}

=head2 login

    $session->login($user, $password, $sourceinfo);

Logs in using the specified username and password. The third parameter,
C<$sourceinfo>, which defaults to '::0', is an optional string to be included
in the source text in Atheme's log system.

Throws L<RPC::Atheme::Error> on failure.

=cut

sub login {
    my ($self, $user, $pass, $source) = @_;

    $self->{__username} = $user if $user;
    $self->{__password} = $pass if $pass;
    $self->{__source} = $source || $self->{__source};

    my $response = $self->{__client}->simple_request(
        'atheme.login', $self->{__username}, $self->{__password}, $self->{__source}
    );

    if (! defined $response) {
        die RPC::Atheme::Error->new(RPC::Atheme::Error::rpc_error, $RPC::XML::ERROR);
    }

    if (ref $response) {
        die RPC::Atheme::Error->new($response);
    }

    $self->{__authcookie} = $response;

    return 1;
}

=head2 command

    $session->command('ChanServ', 'OP', '#test', $nickname);

Sends the given command to the named service. See the documentation for
C<atheme.command> in the Atheme source distribution for invocation of specific
commands, in particular the argument list and return values. The first two
arguments are always the service name and command name; further arguments depend
on the particular command being invoked. Note in particular that not all
commands have a convenient return value when invoked via XML-RPC.

Throws L<RPC::Atheme::Error> on failure.

=cut

sub command {
    my ($self, @args) = @_;

    my $result;

    try {
        $result = $self->do_command(@args);
    } catch (RPC::Atheme::Error $e) {
        die $e if $e->code != RPC::Atheme::Error::badauthcookie;

        # If we got here, the error was a bad authcookie, which most likely
        # means our session timed out. Log in again and retry.
        $self->login;
        $result = $self->do_command(@args);
    }
    return $result;
}

=head2 command_no_login

Same as L</command>, except dies for any reason, even if the authcookie is not
valid.

=cut

sub command_no_login {
    my ($self, @args) = @_;

    return $self->do_command(@args);
}

=head2 do_command

Used internally by C<command>.

=cut

sub do_command {
    my ($self, @args) = @_;

    my $result = $self->{__client}->simple_request(
        'atheme.command',
        $self->{__authcookie},
        $self->{__username},
        $self->{__source},
        @args
    );

    die RPC::Atheme::Error->new(RPC::Atheme::Error::rpc_error, $RPC::XML::ERROR) unless defined $result;
    die RPC::Atheme::Error->new($result) if ref $result eq 'HASH';
    return $result;
}

=head2 logout

Logs out of this session.

=cut

sub logout {
    my ($self) = @_;
    return unless $self->{__authcookie};
    return unless $self->{__client};

    my $result = $self->{__client}->simple_request(
        'atheme.logout', $self->{__authcookie}, $self->{__username});

    die RPC::Atheme::Error->new(RPC::Atheme::Error::rpc_error, $RPC::XML::ERROR) unless $result;
    die RPC::Atheme::Error->new($result) if ref $result eq 'HASH';

    # Delete __authcookie so we don't try to logout in DESTROY
    delete $self->{__authcookie};

    return $result;
}

=head2 service

Returns the name of the GMS service.

=cut

sub service {
    my ($self) = @_;

    $self->{_service};
}

1;
