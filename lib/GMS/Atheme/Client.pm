package GMS::Atheme::Client;

use warnings;
use strict;

use TryCatch;
use RPC::Atheme::Error;
use GMS::Exception;
use GMS::Config;

=head1 NAME

GMS::Atheme::Client

=cut

=head1 DESCRIPTION

This class handles any GMS functionality that needs to be done
through Atheme.

=cut

=head1 METHODS

=head2 new

Constructor.
Accepts a RPC::Atheme::Session object and stores it.

=cut

sub new {
    my ($class, $session) = @_;

    my $self = { };

    $self->{_session} = $session;

    bless $self, $class;
}

=head2 metadata

Returns an account's metadata

=cut

sub metadata {
    my ($self, $uid, $metadata) = @_;
    my $session = $self->{_session};

    try {
        my $data = $session->command($session->service, 'metadata', $uid, $metadata);

        return $data;
    }
    catch (RPC::Atheme::Error $e) {
        die $e if ( $e->code != RPC::Atheme::Error::nosuchkey() );
    }
}

=head2 email

Returns an account's email

=cut

sub email {
    my ($self, $uid) = @_;
    my $session = $self->{_session};

    try {
        my $data = $session->command($session->service, 'email', $uid);

        return $data;
    }
    catch (RPC::Atheme::Error $e) {
        die $e if ( $e->code != RPC::Atheme::Error::nosuchkey() );
    }
}

=head2 mark

Returns an account's mark, if there is one

=cut

sub mark {
    my ($self, $uid) = @_;

    my $mark = $self->metadata ($uid, 'private:mark:reason');
    my $setter = $self->metadata ($uid, 'private:mark:setter');
    my $time = $self->metadata ($uid, 'private:mark:timestamp');

    if ( $mark ) {
        return [$mark, $setter, $time];
    } else {
        return undef;
    }
}

=head2 verified

Checks whether an account is verified

=cut

sub verified {
    my ($self, $uid) = @_;

    my $key = $self->metadata ($uid, 'private:verify:register:key');

    return !defined $key;
}

=head2 registered

Returns the UNIX timestamp when an account was registered

=cut

sub registered {
    my ($self, $uid) = @_;
    my $session = $self->{_session};

    return $session->command ($session->service, 'registered', $uid);
}

=head2 lastlogin

Returns the UNIX timestamp when a user was last logged in.

=cut

sub lastlogin {
    my ($self, $uid) = @_;
    my $session = $self->{_session};

    return $session->command ($session->service, 'lastlogin', $uid);
}

=head2 lastseen

Returns a human-readable date of when the user was last logged in.

=cut

sub lastseen {
    my ($self, $uid) = @_;
    my $session = $self->{_session};

    return $session->command ($session->service, 'lastseen', $uid);
}

=head2 private

Returns if the account is private.

=cut

sub private {
    my ($self, $uid) = @_;
    my $session = $self->{_session};

    my $private = $session->command ( $session->service, 'private', $uid);
    return ( $private == 1 );
}

=head2 info

Returns /ns info result.

=cut

sub info {
    my ($self, $account) = @_;
    my $session = $self->{_session};

    if (!$account) {
        die GMS::Exception->new ("Please provide an account name.");
    }

    # We want to use the session's stored log in, so we can do this as the
    # currently logged in user and not leak any info. Therefore, we don't want
    # it to try to attempt to re-login on its own if it fails due to expired
    # authcookie, because we need to manually ask the user their password.

    my $result_str = $session->command_no_login ('NickServ', 'info', $account);
    return $result_str;

}

=head2 notice_chan

Sends a notice to a channel.

=cut

sub notice_chan {
    my ( $self, $channel, @notices ) = @_;
    my $session = $self->{_session};

    return if !$channel || !scalar @notices;

    foreach my $notice (@notices) {
        $session->command($session->service, 'noticechan', $channel, $notice) if $notice;
    }
}

=head2 notice_staff_chan

Sends a notice to the configured staff channel.

=cut

sub notice_staff_chan {
    my ($self, @notices) = @_;

    my $config = GMS::Config->atheme;
    my $channel = $config->{channel};

    # Allow for disabling this...

    return if !$channel;

    return $self->notice_chan($channel, @notices);
}

=head2 memo

Sends a memo to a user.

=cut

sub memo {
    my ($self, $user, $memo) = @_;

    my $session = $self->{_session};

    return $session->command("MemoServ", "send", $user, $memo);
}

1;
