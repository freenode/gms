package GMS::Web::Controller::Admin::Admin;

use strict;
use warnings;
use base qw (GMS::Web::TokenVerification);

use GMS::Domain::ChannelNamespaceChange;
use GMS::Domain::ContactChange;
use GMS::Domain::CloakChangeChange;
use GMS::Domain::CloakChange;
use GMS::Domain::CloakNamespaceChange;
use GMS::Domain::GroupContactChange;
use GMS::Domain::GroupChange;
use GMS::Domain::Group;
use GMS::Domain::ChannelRequest;
use GMS::Domain::ChannelRequestChange;

use TryCatch;
use GMS::Exception;
use RPC::Atheme::Error;

=head1 NAME

GMS::Web::Controller::Admin::Admin - Controller for GMS::Web

=head1 DESCRIPTION

This controller contains handlers for the admin pages.

=head1 METHODS

=head2 single_group

Chained method to select a single group. Similar to
L<GMS::Web::Controller::Group/single_group>, but searches all groups, not those
for which the user is a contact.

=cut

sub single_group :Chained('/admin/admin_only') :PathPart('group') :CaptureArgs(1) {
    my ($self, $c, $group_id) = @_;

    my $group_row = $c->model('DB::Group')->find({ id => $group_id });
    $c->stash->{group_row} = $group_row;

    try {
        my $session = $c->model('Atheme')->session;

        if ($group_row) {
            my $group = GMS::Domain::Group->new ( $session, $group_row );
            $c->stash->{group} = $group;
        } else {
            $c->detach('/default');
        }
    }
    catch (RPC::Atheme::Error $e) {
        $c->stash->{error_msg} = "The following error occurred when attempting to communicate with atheme: " . $e->description . ". Data displayed below may not be current.";
        if ($group_row) {
            $c->stash->{group} = $group_row;
        } else {
            $c->detach('/default');
        }
    }
}

=head2 address

Chained method to select an address. Admins can view addresses
for all groups and users.

=cut

sub address :Chained('/admin/admin_only') :PathPart('address') :CaptureArgs(1) {
    my ($self, $c, $address_id) = @_;

    my $address = $c->model('DB::Address')->find({ id => $address_id });

    if ($address) {
        $c->stash->{address} = $address;
    } else {
        $c->detach('/default');
    }
}

=head2 account

Chained method to select an account.

=cut

sub account :Chained('/admin/admin_only') :PathPart('account') :CaptureArgs(1) {
    my ($self, $c, $account_id) = @_;

    my $account;

    try {
        $account = $c->model('Accounts')->find_by_uid ( $account_id );
    }
    catch (GMS::Exception $e) {
        $c->stash->{error_msg} = "The following error occurred when attempting to communicate with atheme: " . $e->message . ". Data displayed below may not be current.";
        $account = $c->model('DB::Account')->find({ id => $account_id });
    }
    catch (RPC::Atheme::Error $e) {
        $c->stash->{error_msg} = "The following error occurred when attempting to communicate with atheme: " . $e->description . ". Data displayed below may not be current.";
        $account = $c->model('DB::Account')->find({ id => $account_id });
    }

    if ($account) {
        $c->stash->{account} = $account;
    } else {
        $c->detach('/default');
    }
}


=head2 approve

Presents the approval page.

=cut

sub approve: Chained('/admin/approver_only') :PathPart('approve') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{pending_groups} = $c->model('DB::Group')->search_pending->count;
    $c->stash->{pending_channel_namespaces} = $c->model('DB::ChannelNamespace')->search_pending->count;
    $c->stash->{pending_cloak_namespaces} = $c->model('DB::CloakNamespace')->search_pending->count;
    $c->stash->{pending_gc} = $c->model('DB::GroupContact')->search_pending->count;
    $c->stash->{pending_changes} =
      $c->model('DB::GroupContactChange')->active_requests->count
      + $c->model('DB::GroupChange')->active_requests->count
      + $c->model('DB::ChannelNamespaceChange')->active_requests->count
      + $c->model('DB::CloakNamespaceChange')->active_requests->count;
    $c->stash->{pending_cloaks} = $c->model('DB::CloakChange')->search_pending->count;
    $c->stash->{pending_channels} = $c->model('DB::ChannelRequest')->search_pending->count;

    $c->stash->{template} = 'admin/approve.tt';
}

