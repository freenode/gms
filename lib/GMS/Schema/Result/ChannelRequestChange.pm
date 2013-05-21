use utf8;
package GMS::Schema::Result::ChannelRequestChange;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

GMS::Schema::Result::ChannelRequestChange

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Object::Enum");

=head1 TABLE: C<channel_request_changes>

=cut

__PACKAGE__->table("channel_request_changes");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'channel_request_changes_id_seq'

=head2 channel_request_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 time

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 changed_by

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0

=head2 channel_request_status

  data_type: 'enum'
  extra: {custom_type_name => "channel_request_status",list => ["pending_staff","approved","rejected","applied","error"]}
  is_nullable: 0

=head2 change_freetext

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "channel_request_changes_id_seq",
  },
  "channel_request_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "time",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "changed_by",
  {
    data_type      => "varchar",
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "status",
  {
    data_type => "enum",
    extra => {
      custom_type_name => "status",
      list => ["pending_staff", "approved", "rejected", "applied", "error"],
    },
    is_nullable => 0,
  },
  "change_freetext",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 changed_by

Type: belongs_to

Related object: L<GMS::Schema::Result::Account>

=cut

__PACKAGE__->belongs_to(
  "changed_by",
  "GMS::Schema::Result::Account",
  { id => "changed_by" },
  { is_deferrable => 1, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 channel_request

Type: belongs_to

Related object: L<GMS::Schema::Result::ChannelRequest>

=cut

__PACKAGE__->belongs_to(
  "channel_request",
  "GMS::Schema::Result::ChannelRequest",
  { id => "channel_request_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-04-11 11:58:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Vf9rX2TrOvBcFdljt7K0fg

# Set enum columns to use Object::Enum
__PACKAGE__->add_columns(
    '+status' => { is_enum => 1 },
);

use TryCatch;

use GMS::Exception;

=head1 METHODS

=head2 new

Constructor. Checks if the arguments in the change object are valid,
and throws an error if not.

=cut

sub new {
    my ($class, $args) = @_;

    my @errors;
    my $valid=1;

    if (!$args->{status}) {
        push @errors, "Status cannot be empty";
        $valid = 0;
    }

    if (!$valid) {
        die GMS::Exception::InvalidChange->new(\@errors);
    }

    return $class->next::method($args);
}

1;
