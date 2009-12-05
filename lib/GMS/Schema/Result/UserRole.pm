package GMS::Schema::Result::UserRole;
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table('user_roles');
__PACKAGE__->add_columns(qw/ account_id role_id /);

__PACKAGE__->set_primary_key(qw/ account_id role_id /);

__PACKAGE__->belongs_to(account => 'GMS::Schema::Result::Account', 'account_id');
__PACKAGE__->belongs_to(role => 'GMS::Schema::Result::Role', 'role_id');

1;
