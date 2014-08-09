use utf8;
package GMS::Schema::Result::Address;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

GMS::Schema::Result::Address

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<addresses>

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

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 group_changes

Type: has_many

Related object: L<GMS::Schema::Result::GroupChange>

=cut

__PACKAGE__->has_many(
  "group_changes",
  "GMS::Schema::Result::GroupChange",
  { "foreign.address" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-07-07 14:42:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2eOkRKyaxOEhytZyi54ZZQ
# You can replace this text with custom content, and it will be preserved on regeneration

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Object::Enum");

use overload '""' => \&stringify,
             fallback => 1;

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
    } elsif (length $args->{address_one} > 255) {
        push @errors, "Address 1 can be up to 255 characters.";
        $valid = 0;
    }

    if ($args->{address_two} && length $args->{address_two} > 255) {
        push @errors, "Address 2 can be up to 255 characters.";
        $valid = 0;
    }

    if (! $args->{city}) {
        push @errors, "City is missing";
        $valid = 0;
    } elsif (length $args->{city} > 255) {
        push @errors, "City can be up to 255 characters.";
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
    } elsif (length $args->{phone} > 32) {
        push @errors, "Phone can be up to 32 characters.";
        $valid = 0;
    }

    if ($args->{phone2} && $args->{phone2} =~ /[^0-9 \+-]/) {
        push @errors, "Alternate telephone number contains non-digit characters";
        $valid = 0;
    }
    if ($args->{phone2} && length $args->{phone2} > 32) {
        push @errors, "Alternate Phone can be up to 32 characters.";
        $valid = 0;
    }

    if ($args->{state} && length $args->{state} > 255) {
        push @errors, "State can be up to 255 characters.";
        $valid = 0;
    }
    if ($args->{code} && length $args->{code} > 32) {
        push @errors, "Postcode can be up to 32 characters.";
        $valid = 0;
    }
    if ($args->{country} && length $args->{country} > 64) {
        push @errors, "Country can be up to 64 characters.";
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


=head2 TO_JSON

Returns a representative object for the JSON parser.

=cut

sub TO_JSON {
    my ($self) = @_;

    return {
        'address_one' => $self->address_one,
        'address_two' => $self->address_two,
        'city'        => $self->city,
        'state'       => $self->state,
        'country'     => $self->country,
        'code'        => $self->code,
        'phone'       => $self->phone,
        'phone2'      => $self->phone2
    };
}

=head2 stringify

Returns a string representation.

=cut

sub stringify {
    my ($self) = @_;

    my $str = $self->address_one;
    $str .= ", " . $self->address_two if $self->address_two;

    $str .= ", " . $self->city;

    $str .= ", " . $self->state if $self->state;
    $str .= ", " . $self->code if $self->code;

    $str .= ", " . $self->country;
    $str .= ", " . $self->phone;

    $str .= ", " . $self->phone2 if $self->phone2;

    return $str;
}

1;
