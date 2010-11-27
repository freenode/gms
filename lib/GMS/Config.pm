package GMS::Config;

use strict;
use warnings;
use Config::JFDI;
use Dir::Self;

my $config;

=head1 NAME

GMS::Config

=head1 DESCRIPTION

GMS::Config provides an interface to GMS configuration for non-Catalyst code
that cannot simply use C<$c->config>. Uses L<Config::JFDI>, so settings such as
C<GMS_WEB_CONFIG_LOCAL_SUFFIX> are respected.

=head1 METHODS

=head2 load_config

Loads the relevant configuration files. Called internally when required -- you
shouldn't need to call this directly.

=cut

sub load_config {
    my $config_loader = Config::JFDI->new(
            name => "gms_web",
            path => $ENV{GMS_WEB_CONFIG_PATH} || __DIR__ . "/../..",
    );
    $config = $config_loader->get;
}

=head2 database

Returns the database connect_info defined in the C<Model::DB> section of the
configuration file(s).

=cut

sub database {
    load_config unless $config;
    return $config->{"Model::DB"}->{connect_info};
}

=head2 atheme

Returns the Atheme connection info defined in the C<Model::Atheme> section of
the configuration file(s).

=cut

sub atheme {
    load_config unless $config;
    return $config->{"Model::Atheme"};
}


1;
