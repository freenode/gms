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

        DBIx::Class::DeploymentHandler->new({
                schema => GMS::Schema->do_connect,
                script_directory => 'share/ddl',
                databases => [ 'PostgreSQL' ],
                sql_translator_args => {
                  quote_field_names => 1,
                  producer_args => {
                    postgres_version => 9
                  },
                },
            })
    }

    sub cmd_write_ddl {
        # Get self.
        my $self = shift;

        $self->_dh->prepare_install;
        my $v = $self->_dh->schema_version;
        if ($v > 1) {
            $self->_dh->prepare_upgrade({
                    from_version => $v-1,
                    to_version => $v
                });
        }
    }

    # Do a first-time database install.
    sub cmd_install {
        # Get self.
        my $self = shift;

        # Install.
        $self->_dh->install;

        # Setup Schema.
        $self->_dh->schema->install_defaults;
    }

    # Do an upgrade from a previous version.
    sub cmd_upgrade {
        # Get self.
        my $self = shift;

        # Do upgrade.
        $self->_dh->upgrade;
    }

    # This is the main sub that is run at the start.
    sub run {
        my ($self) = @_;

        # Get the command and any extra parameters supplied
        # from the command line.
        my ($cmd, @what) = @ARGV;

        # Check to see that a command was passed. If not, exit.
        die "Must supply a command\n" unless $cmd;

        # TBD: I suggest that a -h/--help option be added,
        # That explains what each command does.

        # Check to see if any extra, bogus parameters were passed.
        # TBD: Should we really exit?
        die "Extra argv detected - command only please\n" if @what;

        # Check if the supplied command is valid.
        die "No such command ${cmd}\n" unless $self->can("cmd_${cmd}");

        # Execute the command.
        $self->${\"cmd_${cmd}"};
    }

} # end of BEGIN block

GMS::Schema::Script->new->run;