package GMS::Config;

use strict;
use warnings;
use Config::JFDI;
use Dir::Self;
use vars qw($dbstring $dbuser $dbpass
            $atheme_host $atheme_port $service
            $atheme_master_login $atheme_master_pass);

my $config_loader = Config::JFDI->new(
	name => "gms_web",
	path => __DIR__ . "/../..",
);
my $config = $config_loader->get;

$dbstring = $config->{"Model::DB"}{connect_info}{dsn};
$dbuser = $config->{"Model::DB"}{connect_info}{user};
$dbpass = $config->{"Model::DB"}{connect_info}{password};
$atheme_host = $config->{"Model::Atheme"}{atheme_host};
$atheme_port = $config->{"Model::Atheme"}{atheme_port};
$service = 'GroupServ';
$atheme_master_login = $config->{"Model::Atheme"}{master_account};
$atheme_master_pass = $config->{"Model::Atheme"}{master_password};

1;
