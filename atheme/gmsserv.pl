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

    my ($channel, $nick) = @parv;

    my $creg = $Atheme::ChannelRegistrations{$channel};

    my $acc = $Atheme::Accounts{$nick};

    if (!$creg) {
        $source->fail (Atheme::Fault::nosuch_target(), "The channel $channel is not registered");
    } elsif (!$acc) {
        $source->fail (Atheme::Fault::nosuch_target(), "The nickname $nick is not registered");
    } else {
        $creg->drop;

        $source->success ("The channel " . $channel . " has been dropped");

        Atheme::Log::command(__PACKAGE__, $source, Atheme::Log::admin | Atheme::Log::register, "The channel $channel has been dropped through GMS by $nick");
        Atheme::wallops ("The channel $channel has been dropped through GMS by $nick");
    }

}

sub gms_transfer {
    my ($source, @parv) = @_;

    my ($channel, $new_founder, $command_caller) = @parv;

    my $creg = $Atheme::ChannelRegistrations{$channel};

    my $nf_acc = $Atheme::Accounts{$new_founder};
    my $caller_acc = $Atheme::Accounts{$command_caller};

    if (!$creg) {
        $source->fail (Atheme::Fault::nosuch_target(), "The channel $channel is not registered");
    } elsif (!$nf_acc) {
        $source->fail (Atheme::Fault::nosuch_target(), "The nickname $new_founder is not registered");
    } elsif (!$caller_acc) {
        $source->fail (Atheme::Fault::nosuch_target(), "The nickname $command_caller is not registered");
    } else {
        $creg->transfer ($source, $nf_acc);

        $source->success ("The channel " . $channel . " has been transferred to $new_founder");

        Atheme::Log::command(__PACKAGE__, $source, Atheme::Log::admin | Atheme::Log::register, "The channel $channel has been transferred to $new_founder through GMS by $command_caller");
        Atheme::wallops("The channel $channel has been transferred to $new_founder through GMS by $command_caller");
    }
}

sub gms_cloak {
    my ($source, @argv) = @_;

    my ($nick, $cloak) = @argv;

    my $acc = $Atheme::Accounts{$nick};

    if (!$acc) {
        $source->fail (Atheme::Fault::nosuch_target(), "No such account");
    }

    $acc->vhost ($cloak);

    $source->success ($nick . " has successfully been granted the cloak $cloak");
    Atheme::Log::command(__PACKAGE__, $source, Atheme::Log::admin, "VHOST:ASSIGN: $cloak to $nick");
}

sub gms_metadata {
    my ($source, @argv) = @_;

    my ($nick, $name) = @argv;

    my $acc = $Atheme::Accounts{$nick};

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