=head2 view

Displays information about a single group.

=cut

sub view :Chained('single_group') :PathPart('view') :Args(0) {
    my ($self, $c) = @_;

    my $group = $c->stash->{group};

    if ($group->status eq 'submitted' || $group->status eq 'pending_web') {
        $c->stash->{friendly_status} = "Submitted, awaiting verification by Group Contact.";
    }
    elsif ($group->status eq "pending_auto" || $group->status eq "pending_staff" || $group->status eq "verified") {
        $c->stash->{friendly_status} = "Awaiting staff decision.";
    }
    elsif ($group->status eq "active") {
        $c->stash->{friendly_status} = "The group is active.";
    }
    elsif ($group->status eq "deleted") {
        $c->stash->{friendly_status} = "The group has been deleted.";
    }

    $c->stash->{template} = 'staff/view_group.tt';
}

=head2 add_gc

Displays the form to add a new group contact, bypassing invitation.

=cut

sub add_gc :Chained('single_group') :PathPart('add_gc') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'admin/add_gc.tt';
}

=head2 do_add_gc

Adds the specified user as a group contact, bypassing invitation.

=cut

sub do_add_gc :Chained('single_group') :PathPart('add_gc/submit') :Args(0) {
    my ($self, $c) = @_;

    my $p = $c->request->params;
    my $account = $c->model("DB::Account")->find ({ 'accountname' => $p->{contact} });

    if (! $account || ! $account->contact) {
        $c->stash->{error_msg} = "This user doesn't exist or has no contact information defined.";
        $c->detach ("add_gc");
    } else {
        my $contact = $account->contact;
        my $group = $c->stash->{group_row};

        try {
            $group->add_contact ($contact, $c->user->account->id, { 'freetext' => $p->{freetext} });
        }
        catch (GMS::Exception $e) {
            $c->stash->{error_msg} = $e;
            $c->detach ("add_gc");
        }
    }

    $c->stash->{msg} = "Successfully added the group contact.";
    $c->stash->{template} = 'admin/action_done.tt';
}

=head2 view_address

Displays the given address to the admin.

=cut

sub view_address :Chained('address') :PathPart('view') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'admin/view_address.tt';
}

=head2 edit

Displays the form to edit a group's details.
If the form hasn't been submitted already,
it's populated with the group's current data.

=cut

sub edit :Chained('single_group') :PathPart('edit') :Args(0) {
    my ($self, $c) = @_;

    my $group = $c->stash->{group};

    my $active_change = $group->active_change;
    my $last_change = $group->last_change;
    my $change;

    if ($last_change->change_type->is_request) {
        $change = $last_change;
        $c->stash->{status_msg} = "Warning: There is already a change request pending for this group.
         As a result, information from the current request is used instead of the active change.";
    } else {
        $change = $active_change;
    }

    my $address = $change->address;

    if (!$c->stash->{form_submitted}) {
        $c->stash->{group_type} = $change->group_type;
        $c->stash->{url} = $change->url;
        $c->stash->{status} = $change->status;

        if ($address) {
            $c->stash->{has_address} = 'y';

            foreach (qw /address_one address_two city state code country phone phone2/) {
                $c->stash->{$_} = $address->$_;
            }
        } else {
            $c->stash->{has_address} = 'n';
        }
    }

    $c->stash->{template} = 'admin/edit_group.tt';
}

=head2 do_edit

Processes the group edit form. Similar to
L<GMS::Web::Controller::Group/do_edit>,
but the change_type is 'admin'.

=cut

