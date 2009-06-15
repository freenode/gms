package GMS::Schema::Result::ChannelNamespace;
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table('channel_namespaces');
__PACKAGE__->add_columns(qw/ group_id namespace /);

1;
