package GMS::Schema::Result::ChannelNamespace;
use strict;
use warnings;
use base 'DBIx::Class';

use TryCatch;

__PACKAGE__->load_components('Core');
__PACKAGE__->table('channel_namespaces');
__PACKAGE__->add_columns(qw/ group_id namespace /);

__PACKAGE__->belongs_to('group', 'GMS::Schema::Result::Group', 'group_id');

sub insert {
    my $self = shift;
    try {
        return $self->next::method(@_);
    }
    catch (DBIx::Class::Exception $e) {
        if ("$e" =~ /unique_channel_ns/) {
            die GMS::Exception->new("The channel namespace " . $self->namespace .
                                    " has already been claimed.");
        } else {
            die $e;
        }
    }
}

1;