sub do_edit :Chained('single_group') :PathPart('edit/submit') :Args(0) {
    my ($self, $c) = @_;

    my $p = $c->request->params;
    my $group = $c->stash->{group_row};
    my $address;

    try {
        if ($p->{has_address} && $p->{update_address} && $p->{has_address} eq 'y' && $p->{update_address} eq 'y') {
            $address = $c->model('DB::Address')->create({
                    address_one => $p->{address_one},
                    address_two => $p->{address_two},
                    city => $p->{city},
                    state => $p->{state},
                    code => $p->{code},
                    country => $p->{country},
                    phone => $p->{phone},
                    phone2 => $p->{phone2}
                });
        } elsif ($p->{has_address} eq 'n' && $p->{update_address} eq 'y') {
            $address = -1;
        }

        $group->change ($c->user->account->id, 'admin', { 'group_type' => $p->{group_type}, 'status' => $p->{status}, 'url' => $p->{url}, address => $address, 'change_freetext' => $p->{freetext} });
    }
    catch (GMS::Exception::InvalidAddress $e) {
        $c->stash->{errors} = [
            "The address provided is not valid. Please fill in all required fields.",
            @{$e->message}
        ];
        %{$c->stash} = ( %{$c->stash}, %$p );
        $c->stash->{form_submitted} = 1;
        $c->detach('edit');
    } catch (GMS::Exception::InvalidChange $e) {
        $c->stash->{errors} = $e->message;
         %{$c->stash} = ( %{$c->stash}, %$p );
        $c->stash->{form_submitted} = 1;
        $c->detach('edit');
    }

    $c->stash->{msg} = "Successfully edited the group's information.";
    $c->stash->{template} = 'admin/action_done.tt';
}

=head2 edit_gc

Displays the form to edit Group Contact information.
Admins can edit information for all contacts.

=cut

sub edit_gc :Chained('single_group') :PathPart('edit_gc') :Args(0) {
    my ($self, $c) = @_;

    my $group = $c->stash->{group};
    my @group_contacts = $group->group_contacts;

    $c->stash->{group_contacts} = \@group_contacts;

    $c->stash->{template} = 'admin/edit_gc.tt';
}

=head2 do_edit_gc

Processes the Group Contact edit form and creates a
GroupContactChange with 'admin' as the change type.

=cut

sub do_edit_gc :Chained('single_group') :PathPart('edit_gc/submit') :Args(0) {
    my ($self, $c) = @_;

    my $group = $c->stash->{group_row};

    my $params = $c->request->params;
    my @group_contacts = split / /, $params->{group_contacts};

    foreach my $contact_id (@group_contacts) {
        my $contact = $group->group_contacts->find ({ contact_id => $contact_id });
        my $action = $params->{"action_$contact_id"};
        if ($action eq 'change') {
            my $status = $params->{"status_$contact_id"};
            my $primary = $params->{"primary_$contact_id"};
            my $freetext = $params->{"freetext_$contact_id"};

            if (!$primary) {
                $primary = -1;
            }

            $contact->change ($c->user->account->id, 'admin', { 'status' => $status, 'primary' => $primary, 'change_freetext' => $freetext });
        } elsif ($action eq 'hold') {
            next;
        }
    }

    $c->stash->{msg} = "Successfully edited the Group Contacts' information.";
    $c->stash->{template} = 'admin/action_done.tt';
}

=head2 edit_channel_namespaces

Shows the group's current channel namespaces and allows the admin to edit them or add more.

=cut

sub edit_channel_namespaces :Chained('single_group') :PathPart('edit_channel_namespaces') :Args(0) {
    my ($self, $c) = @_;

    my $group = $c->stash->{group};
    my @channel_namespaces = $group->channel_namespaces;

    $c->stash->{channel_namespaces} = \@channel_namespaces;
    $c->stash->{template} = 'admin/edit_channel_namespaces.tt';
}

=head2 do_edit_channel_namespaces

Processes the form to edit channel namespaces or add a new channel namespace for the group

=cut

