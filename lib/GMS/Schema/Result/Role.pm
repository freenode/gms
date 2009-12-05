package GMS::Schema::Result::Role;
use strict;
use warnings;
use base 'DBIx::Class';

use overload '""' => 'name';

__PACKAGE__->load_components('Core');
__PACKAGE__->table('roles');
__PACKAGE__->add_columns(qw/ id name /);
__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many(user_roles => 'GMS::Schema::Result::UserRole', 'role_id');
__PACKAGE__->many_to_many(accounts => 'user_roles', 'account');


1;


