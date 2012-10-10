package GMS::Schema::Result::Group;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use LWP::UserAgent;
use Socket;
use HTTP::Request;
use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime", "InflateColumn::Object::Enum");

=head1 NAME

GMS::Schema::Result::Group

=cut

__PACKAGE__->table("groups");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'groups_id_seq'

=head2 group_name

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 submitted

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 verify_auto

  data_type: 'boolean'
  is_nullable: 0

=head2 active_change

  data_type: 'integer'
  default_value: -1
  is_foreign_key: 1
  is_nullable: 0

=head2 deleted

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "groups_id_seq",
  },
  "group_name",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "submitted",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "verify_auto",
  { data_type => "boolean", is_nullable => 0 },
  "active_change",
  {
    data_type      => "integer",
    default_value  => -1,
    is_foreign_key => 1,
    is_nullable    => 0,
  },
  "deleted",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("unique_active_change", ["active_change"]);
__PACKAGE__->add_unique_constraint("unique_group_name", ["group_name", "deleted"]);

=head1 RELATIONS

=head2 channel_namespaces

Type: has_many

Related object: L<GMS::Schema::Result::ChannelNamespace>

=cut

__PACKAGE__->has_many(
  "channel_namespaces",
  "GMS::Schema::Result::ChannelNamespace",
  { "foreign.active_change.group_id" => "self.id" },
  { "join" => "active_change" },
);

=head2 cloak_namespaces

Type: has_many

Related object: L<GMS::Schema::Result::CloakNamespace>

=cut

__PACKAGE__->has_many(
  "cloak_namespaces",
  "GMS::Schema::Result::CloakNamespace",
  { "foreign.active_change.group_id" => "self.id" },
  { "join" => "active_change" },
);

=head2 group_changes

Type: has_many

Related object: L<GMS::Schema::Result::GroupChange>

=cut

__PACKAGE__->has_many(
  "group_changes",
  "GMS::Schema::Result::GroupChange",
  { "foreign.group_id" => "self.id" },
  {},
);

=head2 group_contacts

Type: has_many

Related object: L<GMS::Schema::Result::GroupContact>

=cut

__PACKAGE__->has_many(
  "group_contacts",
  "GMS::Schema::Result::GroupContact",
  { "foreign.group_id" => "self.id" },
  {},
);

=head2 active_change

Type: belongs_to

Related object: L<GMS::Schema::Result::GroupChange>

=cut

__PACKAGE__->belongs_to(
  "active_change",
  "GMS::Schema::Result::GroupChange",
  { id => "active_change" },
  {},
);

=head2 group_verifications

Type: has_many

Related object: L<GMS::Schema::Result::GroupVerification>

=cut