sub do_edit_channel_namespaces :Chained('single_group') :PathPart('edit_channel_namespaces/submit') :Args(0) {
    my ($self, $c) = @_;

    my $group = $c->stash->{group_row};
    my $p = $c->request->params;
    my $new_namespace = $p->{namespace};

    my @namespaces = $group->active_channel_namespaces;

    my $namespace_rs = $c->model("DB::ChannelNamespace");

    foreach my $namespace (@namespaces) {
        my $namespace_id = $namespace->id;

        if ($p->{"edit_$namespace_id"}) {
            my $status = $p->{"status_$namespace_id"};
            $namespace->change ($c->user->account, 'admin', { 'status' => $status });
        }
    }

    if ($new_namespace) {
        $new_namespace =~ s/^\#//;
        $new_namespace =~ s/-\*//;

        if ( ( my $ns = $namespace_rs->find({ 'namespace' => $new_namespace }) ) ) {
            if (!$ns->status->is_deleted) {
                $c->stash->{error_msg} = "That namespace is already taken";
                $c->detach ('edit_channel_namespaces');
            } else {
                $ns->change ($c->user->account, 'admin', { 'status' => 'active', 'group_id' => $group->id });
            }
        } else {
            try {
                $group->add_to_channel_namespaces ({ 'group_id' => $group->id, 'account' => $c->user->account, 'namespace' => $new_namespace, 'status' => 'active' });
            } catch (GMS::Exception::InvalidNamespace $e) {
                $c->stash->{errors} = $e->message;
                $c->stash->{prev_namespace} = $new_namespace;
                $c->detach ('edit_channel_namespaces');
            }
        }
    }

    $c->stash->{msg} = 'Namespaces updated successfully,';
    $c->stash->{template} = 'admin/action_done.tt';
}

=head2 edit_cloak_namespaces

Shows the group's cloak namespaces and allows the admin to
change namespaces or add new namespaces.

=cut

sub edit_cloak_namespaces :Chained('single_group') :PathPart('edit_cloak_namespaces') :Args(0) {
    my ($self, $c) = @_;

    my $group = $c->stash->{group};
    my @cloak_namespaces = $group->cloak_namespaces;

    $c->stash->{cloak_namespaces} = \@cloak_namespaces;
    $c->stash->{template} = 'admin/edit_cloak_namespaces.tt';
}

=head2 do_edit_cloak_namespaces

Processes the form to edit cloak namespaces or add a new cloak namespace for the group

=cut

sub do_edit_cloak_namespaces :Chained('single_group') :PathPart('edit_cloak_namespaces/submit') :Args(0) {
    my ($self, $c) = @_;

    my $group = $c->stash->{group_row};
    my $p = $c->request->params;
    my $new_namespace = $p->{namespace};

    my @namespaces = $group->cloak_namespaces;

    my $namespace_rs = $c->model("DB::CloakNamespace");

    foreach my $namespace (@namespaces) {
        my $namespace_id = $namespace->id;

        if ($p->{"edit_$namespace_id"}) {
            my $status = $p->{"status_$namespace_id"};
            $namespace->change ($c->user->account, 'admin', { 'status' => $status });
        }
    }

    if ($new_namespace) {
        $new_namespace =~ s|/||;
        $new_namespace =~ s/\*//;

        if ( ( my $ns = $namespace_rs->find({ 'namespace' => $new_namespace }) ) ) {
            if (!$ns->status->is_deleted) {
                $c->stash->{error_msg} = "That namespace is already taken";
                $c->detach ('edit_cloak_namespaces');
            } else {
                $ns->change ($c->user->account, 'admin', { 'status' => 'active', 'group_id' => $group->id });
            }
        } else {
            try {
                $group->add_to_cloak_namespaces ({ 'group_id' => $group->id, 'account' => $c->user->account, 'namespace' => $new_namespace, 'status' => 'active' });
            } catch (GMS::Exception::InvalidNamespace $e) {
                $c->stash->{errors} = $e->message;
                $c->stash->{prev_namespace} = $new_namespace;
                $c->detach ('edit_cloak_namespaces');
            }
        }
    }

    $c->stash->{msg} = 'Namespaces updated successfully';
    $c->stash->{template} = 'admin/action_done.tt';
}

=head2 edit_account

Displays the form to edit a user's contact information.
If the form hasn't been submitted already,
it is populated with the contact's current data.
=cut

