package GMS::Schema::Result::Group;
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table('groups');
__PACKAGE__->add_columns(qw/ id groupname grouptype url address status verify_url 
                             submitted verified approved /);
__PACKAGE__->set_primary_key('id');

__PACKAGE__->has_many(group_contacts => 'GMS::Schema::Result::GroupContact', 'group_id');
__PACKAGE__->many_to_many(contacts => 'group_contacts', 'contact');

__PACKAGE__->belongs_to(address => 'GMS::Schema::Result::Address', 'address');

__PACKAGE__->has_many(channel_namespaces => 'GMS::Schema::Result::ChannelNamespace', 'group_id');
__PACKAGE__->has_many(cloak_namespaces => 'GMS::Schema::Result::CloakNamespace', 'group_id');

1;
