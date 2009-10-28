package GMS::Config;

use strict;
use warnings;

use vars qw($dbstring $dbuser $dbpass
            $atheme_host $atheme_port $service
            $atheme_master_login $atheme_master_pass);

$dbstring = 'dbi:Pg:dbname=gms';
$dbuser = '';
$dbpass = '';
$atheme_host = 'localhost';
$atheme_port = '8080';
$service = 'GroupServ';
$atheme_master_login = 'GMS';
$atheme_master_pass = 'goat';