sub edit_account :Chained('account') :PathPart('edit') :Args(0) {
    my ($self, $c) = @_;

    my $account = $c->stash->{account};
    my $contact = $account->contact;

    if ($contact) {

        my $active_change = $contact->active_change;
        my $last_change = $contact->last_change;
        my $change;

        if ($last_change->change_type->is_request) {
            $change = $last_change;
            $c->stash->{status_msg} = "Warning: There is already a change request pending for this contact.
             As a result, information from the current request is used instead of the active change.";
        } else {
            $change = $active_change;
        }

        if (!$c->stash->{form_submitted}) {
            $c->stash->{user_name} = $change->name;
            $c->stash->{user_email} = $change->email;
            $c->stash->{phone} = $change->phone;
        }
    }

    $c->stash->{template} = 'admin/edit_account.tt';
}

=head2 do_edit_account

Processes the contact information edit form.
Similar to L<GMS::Web::Controller::Userinfo/update>,
but only handles updating and not defining and the
change_type is 'admin'

=cut

sub do_edit_account :Chained('account') :PathPart('edit/submit') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my $account = $c->stash->{account};
    my $contact = $account->contact;

    try {
        if ($contact) {
            $contact->change (
                $c->user->account->id,
                'admin', {
                    'name' => $params->{user_name},
                    'email' => $params->{user_email},
                    phone => $params->{phone},
                    'change_freetext' => $params->{freetext}
                }
            );
        } else {
            $contact = $c->model('DB::Contact')->create({
                account_id      => $account->id,
                name            => $params->{user_name},
                email           => $params->{user_email},
                phone           => $params->{phone},
                change_freetext => $params->{freetext}
            });
        }
    }
    catch (GMS::Exception::InvalidChange $e) {
        $c->stash->{errors} = $e->message;
        %{$c->stash} = ( %{$c->stash}, %$params );
        $c->stash->{form_submitted} = 1;
        $c->detach('edit_account');
    }

    $c->stash->{msg} = "Successfully edited the user's contact information.";
    $c->stash->{template} = 'admin/action_done.tt';
}

=head2 search_changes

Presents the form to search changes.

=cut

sub search_changes :Chained('/admin/admin_only') :PathPart('search_changes') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'admin/search_changes.tt';
}

=head2 do_search_changes

Processes the form to search changes,
and displays the results.

=cut

