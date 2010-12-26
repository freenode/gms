package GMS::Schema::Result::Address;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Object::Enum");

=head1 NAME

GMS::Schema::Result::Address

=cut

__PACKAGE__->table("addresses");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'addresses_id_seq'

=head2 address_one

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 address_two

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 city

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 state

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 code

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 country

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 phone

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 phone2

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "addresses_id_seq",
  },
  "address_one",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "address_two",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "city",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "state",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "code",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "country",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "phone",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "phone2",
  { data_type => "varchar", is_nullable => 1, size => 32 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 contact_changes

Type: has_many

Related object: L<GMS::Schema::Result::ContactChange>

=cut

__PACKAGE__->has_many(
  "contact_changes",
  "GMS::Schema::Result::ContactChange",
  { "foreign.address" => "self.id" },
  {},
);

=head2 group_changes

Type: has_many

Related object: L<GMS::Schema::Result::GroupChange>

=cut

__PACKAGE__->has_many(
  "group_changes",
  "GMS::Schema::Result::GroupChange",
  { "foreign.address" => "self.id" },
  {},
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2010-12-26 23:18:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xfAitxEloRcFwfhet9pXxQ

=head1 METHODS

=head2 new

Constructor. Validates arguments and presents human-readable errors when this
fails.

=cut

sub new {
    my $class = shift;
    my $args = shift;

    my @errors;
    my $valid = 1;

    if (! $args->{address_one}) {
        push @errors, "Address 1 is missing";
        $valid = 0;
    }
    if (! $args->{city}) {
        push @errors, "City is missing";
        $valid = 0;
    }
    if (! $args->{country}) {
        push @errors, "Country is missing";
        $valid = 0;
    }
    if (! $args->{phone}) {
        push @errors, "Telephone number is missing";
        $valid = 0;
    } elsif ($args->{phone} =~ /[^0-9 \+-]/) {
        push @errors, "Telephone number contains non-digit characters";
        $valid = 0;
    }
    if ($args->{phone2} && $args->{phone2} =~ /[^0-9 \+-]/) {
        push @errors, "Alternate telephone number contains non-digit characters";
        $valid = 0;
    }

    if (!$valid) {
        die GMS::Exception::InvalidAddress->new(\@errors);
    }

    return $class->next::method($args);
}


#sub pretty_long {
#    my ($self) = @_;
#    my $out = "";
#    $out .= $self->address_one . "\n";
#    $out .= $self->address_two . "\n" if $self->address_two;
#    $out .= $self->city . "\n";
#    $out .= $self->state . "\n" if $self->state;
#    $out .= $self->country . "\n";
#    $out .= $self->code . "\n" if $self->code;
#    return $out;
#}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
