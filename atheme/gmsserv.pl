use Atheme;
use Atheme::Fault qw/:all/;

%Info = (
    name => 'gmsserv.pl',
);

$Services{GMSServ};

$Services{GMSServ}->bind_command(
    name => "UID",
    desc => "Returns a user's UID",
    help_path => "gmsserv/uid",
    handler => \&gms_uid,
    access => "special:gms"
);

$Services{GMSServ}->bind_command(
    name => "DROP",
    desc => "Forces dropping a channel",
    help_path => "gmsserv/drop",
    handler => \&gms_drop,
    access => "special:gms"
);

$Services{GMSServ}->bind_command(
    name => "TRANSFER",
    desc => "Forces transferring a channel",
    help_path => "gmsserv/transfer",
    handler => \&gms_transfer,
    access => "special:gms"
);

$Services{GMSServ}->bind_command(
    name => "CLOAK",
    desc => "Cloaks a user",
    help_path => "gmsserv/cloak",
    handler => \&gms_cloak,
    access => "special:gms"
);

$Services{GMSServ}->bind_command(
    name => "METADATA",
    desc => "Returns metadata on a user",
    help_path => "gmsserv/metadata",
    handler => \&gms_metadata,
    access => "special:gms"
);

$Services{GMSServ}->bind_command(
    name => "ACCOUNTNAME",
    desc => "Returns a user's account name from their UID",
    help_path => "gmssrv/accountname",
    handler => \&gms_accountname,
    access => "special:gms"
);

$Services{GMSServ}->bind_command(
    name => "CHANEXISTS",
    desc => "Returns 1 if a channel exists, -1 if not.",
    help_path => "gmsserv/chanexists",
    handler => \&gms_chanexists,
    access => "special:gms"
);

$Services{GMSServ}->bind_command(
    name => "CHANREGISTERED",
    desc => "Returns 1 if a channel has been registered, -1 if not.",
    help_path => "gmsserv/chanregistered",
    handler => \&gms_chanregistered,
    access => "special:gms"
);

$Services{GMSServ}->bind_command(
    name => "REGISTERED",
    desc => "Returns a user's registration time",
    help_path => "gmsserv/registered",
    handler => \&gms_registered,
    access => "special:gms"
);

$Services{GMSServ}->bind_command(
    name => "LASTLOGIN",
    desc => "Returns a user's last login time",
    help_path => "gmsserv/lastlogin",
    handler => \&gms_lastlogin,
    access => "special:gms"
);

$Services{GMSServ}->bind_command(
    name => "LASTSEEN",
    desc => "Returns a user's last login time",
    help_path => "gmsserv/lastseen",
    handler => \&gms_lastseen,
    access => "special:gms"
);

$Services{GMSServ}->bind_command(
    name => "FREGISTER",
    desc => "Forcibly registers a channel to a user",
    help_path => "gmsserv/fregister",
    handler => \&gms_fregister,
    access => "special:gms"
);

$Services{GMSServ}->bind_command(
    name => "PRIVATE",
    desc => "Returns if an account is private",
    help_path => "gmsserv/private",
    handler => \&gms_private,
    access => "special:gms"
);

$Services{GMSServ}->bind_command(
    name => "NOTICECHAN",
    desc => "Notice a channel",
    help_path => "gmsserv/noticechan",
    handler => \&gms_noticechan,
    access => "special:gms"
);

$Services{GMSServ}->bind_command(
    name => "HELP",
    desc => "Displays contextual help information.",
    help_path => "gmsserv/help",
    handler => \&gms_help
);

sub gms_uid {
    my ($source, @parv) = @_;

    my $nick = shift @parv;

    my $account = $Atheme::Accounts{$nick};

    if ($account) {
        $source->success ($account->uid);
    }
    else {
        $source->fail (Atheme::Fault::nosuch_target(), "No such account");
    }
}

sub gms_drop {
    my ($source, @parv) = @_;

    my ($channel, $uid) = @parv;

    my $creg = $Atheme::ChannelRegistrations{$channel};

    my $acc = $Atheme::Accounts{'?' . $uid};

    if (!$creg) {
        $source->fail (Atheme::Fault::nosuch_target(), "The channel $channel is not registered");
    } elsif (!$acc) {
        $source->fail (Atheme::Fault::nosuch_target(), "The account with uid $uid is not registered");
    } else {
        $creg->drop;

        $source->success ("The channel " . $channel . " has been dropped");

        Atheme::Log::command(__PACKAGE__, $source, Atheme::Log::admin | Atheme::Log::register, "The channel $channel has been dropped through GMS by " . $acc->name);
        Atheme::wallops ("The channel $channel has been dropped through GMS by " . $acc->name);
    }

}

sub gms_transfer {
    my ($source, @parv) = @_;

    my ($channel, $new_founder, $requestor) = @parv;

    my $creg = $Atheme::ChannelRegistrations{$channel};

    my $nf_acc = $Atheme::Accounts{'?' . $new_founder};
    my $requestor_acc = $Atheme::Accounts{'?' . $requestor};

    if (!$creg) {
        $source->fail (Atheme::Fault::nosuch_target(), "The channel $channel is not registered");
    } elsif (!$nf_acc) {
        $source->fail (Atheme::Fault::nosuch_target(), "The account with uid $new_founder is not registered");
    } elsif (!$requestor_acc) {
        $source->fail (Atheme::Fault::nosuch_target(), "The account with uid $requestor is not registered");
    } else {
        $creg->transfer ($source, $nf_acc);

        $source->success ("The channel " . $channel . " has been transferred to " . $nf_acc->name);

        Atheme::Log::command(__PACKAGE__, $source, Atheme::Log::admin | Atheme::Log::register, "The channel $channel has been transferred to " . $nf_acc->name . " through GMS by " . $requestor_acc->name);
        Atheme::wallops("The channel $channel has been transferred to " . $nf_acc->name . " through GMS by " . $requestor_acc->name);
    }
}