sub do_search_changes :Chained('/admin/admin_only') :PathPart('search_changes/submit') :Args(0) {
    my ($self, $c) = @_;
    my ($change_rs, $rs, $page, @results);

    my $p = $c->request->params;
    my $change_item = $p->{change_item} || 0;

    my $current_page = $p->{current_page} || 1;
    my $next = $p->{next} || '';

    if ($next eq 'Next page') {
        $page = $current_page + 1;
    } elsif ($next eq 'Previous page') {
        $page = $current_page - 1;
    } elsif ($next eq 'First page') {
        $page = 1;
    } elsif ($next eq 'Last page') {
        $page = $p->{last_page};
    } else {
        $page = $p->{page} || $current_page;
    }

    if ($change_item == 1) { #GroupContactChanges
        $change_rs = $c->model('DB::GroupContactChange');

        my $accname = $p->{gc_accname};
        my $groupname = $p->{gc_groupname} || '%';
        my $account_search;

        if ($accname) {
            try {
                my $accounts = $c->model('Accounts');
                my $account = $accounts->find_by_name ( $accname );
                my $uid = $account->id;

                $account_search = $uid;
            }
            catch (RPC::Atheme::Error $e) {
                $c->stash->{error_msg} = "The following error occurred when attempting to communicate with atheme: " . $e->description . ". Data displayed below may not be current.";

                my $account_rs = $c->model('DB::Account');
                my $account = $account_rs->find ({ accountname => $accname });

                if (!$account) {
                    $c->stash->{error_msg} = "Could not find an account with that account name.";
                    $c->detach ('search_changes');
                }

                my $uid = $account->id;
                $account_search = $uid;
            }
            catch (GMS::Exception $e) {
                $c->stash->{error_msg} = $e->message;
                $c->detach('search_changes');
            }
        } else {
            $account_search = { 'ilike', '%' };
        }

        $groupname =~ s#_#\\_#g; #escape _ so it's not used as a wildcard.

        $rs = $change_rs -> search(
            {
                'contact.account_id' => $account_search,
                'group.group_name' => { 'ilike', '%' . $groupname . '%' }
            },
            {
                join => { 'group_contact' => [ 'contact', 'group' ] },
                order_by => 'id',
                page => $page,
                rows => 15
            },
        );

        my @rows = $rs->all;

        try {
            my $session = $c->model('Atheme')->session;

            foreach my $row (@rows) {
                my $gc_change = GMS::Domain::GroupContactChange->new ( $session, $row );
                push @results, $gc_change;
            }
        }
        catch (RPC::Atheme::Error $e) {
            @results = @rows;
            $c->stash->{error_msg} = "The following error occurred when attempting to communicate with atheme: " . $e->description . ". Data displayed below may not be current.";
        }

        $c->stash->{template} = 'admin/search_gcc_results.tt';
    } elsif ($change_item == 2) { #GroupChanges
        $change_rs = $c->model('DB::GroupChange');

        my $groupname = $p->{group_name} || '%';
        $groupname =~ s#_#\\_#g;

        $rs = $change_rs -> search(
            { 'group.group_name' => { 'ilike', '%' . $groupname . '%' } },
            {
                join => 'group',
                order_by => 'id',
                page => $page,
                rows => 15
            },
        );

        my @rows = $rs->all;

        try {
            my $session = $c->model('Atheme')->session;

            foreach my $row (@rows) {
                my $gc_change = GMS::Domain::GroupChange->new ( $session, $row );
                push @results, $gc_change;
            }
        }
        catch (RPC::Atheme::Error $e) {
            @results = @rows;
            $c->stash->{error_msg} = "The following error occurred when attempting to communicate with atheme: " . $e->description . ". Data displayed below may not be current.";
        }

        $c->stash->{template} = 'admin/search_gc_results.tt';
    } elsif ($change_item == 4) { #ChannelNamespaceChanges
        $change_rs = $c->model('DB::ChannelNamespaceChange');

        my $namespace = $p->{namespace} || '%';
        my $groupname = $p->{groupname} || '%';

        $namespace =~ s#_#\\_#g;
        $groupname =~ s#_#\\_#g;

        $rs = $change_rs -> search(
            {
                'namespace.namespace' => { 'ilike', '%' . $namespace . '%' },
                'group.group_name' => { 'ilike', '%' . $groupname . '%' }
            },
            {
                join => [ 'namespace', 'group' ],
                order_by => 'id',
                page => $page,
                rows => 15
            },
        );

        my @rows = $rs->all;

        try {
            my $session = $c->model('Atheme')->session;

            foreach my $row (@rows) {
                my $gc_change = GMS::Domain::ChannelNamespaceChange->new ( $session, $row );
                push @results, $gc_change;
            }
        }
        catch (RPC::Atheme::Error $e) {
            @results = @rows;
            $c->stash->{error_msg} = "The following error occurred when attempting to communicate with atheme: " . $e->description . ". Data displayed below may not be current.";
        }

        $c->stash->{template} = 'admin/search_cnc_results.tt';
    } elsif ($change_item == 5) { #CloakNamespaceChanges
        $change_rs = $c->model('DB::CloakNamespaceChange');

        my $namespace = $p->{cloak_namespace} || '%';
        my $groupname = $p->{cloak_groupname} || '%';

        $namespace =~ s#_#\\_#g;
        $groupname =~ s#_#\\_#g;

        $rs = $change_rs -> search(
            {
                'namespace.namespace' => { 'ilike', '%' .  $namespace  . '%'},
                'group.group_name' => { 'ilike', '%' . $groupname . '%' }
            },
            {
                join => [ 'namespace', 'group' ],
                order_by => 'id',
                page => $page,
                rows => 15
            },
        );

        my @rows = $rs->all;

        try {
            my $session = $c->model('Atheme')->session;

            foreach my $row (@rows) {
                my $gc_change = GMS::Domain::CloakNamespaceChange->new ( $session, $row );
                push @results, $gc_change;
            }
        }
        catch (RPC::Atheme::Error $e) {
            @results = @rows;
            $c->stash->{error_msg} = "The following error occurred when attempting to communicate with atheme: " . $e->description . ". Data displayed below may not be current.";
        }

        $c->stash->{template} = 'admin/search_clnc_results.tt';
    } elsif ($change_item == 6) { #CloakChanges
        $change_rs = $c->model('DB::CloakChangeChange');

        my $cloak = $p->{cloak};
        my $accountname = $p->{cloak_accountname};
        my $account_search;

        if ($accountname) {
            try {
                my $accounts = $c->model('Accounts');
                my $account = $accounts->find_by_name ( $accountname );
                my $uid = $account->id;

                $account_search = $uid;
            }
            catch (RPC::Atheme::Error $e) {
                $c->stash->{error_msg} = "The following error occurred when attempting to communicate with atheme: " . $e->description . ". Data displayed below may not be current.";

                my $account_rs = $c->model('DB::Account');
                my $account = $account_rs->find ({ accountname => $accountname });

                if (!$account) {
                    $c->stash->{error_msg} = "Could not find an account with that account name.";
                    $c->detach ('search_changes');
                }

                my $uid = $account->id;
                $account_search = $uid;
            }
            catch (GMS::Exception $e) {
                $c->stash->{error_msg} = $e->message;
                $c->detach('search_changes');
            }
        } else {
            $account_search = { 'ilike', '%' };
        }

        $rs = $change_rs -> search(
            {
                'target' => $account_search
            },
            {
                join => { cloak_change => 'target' },
                order_by => 'id',
                page => $page,
                rows => 15
            }
        );

        my @rows = $rs->all;

        try {
            my $session = $c->model('Atheme')->session;

            foreach my $row (@rows) {
                my $gc_change = GMS::Domain::CloakChangeChange->new ( $session, $row );
                push @results, $gc_change;
            }
        }
        catch (RPC::Atheme::Error $e) {
            @results = @rows;
            $c->stash->{error_msg} = "The following error occurred when attempting to communicate with atheme: " . $e->description . ". Data displayed below may not be current.";
        }

        $c->stash->{template} = 'admin/search_clc_results.tt';
    } elsif ($change_item == 7) { #ChannelRequestChanges
        $change_rs = $c->model('DB::ChannelRequestChange');

        my $channel = $p->{channel};
        my $target = $p->{target};
        my $requestor = $p->{requestor};

        my ($target_search, $requestor_search);

        if ($target) {
            try {
                my $accounts = $c->model('Accounts');
                my $account = $accounts->find_by_name ( $target );
                my $uid = $account->id;

                $target_search = $uid;
            }
            catch (RPC::Atheme::Error $e) {
                $c->stash->{error_msg} = "The following error occurred when attempting to communicate with atheme: " . $e->description . ". Data displayed below may not be current.";

                my $account_rs = $c->model('DB::Account');
                my $account = $account_rs->find ({ accountname => $target });

                if (!$account) {
                    $c->stash->{error_msg} = "Could not find an account with that account name.";
                    $c->detach ('search_changes');
                }

                my $uid = $account->id;
                $target_search = $uid;
            }
            catch (GMS::Exception $e) {
                $c->stash->{error_msg} = $e->message;
                $c->detach('search_changes');
            }
        } else {
            $target_search = { 'ilike', '%' };
        }

        if ($requestor) {
            try {
                my $accounts = $c->model('Accounts');
                my $account = $accounts->find_by_name ( $requestor );
                my $uid = $account->id;

                $requestor_search = $uid;
            }
            catch (RPC::Atheme::Error $e) {
                $c->stash->{error_msg} = "The following error occurred when attempting to communicate with atheme: " . $e->description . ". Data displayed below may not be current.";

                my $account_rs = $c->model('DB::Account');
                my $account = $account_rs->find ({ accountname => $requestor });

                if (!$account || !$account->contact) {
                    $c->stash->{error_msg} = "Could not find an account with that account name.";
                    $c->detach ('search_changes');
                }

                my $uid = $account->id;
                $requestor_search = $uid;
            }
            catch (GMS::Exception $e) {
                $c->stash->{error_msg} = $e->message;
                $c->detach('search_changes');
            }
        } else {
            $requestor_search = { 'ilike', '%' };
        }

        $rs = $change_rs -> search(
            {
                'target' => $target_search,
                'requestor.account_id' => $requestor_search
            },
            {
                join => { channel_request => [ 'target', 'requestor' ] },
                order_by => 'id',
                page => $page,
                rows => 15
            }
        );

        my @rows = $rs->all;

        try {
            my $session = $c->model('Atheme')->session;

            foreach my $row (@rows) {
                my $gc_change = GMS::Domain::ChannelRequestChange->new ( $session, $row );
                push @results, $gc_change;
            }
        }
        catch (RPC::Atheme::Error $e) {
            @results = @rows;
            $c->stash->{error_msg} = "The following error occurred when attempting to communicate with atheme: " . $e->description . ". Data displayed below may not be current.";
        }

        $c->stash->{template} = 'admin/search_crc_results.tt';
    } elsif (! $change_item ) {
        $c->detach ('search_changes');
    } else {
        $c->stash->{error_msg} = 'Invalid option';
        $c->detach ('search_changes');
    }

    my $pager = $rs->pager;

    %{$c->stash} = ( %{$c->stash}, %$p );
    $c->stash->{current_page} = $page;
    $c->stash->{last_page} = $pager->last_page;

    $c->stash->{results} = \@results;
}