__PACKAGE__->has_many(
  "group_verifications",
  "GMS::Schema::Result::GroupVerification",
  { "foreign.group_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-02-01 21:27:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fC8WCMJinrT5Xam+mk/OOQ

# Pseudo-relations not added by Schema::Loader
__PACKAGE__->many_to_many(contacts => 'group_contacts', 'contact');

__PACKAGE__->many_to_many(verifications => 'group_verifications', 'verification');
# Filtered versions of group_contacts, contacts and namespaces
__PACKAGE__->has_many(
    "active_group_contacts",
    "GMS::Schema::Result::GroupContact",
    { "foreign.group_id" => "self.id" },
    { 'join' => 'active_change',
      'where' => { 'active_change.status' => 'active' }
    }
);

__PACKAGE__->many_to_many(active_contacts => 'active_group_contacts', 'contact');

#GroupContacts can edit the information for active and retired contacts.
__PACKAGE__->has_many(
    "editable_group_contacts",
    "GMS::Schema::Result::GroupContact",
    { "foreign.group_id" => "self.id" },
    { join => 'active_change',
      'where' => { 'active_change.status' => ['active', 'retired'] }
    }
);

__PACKAGE__->has_many(
    "active_channel_namespaces",
    "GMS::Schema::Result::ChannelNamespace",
    { "foreign.active_change.group_id" => "self.id" },
    { 'join' => 'active_change',
      'where' => { 'active_change.status' => 'active' }
    }
);

__PACKAGE__->has_many(
    "active_cloak_namespaces",
    "GMS::Schema::Result::CloakNamespace",
    { "foreign.active_change.group_id" => "self.id" },
    { 'join' => 'active_change',
      'where' => { 'active_change.status' => 'active' }
    }
);

use TryCatch;
use String::Random qw/random_string/;
use Text::Glob qw/match_glob/;

use GMS::Exception;

=head1 METHODS

=head2 new

Constructor. A Group is constructed with all of the required fields from both
Group and GroupChange, and will implicitly create a 'create' change for the
group with its initial state.

The group name, type, and URL must be specified. Address is optional. All other
fields will be populated automatically.

=cut

sub new {
    my $class = shift;
    my $args = shift;

    my @errors;
    my $valid=1;

    if (!$args->{group_type}) {
        push @errors, "Group type must be specified";
        $valid = 0;
    }
    if (!$args->{group_name}) {
        push @errors, "Group name must be provided";
        $valid = 0;
    }
    elsif ($args->{group_name} !~ /^[A-Za-z0-9 _\.-]*$/) {
        push @errors, "Group name must contain only alphanumeric characters, space, " .
                       "underscores, hyphens and dots.";
        $valid = 0;
    }
    if (!$args->{url}) {
        push @errors, "Group URL must be provided";
        $valid = 0;
    }
    elsif ($args->{url} !~ /^[a-zA-Z0-9:\.\/_?+-]*$/) {
        push @errors, "Group URL contains invalid characters (valid characters are a-z, A-Z, " .
                       "0-9, :_+-/)";
        $valid = 0;
    }

    if (!$valid) {
        die GMS::Exception::InvalidGroup->new(\@errors);
    }
    if ($args->{url} !~ m/^http:\/\// && $args->{url} !~ m/^https:\/\//) {
        $args->{url} = "https://" . $args->{url};
    }
    $args->{verify_auto} = _use_automatic_verification($args->{group_name}, $args->{url});

    my @change_arg_names = (
        'group_type',
        'url',
        'address',
    );
    my %change_args;
    @change_args{@change_arg_names} = delete @{$args}{@change_arg_names};
    $change_args{status} = 'pending_web';
    $change_args{change_type} = 'create';
    $change_args{changed_by} = delete $args->{account};

    $args->{group_changes} = [ \%change_args ];

    return $class->next::method($args);
}

=head2 insert

Overloaded to support the implicit GroupChange creation.

=cut

sub insert {
    my ($self) = @_;
    my $ret;

    my $next_method = $self->next::can;
    # Can't put this in the creation args, as we don't know the active change id
    # until the change has been created, and we can't create the change without knowing
    # the group id.
    $self->result_source->storage->with_deferred_fk_checks(sub {
            $ret = $self->$next_method();
            $self->active_change($self->group_changes->single);
            $self->update;
        });

    $self->add_to_group_verifications ({
            verification_type => "web_url",
            verification_data => $self->url . "/".random_string("cccccccc").".txt",
        });
    $self->add_to_group_verifications ({
            verification_type => "web_token",
            verification_data => random_string("cccccccccccc"),
        });
    my $url = URI->new ($self->url);
    my $domain = $url->host;
    my @parts = split (/\./, $domain);
    $domain = $parts[-2] . "." . $parts[-1];
    $self->add_to_group_verifications ({
            verification_type => "dns",
            verification_data => "freenode-" . random_string ("ccccccc") . "." . $domain
        });
    return $ret;
}

=head2 change

    $group->change($account, $changetype, \%args);

Creates a related GroupChange with the modifications specified in %args.
Unchanged fields are populated based on the group's current state.

=cut

sub change {
    my ($self, $account, $change_type, $args) = @_;

    my $active_change = $self->active_change;
    my $last_change = $self->last_change;
    my $change;

    if ($last_change->change_type->is_request) {
        $change = $last_change;
    } else {
        $change = $active_change;
    }

    my %change_args = (
        changed_by => $account,
        change_type => $change_type,
        group_type => $args->{group_type} || $change->group_type,
        url => $args->{url} || $change->url,
        address => $args->{address} || $change->address,
        status => $args->{status} || $change->status,
        change_freetext => $args->{change_freetext}
    );
    if ( defined ( my $va = $args->{verify_auto} ) ) {
        $self->verify_auto ($va);
    }
    if ($change_args{address} == -1) {
        $change_args{address} = undef; #make it possible for groups to remove their address.
    }

    my $ret = $self->add_to_group_changes(\%change_args);
    $self->active_change($ret) if $change_type ne 'request';

    if ($self->status->is_deleted) {
        # deleted only needs to be an increasing integer value; the current
        # time seems convenient.
        $self->deleted(time) unless $self->deleted;
    } else {
        $self->deleted(0);
    }

    $self->update;
    return $ret;
}

#sub simple_url {
#    my ($self) = @_;
#    my $url = $self->url;
#    $url =~ tr/A-Z/a-z/;
#
#    if ($url !~ m!^[a-z]+://!) {
#        $url = "http://" . $url;
#    }
#
#    $url =~ s/\/$//;
#    return $url;
#}

=head2 status

Returns the current status of the group, based on the active change.

=cut
sub status {
    my ($self) = @_;
    return $self->active_change->status;
}

=head2 group_type

Returns the group type ( informal, coorporation, NGO, etc) of the
group, based on the active change.

=cut

sub group_type {
    my ($self) = @_;
    return $self->active_change->group_type;
}

=head2 verify_url

Returns the URL that can be used to verify affiliation to the group.

=cut

sub verify_url {
    my ($self) = @_;
    my ($res) = $self->group_verifications->find({verification_type => "web_url"});
    my ($data) = $res->verification_data;
    return $data;
}

=head2 verify_token

Returns the text that should be present in the above URL.

=cut

sub verify_token {
    my ($self) = @_;
    my ($res) = $self->group_verifications->find({verification_type => "web_token"});
    if ($res) {
        my ($data) = $res->verification_data;
        return $data;
    }
}

=head2 verify_dns

Returns the subdomain that must resolve to freenode.net
for DNS-based verification.

=cut

sub verify_dns {
    my ($self) = @_;
    my ($res) = $self->group_verifications->find({verification_type => "dns"});
    if ($res) {
        my ($data) = $res->verification_data;
        return $data;
    }
}

=head2 verify_freetext

Returns the user-provided text that they provide if they
can't use any of the automated verification methods.

=cut

sub verify_freetext {
    my ($self) = @_;
    my ($res) = $self->group_verifications->find({verification_type => "freetext"});
    if ($res) {
        my ($data) = $res->verification_data;
        return $data;
    }
}

=head2 last_change

Returns the most recent change for the group.

=cut

sub last_change {
    my ($self) = @_;

    my @changes = $self->group_changes->search({ }, { 'order_by' => { -desc => 'id' } });

    return $changes[0];
}

=head2 auto_verify

Checks if the group ownership can automatically be verified.
First, it checks if the verification document exists in the
domain. Failing that, it checks if the subdomain provided 
for verification resolves to the same IP as freenode.net.
Finally, it takes the text the user has given that explains
why the group hasn't been verified, if provided, or asks the
user to try again or to provide the reason for failure if not.

Depending on the result, the group will be either marked as
pending_staff (pending staff verification) or as pending_auto
(automatically verified and pending approval or rejection).

=cut

sub auto_verify {
    my ($self, $account, $args) = @_;
    my $request = HTTP::Request->new(GET => $self->verify_url);
    my $ua = LWP::UserAgent->new;
    my $response = $ua->request($request);
    my $content = $response->content;
    $content =~ s/^\s+//;
    $content =~ s/\s+$//;
    if ($content eq $self->verify_token) {
        $self->change ($account, 'workflow_change', { status => 'pending_auto' } );
        return 1;
    }

    my $packed = Socket::inet_aton($self->verify_dns);

    if ($packed) {
        my $address = Socket::inet_ntoa($packed);

        if ($address eq "5.9.244.117") {
            $self->change ($account, 'workflow_change', { status => 'pending_auto' } );
            return 1;
        }
    }
    if ( ( my $freetext = $args->{freetext} ) ) {
        $self->add_to_group_verifications ({ verification_type => 'freetext', verification_data => $freetext });
        $self->change ($account, 'workflow_change', { status => 'pending_staff'});

        return 0;
    }
    return -1;
}

=head2 url

Returns the current URL of the group, based on the active change.

=cut

sub url {
    my ($self) = @_;

    return $self->active_change->url;
}

=head2 address

Returns the Address object for the group, based on the active change.

=cut

sub address {
    my ($self) = @_;

    return $self->active_change->address;
}

=head2 verify

    $group->verify($verifiedby, $freetext);

Marks the group, which must be pending verification, as verified.

=cut

sub verify {
    my ($self, $account, $freetext) = @_;
    if (!$self->status->is_pending_staff) {
        die GMS::Exception->new("Can't verify a group that isn't pending verification.");
    }
    $self->change( $account, 'admin', { status => 'verified', 'change_freetext' => $freetext } );
}

=head2 approve

    $group->approve($approvedby, $freetext);

Marks the group, which must be pending verification or approval, as approved.
Takes two arguments, the account which approved it and optional freetext about
the approval.

=cut

sub approve {
    my ($self, $account, $freetext) = @_;
    if (!$self->status->is_pending_staff && !$self->status->is_pending_auto && !$self->status->is_verified) {
        die GMS::Exception->new("Can't approve a group that isn't verified or "
            . "pending verification");
    }
    $self->change( $account, 'admin', { status => 'active', 'change_freetext' => $freetext } );

    foreach my $contact ($self->group_contacts) {
        $contact->change ($account, 'admin', { status => 'active' });
    }

    foreach my $namespace ($self->channel_namespaces) {
        $namespace->change ($account, 'admin', { status => 'active' });
    }

}

=head2 reject

Marks the group, which must not be approved, as rejected. Takes two arguments,
the account which rejected it and optional freetext about the rejection.

=cut

sub reject {
    my ($self, $account, $freetext) = @_;
    if (!$self->status->is_pending_staff && !$self->status->is_pending_auto && !$self->status->is_verified) {
        die GMS::Exception->new("Can't reject a group not pending approval");
    }
    $self->change( $account, 'admin', { status => 'deleted', 'change_freetext' => $freetext } );
}

=head2 invite_contact

    $group->invite_contact($contact, $inviter[, \%args]);

Invites a contact to join the group. A new GroupContact will be created, with
status 'invited', and marked as being invited by $inviter. %args, if supplied,
will be used to create the new GroupContact record. Otherwise, default values
will be used.

=cut

sub invite_contact {
    my ($self, $contact, $inviter, $args) = @_;

    $args ||= {};

    if ( ( my $group_contact = $self->group_contacts->find ({ contact_id => $contact->id }) ) ) {
        if ($group_contact->status->is_deleted) {
            $group_contact->change ($inviter, 'workflow_change', { status => 'invited' });
        } else {
            die GMS::Exception->new ("This person has already been invited.");
        }
    } else {
        $self->add_to_group_contacts({
                contact => $contact,
                account => $inviter,
                %$args
            });
    }
}

=head2 add_contact

    $group->add_contact($contact, $adder[, \%args]);

Administratively adds a new contact, bypassing invitation and acceptance.

Behaves as for invite_contact above, except that the contact is created as
active from the beginning.

=cut

sub add_contact {
    my ($self, $contact, $inviter, $args) = @_;

    $args ||= {};

    if ( $self->group_contacts->find ({ contact_id => $contact->id }) ) {
        die GMS::Exception->new ("This person has already been added.");
    }

    $args->{status} = 'active';

    $self->add_to_group_contacts({
            contact => $contact,
            account => $inviter,
            %$args
        });
}

=head2 take_over

Takes three arguements, a channel name, a channel namespace and the account name
of a group contact. If the channel name matches the given namespace, which must
belong to the group, try to transfer the channel to the given group contact and
throw an error on failure. If not, an error is thrown.

=cut

sub take_over {
    my ($self, $c, $channel, $namespace, $gc_name) = @_;

    my $controlsession = $c->model('Atheme')->session;

    if (! $self->active_channel_namespaces->find({ 'namespace' => $namespace }) ) {
        die GMS::Exception->new ("This namespace does not belong in your Group's namespaces.");
    }

    if ( $channel eq "#$namespace" || match_glob ("#$namespace-*", $channel) ) {
        try {
            return $controlsession->command('GMSServ', 'transfer', $channel, $gc_name, $c->user->account->accountname);
        }
        catch (RPC::Atheme::Error $e) {
            die $e;
        }
    } else {
        die GMS::Exception->new ("This channel does not belong in that namespace.");
    }
}

=head2 drop

Similar to take_over, but drops the channel instead of transferring it.

=cut

sub drop {
    my ($self, $c, $channel, $namespace) = @_;

    my $controlsession = $c->model('Atheme')->session;

    if (! $self->active_channel_namespaces->find({ 'namespace' => $namespace }) ) {
        die GMS::Exception->new ("This namespace does not belong in your Group's namespaces.");
    }

    if ( $channel eq "#$namespace" || match_glob ("#$namespace-*", $channel) ) {
        try {
            return $controlsession->command('GMSServ', 'drop', $channel, $c->user->account->accountname);
        }
        catch (RPC::Atheme::Error $e) {
            die $e;
        }
    } else {
        die GMS::Exception->new ("This channel does not belong in that namespace.");
    }
}

=head1 INTERNAL METHODS

=head2 _use_automatic_verification

Determines whether or not a group with the given name and URL will use
automatic verification.

=cut

sub _use_automatic_verification {
    my ($name, $url) = @_;
    $url =~ tr/A-Z/a-z/;
    $url =~ s!http://!!;
    $url =~ s!www\.!!;
    $url =~ s!\.[a-z]+/?!!;
    $name =~ tr/A-Z/a-z/;
    $name =~ s/\W//g;

    return ($name eq $url) ? 1 : 0;
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
