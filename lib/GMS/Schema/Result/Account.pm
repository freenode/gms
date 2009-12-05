package GMS::Schema::Result::Account;
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table('accounts');
__PACKAGE__->add_columns(qw/ id accountname /);
__PACKAGE__->set_primary_key('id');

__PACKAGE__->might_have('contact', 'GMS::Schema::Result::Contact', 'account_id');

__PACKAGE__->has_many(user_roles => 'GMS::Schema::Result::UserRole', 'account_id');
__PACKAGE__->many_to_many(roles => 'user_roles', 'role');

1;