=head2 admin

Lists users and roles

=cut

sub admin :Chained('/admin/admin_only') :PathPart('admin') {
    my ($self, $c) = @_;

    my @admins = $c->model('DB::UserRole')->search({}, {join => ['role', 'account']});

    my @roles = $c->model('DB::Role')->all;

    $c->stash->{admins} = \@admins;
    $c->stash->{roles} = \@roles;

    $c->stash->{user_id} = $c->user->account->id;

    $c->stash->{template} = 'admin/admin.tt';
}

=head2 del_admin

Removes a role from a user.

=cut

sub del_admin :Chained('/admin/admin_only') :PathPart('admin/delete') {
    my ($self, $c) = @_;

    my $p = $c->request->params;

    if ($p->{'role'} && $p->{'account'}) {
        my $admin = $c->model('DB::UserRole')->find({
            'role_id'     => $p->{'role'},
            'account_id'  => $p->{'account'}
          });

        if ($admin) {
            $admin->delete;
            $c->flash->{status_msg} = "Successfully removed role.";
        } else {
            $c->flash->{error_msg} = "Role not found.";
        }
    } else {
        $c->flash->{error_msg} = "You did not provide a role and user.";
    }


    $c->response->redirect($c->uri_for('/admin/admin'));
}


=head2 add_admin