sub gms_fregister {
    my ($source, @parv) = @_;

    my ($channel, $new_founder, $requestor) = @parv;

    my $chan = $Atheme::Channels{$channel};

    my $nf_acc = $Atheme::Accounts{'?' . $new_founder};
    my $requestor_acc = $Atheme::Accounts{'?' . $requestor};

    if (!$chan) {
        $source->fail (Atheme::Fault::nosuch_target(), "The channel $channel must exist in order to register it");
    } elsif (!$nf_acc) {
        $source->fail (Atheme::Fault::nosuch_target(), "The account with uid $new_founder is not registered");
    } elsif (!$requestor_acc) {
        $source->fail (Atheme::Fault::nosuch_target(), "The account with uid $requestor is not registered");
    } else {
        my $creg = $chan->register ($source, $nf_acc);

        if ( $chan->ts > 0 ) {
            $creg->metadata->{'private::channelts'} = $chan->ts;
        }

        my $templates = Atheme::ChanServ::Config::default_templates;
        if ( $templates ) {
            $creg->metadata->{'private::templates'} = $templates;
        }

        $source->success ("The channel " . $channel . " has been registered to " . $nf_acc->name);
        Atheme::Log::command(__PACKAGE__, $source, Atheme::Log::admin | Atheme::Log::register, "The channel $channel has been registered to " . $nf_acc->name . " through GMS by " . $requestor_acc->name);
        Atheme::wallops("The channel $channel has been registered to " . $nf_acc->name . " through GMS by " . $requestor_acc->name);
    }
}

sub gms_cloak {
    my ($source, @argv) = @_;

    my ($uid, $cloak) = @argv;

    my $acc = $Atheme::Accounts{'?' . $uid};

    if (!$acc) {
        $source->fail (Atheme::Fault::nosuch_target(), "No such account");
    } else {
        $acc->vhost ($cloak);

        $source->success ($acc->name . " has successfully been granted the cloak $cloak");
        Atheme::Log::command(__PACKAGE__, $source, Atheme::Log::admin, "VHOST:ASSIGN: $cloak to " . $acc->name);
    }
}

sub gms_metadata {
    my ($source, @argv) = @_;

    my ($uid, $name) = @argv;

    my $acc = $Atheme::Accounts{'?' . $uid};

    if (!$acc) {
        $source->fail (Atheme::Fault::nosuch_target(), "No such account");
    } else {
        my $md = $acc->metadata->{$name};

        if ($md) {
            $source->success ($md);
        }
        else {
            $source->fail (Atheme::Fault::nosuch_key(), "No such metadata on the account");
        }
    }

}

sub gms_accountname {
    my ($source, @argv) = @_;

    my $uid = shift @argv;

    my $acc = $Atheme::Accounts{'?' . $uid}; # '?' And a UID will find an account name via UID per Atheme code.

    if (!$acc) {
        $source->fail (Atheme::Fault::nosuch_target(), "No such account");
    } else {
        $source->success ($acc->name);
    }
}

sub gms_chanexists {
    my ($source, @parv) = @_;
    my $channel = shift @parv;

    my $chan = $Atheme::Channels{$channel};

    if ($chan) {
        $source->success (1);
    } else {
        $source->success (-1);
    }
}

sub gms_chanregistered {
    my ($source, @parv) = @_;
    my $channel = shift @parv;

    my $chan = $Atheme::ChannelRegistrations{$channel};

    if ($chan) {
        $source->success (1);
    } else {
        $source->success (-1);
    }
}

sub gms_registered {
    my ($source, @argv) = @_;

    my $uid = shift @argv;

    my $acc = $Atheme::Accounts{'?' . $uid};

    if (!$acc) {
        $source->fail (Atheme::Fault::nosuch_target(), "No such account");
    } else {
        $source->success ($acc->registered);
    }
}

sub gms_lastlogin {
    my ($source, @argv) = @_;

    my $uid = shift @argv;

    my $acc = $Atheme::Accounts{'?' . $uid};

    if (!$acc) {
        $source->fail (Atheme::Fault::nosuch_target(), "No such account");
    } else {
        $source->success ($acc->last_login);
    }
}

sub gms_lastseen {
    my ($source, @argv) = @_;

    my $uid = shift @argv;

    my $acc = $Atheme::Accounts{'?' . $uid};

    if (!$acc) {
        $source->fail (Atheme::Fault::nosuch_target(), "No such account");
    } else {
        $source->success ($acc->last_seen);
    }
}

sub gms_private {
    my ($source, @argv) = @_;

    my $uid = shift @argv;
    my $acc = $Atheme::Accounts{'?' . $uid};

    if (!$acc) {
        $source->fail (Atheme::Fault::nosuch_target(), "No such account");
    } else {
        my $flags = $acc->flags;

        if ( $flags & Atheme::Account::private() ) {
            $source->success (1);
        } else {
            $source->success (-1);
        }
    }
}

sub gms_noticechan {
    my ($source, @parv) = @_;

    my ($channel, $notice) = @parv;

    my $chan = $Atheme::Channels{$channel};

    if (!$chan) {
        $source->fail (Atheme::Fault::nosuch_target(), "The channel $channel does not exist");
    } else {
        $chan->notice ('GMSServ', $notice);
        $source->success ('Success');
    }
}

sub gms_help {
    my ($source, @argv) = @_;

    $source->fail (Atheme::Fault::noprivs(), "This service has no public interface.");
}
