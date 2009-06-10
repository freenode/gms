package GMS::Schema::Result::Contact;
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table('contacts');
__PACKAGE__->add_columns(qw/ id account_id name address /);
__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many(group_contacts => 'GMS::Schema::Result::GroupContact', 'contact_id');
__PACKAGE__->many_to_many(groups => 'group_contacts', 'group');

#__PACKAGE__->belongs_to(address => 'GMS::Schema::Result::Address', 'address');
#__PACKAGE__->belongs_to(account => 'GMS::Schema::Result::Account', 'account');

1;

