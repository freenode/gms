use Atheme;

%Info = (
    name => 'uid.pl',
    depends => [ 'groupserv/main' ],
);

$Services{groupserv}->bind_command(
    name => "UID",
    desc => "Returns a user's UID",
    help_path => "groupserv/uid",
    handler => \&gs_uid
);

sub gs_uid {
    my ($source, @parv) = @_;

    my $nick = shift @parv;

    my $account = $Atheme::Accounts{$nick};

    if ($account) {
        $source->success ($account->uid);
    }
    else {
        $source->fail ($Atheme::Errors::nosuch_target, "No such account");
    }
}
