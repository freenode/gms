#!/usr/bin/perl -w

use lib './lib';

use RPC::Atheme;
use RPC::Atheme::Session;

use GMS::Config;
use GMS::Session;
use Data::Dumper;

my $login;
my $password;

open(TTY, "+</dev/tty") or die "open /dev/tty: $!";
print TTY "login: ";
$login = <TTY>;
exit 0 if ($login eq '');
system("stty -echo </dev/tty");
print TTY "Password:";
$password = <TTY>;
system("stty echo </dev/tty");
print TTY "\n";
exit 0 if ($password eq '');

chomp $login;
chomp $password;

my $controlsession = RPC::Atheme::Session->new($GMS::Config::atheme_host,
                                               $GMS::Config::atheme_port);
$controlsession->login($GMS::Config::atheme_master_login, $GMS::Config::atheme_master_pass)
    or die "Couldn't create atheme control session";

my $session = GMS::Session->new($login, $password, $controlsession);

print Data::Dumper->Dump([$session]);
