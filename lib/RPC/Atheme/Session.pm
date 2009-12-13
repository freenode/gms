package RPC::Atheme::Session;
use strict;

use subs qw(new DESTROY login command logout);

use TryCatch;

use RPC::XML;
use RPC::XML::Client;
use RPC::Atheme;
use RPC::Atheme::Error;

sub new {
    my ($class, $host, $port, %attrs) = @_;

    $class = ref $class || $class;

    return "${class}::new: Missing hostname" unless $host;
    return "${class}::new: Missing port number" unless $port;

    my $self = { };

    $self->{__url} = "http://" . $host . ":" . $port . "/xmlrpc";

    $self->{__client} = RPC::XML::Client->new($self->{__url});
    die RPC::Atheme::Error->new(RPC::Atheme::Error::rpc_error, $RPC::XML::ERROR)
        unless $self->{__client};

    bless $self, $class;
}

sub DESTROY {
    my ($self) = @_;
    if ($self->{__authcookie}) {
        $self->logout;
    }
}

sub login {
    my ($self, $user, $pass, $source) = @_;

    $self->{__username} = $user if $user;
    $self->{__password} = $pass if $pass;
    $self->{__source} = $source if $source;

    my $response = $self->{__client}->simple_request(
        'atheme.login', $user, $pass, $source
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

sub do_command {
    my ($self, @args) = @_;

    my $result = $self->{__client}->simple_request(
        'atheme.command',
        $self->{__authcookie},
        $self->{__username},
        $self->{__source},
        @args
    );

    die RPC::Atheme::Error->new(RPC::Atheme::Error::rpc_error, $RPC::XML::ERROR) unless $result;
    die RPC::Atheme::Error->new($result) if ref $result eq 'HASH';
    return $result;
}

sub logout {
    my ($self) = @_;
    return unless $self->{__authcookie};

    my $result = $self->{__client}->simple_request(
        'atheme.logout', $self->{__authcookie}, $self->{__username});

    die RPC::Atheme::Error->new(RPC::Atheme::Error::rpc_error, $RPC::XML::ERROR) unless $result;
    die RPC::Atheme::Error->new($result) if ref $result eq 'HASH';
    return $result;
}

1;