Adds a role from a user.

=cut

sub add_admin :Chained('/admin/admin_only') :PathPart('admin/add') {
    my ($self, $c) = @_;

    my $p = $c->request->params;

    if ($p->{'role'} && $p->{'account'}) {
        my $account = $c->model('DB::Account')->find({
            'accountname' => $p->{'account'}
        });

        if (!$account) {
            $c->flash->{error_msg} = "Account not found";
            $c->response->redirect($c->uri_for('/admin/admin'));
            $c->detach;
        }

        my $role = $c->model('DB::Role')->find({
            'id'     => $p->{'role'},
          });

        if (!$role) {
            $c->flash->{error_msg} = "Role not found";
            $c->response->redirect($c->uri_for('/admin/admin'));
            $c->detach;
        }

        my $user_role = $c->model('DB::UserRole')->find({
            'role_id'     => $role->id,
            'account_id'  => $account->id,
        });

        if ($user_role) {
            $c->flash->{error_msg} = "This user already has this role";
            $c->response->redirect($c->uri_for('/admin/admin'));
            $c->detach;
        }

        $c->model('DB::UserRole')->create({
                'account_id' => $account->id,
                'role_id'    => $role->id,
            });

        $c->flash->{status_msg} = "Successfully added role.";
    } else {
        $c->flash->{error_msg} = "You did not provide a role and user.";
    }

    $c->response->redirect($c->uri_for('/admin/admin'));
}

1;
