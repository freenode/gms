package GMS::Schema::Result::GroupContact;
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table('group_contacts');
__PACKAGE__->add_columns(qw/ group_id contact_id primary position /);

__PACKAGE__->set_primary_key(qw/ group_id contact_id /);

__PACKAGE__->belongs_to(group => 'GMS::Schema::Result::Group', 'group_id');
__PACKAGE__->belongs_to(contact => 'GMS::Schema::Result::Contact', 'contact_id');

1;

