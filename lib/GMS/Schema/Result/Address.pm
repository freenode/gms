package GMS::Schema::Result::Address;
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components('Core');
__PACKAGE__->table('addresses');
__PACKAGE__->add_columns(qw/ id address_one address_two city state code country phone phone2 /);
__PACKAGE__->set_primary_key('id');

sub pretty_long {
    my ($self) = @_;
    my $out = "";
    $out .= $self->address_one . "\n";
    $out .= $self->address_two . "\n" if $self->address_two;
    $out .= $self->city . "\n";
    $out .= $self->state . "\n" if $self->state;
    $out .= $self->country . "\n";
    $out .= $self->code . "\n" if $self->code;
    return $out;
}

1;

