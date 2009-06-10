package GMS::Schema::Result::Account;
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table('accounts');
__PACKAGE__->add_columns(qw/ id accountname accountts /);
__PACKAGE__->set_primary_key('id');

1;


