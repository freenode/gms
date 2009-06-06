package RPC::Atheme::Session;
use strict;

use subs qw(new DESTROY login command logout);

require RPC::XML;
require RPC::XML::Client;

sub new {
    my ($class, $host, $port, %attrs) = @_;

    $class = ref $class || $class;

    return "${class}::new: Missing hostname" unless $host;
    return "${class}::new: Missing port number" unless $port;

    my $self = { };

    $self->{__url} = "http://" . $host . ":" . $port . "/xmlrpc";

    $self->{__client} = RPC::XML::Client->new($self->{__url});
    return "${class}::new: Couldn't create RPC::XML::Client object" unless $self->{__client};

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

    $self->{__username} = $user;
    $self->{__source} = $source;

    $self->{__authcookie} = $self->{__client}->simple_request(
        'atheme.login', $user, $pass, $source
    );

    if (! defined $self->{__authcookie}) {
        $RPC::Atheme::ERROR = $RPC::XML::ERROR;
        return 0;
    }

    if (ref $self->{__authcookie}) {
        $RPC::Atheme::ERROR = "Too much response from atheme.login";
        return 0;
    }
}

sub command {
    my ($self, @args) = @_;

    $self->{__client}->simple_request(
        'atheme.command',
        $self->{__authcookie},
        $self->{__username},
        $self->{__source},
        @args
    );
}

sub logout {
    my ($self) = @_;
    return unless $self->{__authcookie};

    $self->{__client}->simple_request('atheme.logout', $self->{__authcookie}, $self->{__username});
}

1;
