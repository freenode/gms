package GMS::Session;

use strict;
use warnings;

use GMS::Config;
use GMS::Schema;

use RPC::Atheme;
use RPC::Atheme::Session;

use TryCatch;

=head1 NAME

GMS::Session - Represents a GMS login session

=head1 SYNOPSIS

=head1 DESCRIPTION

A Session represents a GMS login session. Identification and authentication
are provided by Atheme via XML-RPC; authorization is provided in the GMS
database.

=cut

sub new {
    my ($class, $user, $pass, $controlsession, %config) = @_;

    $class = ref $class || $class;

    my $self = {
        __conf => \%config,
        _user => $user,
        _control_session => $controlsession,
    };

    $self->{_source} = "GMS:$user";
    $self->{_source} .= "(" . $config{source} . ")" if $config{source};

    $self->{_rpcsession} = RPC::Atheme::Session->new(
        $GMS::Config::atheme_host,
        $GMS::Config::atheme_port
    );

    $self->{_rpcsession}->login($user, $pass, $self->{_source});

    $self->{_db} = GMS::Schema->connect($GMS::Config::dbstring,
        $GMS::Config::dbuser, $GMS::Config::dbpass);
    my $account_rs = $self->{_db}->resultset('Account');

    my $account = undef;

    try {
        my $accountid = $self->{_control_session}->command($GMS::Config::service, 'accountid', $user);
        $account = $account_rs->find({ id => $accountid });
    }
    catch (RPC::Atheme::Error $e) {
        die $e if $e->code != RPC::Atheme::Error::nosuchkey;
        $account = undef;
    };

    if (!$account) {
        $account = $self->{_db}->txn_do( sub {
                my $result = $account_rs->create({
                        accountname => $user,
                    });
                $self->{_control_session}->command($GMS::Config::service, 'accountid',
                    $user, $account->id);
            });
    };

    if ($account->accountname ne $user) {
        $account->accountname($user);
        $account->update;
    }

    $self->{_account} = $account;

    bless $self, $class;
}

sub account {
    my ($self) = @_;
    return $self->{_account};
}

1;
