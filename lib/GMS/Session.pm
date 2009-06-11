package GMS::Session;

use strict;
use warnings;

use GMS::Config;
use GMS::Schema;

use RPC::Atheme;
use RPC::Atheme::Session;

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
    ) or return "Couldn't create XML-RPC session";

    $self->{_rpcsession}->login($user, $pass, $self->{_source})
        or return "XML-RPC login failed: " . $RPC::Atheme::ERROR;

    my $accountts = $self->{_control_session}->command($GMS::Config::service, 'getregtime', $user)
        or return "Couldn't get account registration time";

    $self->{_db} = GMS::Schema->connect($GMS::Config::dbstring,
        $GMS::Config::dbuser, $GMS::Config::dbpass);
    my $account_rs = $self->{_db}->resultset('Account');

    my $account;

    eval {
        $account = $self->{_db}->txn_do( sub {
                my $result = $account_rs->find_or_create({
                        accountname => $user,
                        accountts => $accountts
                    })
            });
    };
    if ($@) {
        return "Couldn't find or create an account ID: $@";
    }

    $self->{_accountid} = $account->id;

    bless $self, $class;
}

1;
