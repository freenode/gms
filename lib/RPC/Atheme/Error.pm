package RPC::Atheme::Error;

use base Error;

use strict;
use warnings;

use subs qw/new code describe stringify succeeded/;

#use overload '""' => \&stringify, 'bool' => \&succeeded;
use overload '""' => \&stringify;

=head1 NAME

RPC::Atheme::Error

=head1 DESCRIPTION

This is the error class thrown by L<RPC::Atheme::Session> when an error occurs.
It also contains symbolic names for the Atheme fault codes.

Stringifying an error object will produce a meaningful human-readable
description of the problem.

=head1 FAULT CODES

These are the symbolic names of the Atheme fault codes that can be returned
from a command handler.

=over 4

=item B<success>

=item B<needmoreparams>

=item B<nosuchsource>

=item B<nosuchtarget>

=item B<authfail>

=item B<noprivs>

=item B<nosuchkey>

=item B<alreadyexists>

=item B<toomany>

=item B<emailfail>

=item B<notverified>

=item B<nochange>

=item B<already_authed>

=item B<unimplemented>

=item B<badauthcookie>

=back

=head2 rpc_error

The special value B<rpc_error> indicates a failure in XML-RPC communications
rather than an error response from Atheme.

=cut

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

=head1 METHODS

=head2 new

Constructor. This is used by L<RPC::Atheme::Session> and will probably not be
relevant elsewhere. It takes a numeric fault code (see L</FAULT CODES> above)
and the error string from Atheme.

=cut

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

=head2 code

Returns the numeric fault code for this error.

=cut

sub code {
    my ($self) = @_;
    return $self->{_code};
}

=head2 description

Returns the textual description of the error.

=cut

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

=head2 describe

Returns the human-readable name of the numeric fault code.

=cut

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
