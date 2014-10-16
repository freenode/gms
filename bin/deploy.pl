#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

BEGIN {

    package GMS::Schema::Script;

    use GMS::Schema;
    use DBIx::Class::DeploymentHandler;

    use Moose;
    use MooseX::AttributeShortcuts;

    with 'MooseX::Getopt';

    has _dh => (is => 'lazy');

    sub _build__dh {
        my ($self) = @_;
        DBIx::Class::DeploymentHandler->new({
                schema => GMS::Schema->do_connect,
                script_directory => 'share/ddl',
                databases => [ 'PostgreSQL' ],
                sql_translator_args => { quote_field_names => 1 },
            })
    }

    sub cmd_write_ddl {
        my ($self) = @_;
        $self->_dh->prepare_install;
        my $v = $self->_dh->schema_version;
        if ($v > 1) {
            $self->_dh->prepare_upgrade({
                    from_version => $v-1,
                    to_version => $v
                });
        }
    }

    sub cmd_install {  my$self=shift;$self->_dh->install; $self->_dh->schema->install_defaults; }

    sub cmd_upgrade { shift->_dh->upgrade }

    sub run {
        my ($self) = @_;
        my ($cmd, @what) = @ARGV;
        die "Must supply a command\n" unless $cmd;
        die "Extra argv detected - command only please\n" if @what;
        die "No such command ${cmd}\n" unless $self->can("cmd_${cmd}");
        $self->${\"cmd_${cmd}"};
    }

} # end of BEGIN block

GMS::Schema::Script->new->run;

