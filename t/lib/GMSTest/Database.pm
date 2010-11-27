package GMSTest::Database;

use strict;
use warnings;

use GMS::Schema;
use DBIx::Class::Fixtures;

use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/need_database/;
our @EXPORT_OK = @EXPORT;

sub need_database {
    my ($fixtureset) = @_;

    my $schema = GMS::Schema->do_connect();
    $schema->deploy({ add_drop_table => 1 });

    my $fixtures = DBIx::Class::Fixtures->new({ config_dir => 't/etc' });
    $fixtures->populate({
        directory => "t/etc/$fixtureset",
        schema => $schema,
        no_deploy => 1
    });

    # XXX: This is a bit icky.
    # XXX: Needs to be updated when new auto-increment PKs are added
    #
    # Since the explicitly-specified id fields from the fixtures don't use the
    # default auto-incrementing PK, they don't retrieve a value from the sequence
    # used for that purpose, so the default 'next' PK value will already be in
    # use. Set the next sequence values to something higher than what's used.
    my @id_tables = ( qw/
                accounts
                addresses
                contact_changes
                contacts
                group_changes
                groups
                roles/);

    $schema->storage->dbh_do(sub {
            my ($storage, $dbh, @tables) = @_;
            foreach (@tables) {
                $dbh->selectrow_array("SELECT setval('${_}_id_seq', (SELECT max(id) FROM $_) + 1)");
            }
        }, @id_tables);
}

1;
