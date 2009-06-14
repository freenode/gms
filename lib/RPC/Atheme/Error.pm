package RPC::Atheme::Error;

use base Error;

use strict;
use warnings;

use subs qw/new code describe stringify succeeded/;

use overload '""' => \&stringify, 'bool' => \&succeeded;

use constant {
    success          => 0,

    needmoreparams   => 1,
    badparams        => 2,
    nosuchsource     => 3,
    nosuchtarget     => 4,
    authfail         => 5,
    noprivs          => 6,
    nosuchkey        => 7,
    alreadyexists    => 8,
    toomany          => 9,
    emailfail        => 10,
    notverified      => 11,
    nochange         => 12,
    already_authed   => 13,
    unimplemented    => 14,
    badauthcookie    => 15,

    rpc_error        => -1,
};

sub new {
    my ($class, $code, $string) = @_;
    $class = ref $class || $class;

    my $self;

    if (ref $code eq 'HASH') {
        $self = {
            _code => $code->{faultCode},
            _string => $code->{faultString}
        };
    } else {
        $self = {
            _code => $code,
            _string => $string
        };
    }

    bless $self, $class
}

sub code {
    my ($self) = @_;
    return $self->{_code};
}

sub description {
    my ($self) = @_;
    return $self->{_string};
}

sub stringify {
    my ($self) = @_;
    return $self->{_string} . " (" . describe($self->{_code}) . ")";
}

sub succeeded {
    my ($self) = @_;
    return $self->{_code} == success;
}

sub describe {
    my ($_code) = @_;
    my %descriptions = (
        success() => "success",

        needmoreparams() => "fault_needmoreparams",
        badparams() => "fault_badparams",
        nosuchsource() => "fault_nosuch_source",
        nosuchtarget() => "fault_nosuch_target",
        authfail() => "fault_authfail",
        noprivs() => "fault_noprivs",
        nosuchkey() => "fault_nosuch_key",
        alreadyexists() => "fault_alreadyexists",
        toomany() => "fault_toomany",
        emailfail() => "fault_emailfail",
        notverified() => "fault_notverified",
        nochange() => "fault_nochange",
        already_authed() => "fault_alreadyauthed",
        unimplemented() => "fault_unimplemented",
        badauthcookie() => "fault_badauthcookie",

        rpc_error() => "XML-RPC error"
    );

    return $descriptions{$_code};
}

1;
