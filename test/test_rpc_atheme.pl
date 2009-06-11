#!/usr/bin/perl -w
# Simple example of using Atheme's XMLRPC server with perl RPC::XML.
# $Id: perlxmlrpc.pl 8403 2007-06-03 21:34:06Z jilles $

use lib './lib';

use RPC::Atheme;
use RPC::Atheme::Session;

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

my $session = RPC::Atheme::Session->new('localhost', '8080') or die "Couldn't create session";
$session->login($login, $password) or die "Couldn't login: " . $RPC::Atheme::ERROR;

my $response = $session->command('NickServ', 'info', $login) or die "Command failed";

if (ref $response)
{
    print "$_: " . $response->{$_} . "\n" foreach (keys %$response);
} else {
    print "$response\n";
}

$session->logout or die "Couldn't logout";
