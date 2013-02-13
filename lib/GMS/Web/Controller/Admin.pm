package GMS::Web::Controller::Admin;

use strict;
use warnings;
use base qw (GMS::Web::TokenVerification);

use TryCatch;
use GMS::Exception;

=head1 NAME

GMS::Web::Controller::Admin - Controller for GMS::Web

=head1 DESCRIPTION

This controller contains handlers for the administrative pages.

=head1 METHODS

=head2 base

Base method for all the handler chains. Verifies that the user has the 'admin'
role, and presents an error page if not.

=cut

sub base :Chained('/') :PathPart('admin') :CaptureArgs(0) :Local :VerifyToken {
    my ($self, $c) = @_;

    if (! $c->check_user_roles('admin')) {
        $c->detach('/forbidden');
    }

    $c->stash->{admin} = 1;
}

=head2 index

Administrative home page.

=cut

sub index :Chained('base') :PathPart('') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{pending_groups} = $c->model('DB::Group')->search_verified_groups->count + $c->model('DB::Group')->search_submitted_groups->count;
    $c->stash->{pending_namespaces} = $c->model('DB::ChannelNamespace')->search_pending->count + $c->model('DB::CloakNamespace')->search_pending->count;
    $c->stash->{pending_contacts} = $c->model('DB::GroupContact')->search_pending->count;

    $c->stash->{pending_changes} =
      $c->model('DB::GroupContactChange')->active_requests->count
      + $c->model('DB::GroupChange')->active_requests->count
      + $c->model('DB::ContactChange')->active_requests->count
      + $c->model('DB::ChannelNamespaceChange')->active_requests->count
      + $c->model('DB::CloakNamespaceChange')->active_requests->count;

    $c->stash->{pending_cloaks} = $c->model('DB::CloakChange')->search_pending->count;

    $c->stash->{template} = 'admin/index.tt';
}

=head2 single_group

Chained method to select a single group. Similar to
L<GMS::Web::Controller::Group/single_group>, but searches all groups, not those
for which the user is a contact.

=cut

sub single_group :Chained('base') :PathPart('') :CaptureArgs(1) {
    my ($self, $c, $group_id) = @_;

    my $group = $c->model('DB::Group')->find({ id => $group_id });

    if ($group) {
        $c->stash->{group} = $group;
    } else {
        $c->detach('/default');
    }
}

=head2 address

Chained method to select an address. Admins can view addresses
for all groups and users.

=cut

sub address :Chained('base') :PathPart('address') :CaptureArgs(1) {
    my ($self, $c, $address_id) = @_;

    my $address = $c->model('DB::Address')->find({ id => $address_id });

    if ($address) {
        $c->stash->{address} = $address;
    } else {
        $c->detach('default');
    }
}

=head2 account

Chained method to select an account.

=cut

sub account :Chained('base') :PathPart('account') :CaptureArgs(1) {
    my ($self, $c, $account_id) = @_;

    my $account = $c->model('DB::Account')->find ({ id => $account_id });

    if ($account) {
        $c->stash->{account} = $account;
    } else {
        $c->detach('/default');
    }
}

=head2 approve

Presents the group approval form.

=cut

sub approve :Chained('base') :PathPart('approve') :Args(0) {
    my ($self, $c) = @_;

    my @to_approve = $c->model('DB::Group')->search_verified_groups;
    my @to_verify  = $c->model('DB::Group')->search_submitted_groups;

    $c->stash->{to_approve} = \@to_approve;
    $c->stash->{to_verify} = \@to_verify;
    $c->stash->{template} = 'admin/approve.tt';
}

=head2 do_approve

Handler for the group approval form. Verifies, approves, or rejects those groups
selected for it.

=cut

sub do_approve :Chained('base') :PathPart('approve/submit') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my $group_rs = $c->model('DB::Group');
    my $account = $c->user->account;

    my @approve_groups = split / /, $params->{approve_groups};
    my @verify_groups  = split / /, $params->{verify_groups};
    try {
        $c->model('DB')->schema->txn_do(sub {
            foreach my $group_id (@approve_groups, @verify_groups) {
                my $group = $group_rs->find({ id => $group_id });
                my $action = $params->{"action_$group_id"};
                my $freetext = $params->{"freetext_$group_id"};

                if ($action eq 'approve') {
                    $c->log->info("Approving group id $group_id (" .
                        $group->group_name . ") by " . $c->user->username . "\n");
                    $group->approve($account, $freetext);
                } elsif ($action eq 'reject') {
                    $c->log->info("Rejecting group id $group_id (" .
                        $group->group_name . ") by " . $c->user->username . "\n");
                    $group->reject($account, $freetext);
                } elsif ($action eq 'verify') {
                    $c->log->info("Verifying group id $group_id (" .
                        $group->group_name . ") by " . $c->user->username . "\n");
                    $group->verify($account, $freetext);
                } elsif ($action eq 'hold') {
                    next;
                } else {
                    $c->log->error("Got unknown action $action for group id
                        $group_id in Admin::do_approve");
                }
            }
        });
        $c->response->redirect($c->uri_for('approve'));
    }
    catch (GMS::Exception $e) {
        $c->stash->{error_msg} = $e->message;
        $c->detach ("/admin/approve");
    }

}

=head2 approve_new_gc

Presents the form to approve new contact additions.

=cut

sub approve_new_gc :Chained('base') :PathPart('approve_new_gc') :Args(0) {
    my ($self, $c) = @_;

    my @to_approve = $c->model('DB::GroupContact')->search_pending;

    $c->stash->{to_approve} = \@to_approve;
    $c->stash->{template} = 'admin/approve_new_gc.tt';
}

=head2 do_approve_new_gc

Handler for the group contact approval form. Verifies, approves, or rejects those group
contacts selected for it.

=cut

sub do_approve_new_gc :Chained('base') :PathPart('approve_new_gc/submit') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my $rs = $c->model('DB::GroupContact');
    my $account = $c->user->account;

    my @approve_contacts = split / /, $params->{approve_contacts};
    try {
        $c->model('DB')->schema->txn_do(sub {
            foreach my $contact_id (@approve_contacts) {
                my $gc = $rs->find_by_id($contact_id);
                my $action = $params->{"action_$contact_id"};
                my $freetext = $params->{"freetext_$contact_id"};

                if ($action eq 'approve') {
                    $c->log->info("Approving group contact id $contact_id for group $gc->group->id (" .
                        $gc->contact->account->accountname . " is now group contact for " .
                        $gc->group->group_name . ") by " . $c->user->username . "\n");
                    $gc->approve($account, $freetext);
                } elsif ($action eq 'reject') {
                    $c->log->info("Rejecting group contact id $contact_id for group $gc->group->id (" .
                        $gc->contact->account->accountname . " rejected as group contact for " .
                        $gc->group->group_name . ") by " . $c->user->username . "\n");
                    $gc->reject($account, $freetext);
                } elsif ($action eq 'hold') {
                    next;
                } else {
                    $c->log->error("Got unknown action $action for gc id
                        $contact_id (group $gc->group->id) in Admin::do_approve_new_gc");
                }
            }
        });
        $c->response->redirect($c->uri_for('approve_new_gc'));
    }
    catch (GMS::Exception $e) {
        $c->stash->{error_msg} = $e->message;
        $c->detach ("/admin/approve_new_gc");
    }
}

=head2 approve_change

Presents changes pending approval.

=cut

sub approve_change :Chained('base') :PathPart('approve_change') :Args(0) {
    my ($self, $c) = @_;

    my $change_item = $c->request->params->{change_item};
    my @to_approve;
    $c->stash->{change_item} = $change_item;

    if ($change_item && $change_item == 1) { #group contact change
        @to_approve = $c->model ("DB::GroupContactChange")->active_requests();
    } elsif ($change_item && $change_item == 2) { #group change
        @to_approve = $c->model ("DB::GroupChange")->active_requests();
    } elsif ($change_item && $change_item == 3) { #contact change
        @to_approve = $c->model ("DB::ContactChange")->active_requests();
    } elsif ($change_item && $change_item == 4) { #channel namespace change
        @to_approve = $c->model ("DB::ChannelNamespaceChange")->active_requests();
    } elsif ($change_item && $change_item == 5) { #cloak namespace change
        @to_approve = $c->model ("DB::CloakNameSpaceChange")->active_requests();
    }

    $c->stash->{pending_groupcontact} = $c->model("DB::GroupContactChange")->active_requests->count;
    $c->stash->{pending_group} = $c->model("DB::GroupChange")->active_requests->count;
    $c->stash->{pending_contact} = $c->model("DB::ContactChange")->active_requests->count;
    $c->stash->{pending_cns} = $c->model("DB::ChannelNamespaceChange")->active_requests->count;
    $c->stash->{pending_clns} = $c->model("DB::CloakNameSpaceChange")->active_requests->count;

    $c->stash->{to_approve} = \@to_approve;

    if ($change_item && $change_item == 1) {
        $c->stash->{template} = 'admin/approve_gcc.tt';
    } elsif ($change_item && $change_item == 2) {
        $c->stash->{template} = 'admin/approve_gc.tt';
    } elsif ($change_item && $change_item == 3) {
        $c->stash->{template} = 'admin/approve_cc.tt';
    } elsif ($change_item && $change_item == 4) {
        $c->stash->{template} = 'admin/approve_cnc.tt';
    } elsif ($change_item && $change_item == 5) {
        $c->stash->{template} = 'admin/approve_clnc.tt';
    } elsif (! $change_item) {
        $c->stash->{template} = 'admin/approve_change.tt';
    }
}

=head2 do_approve_change

Processes the change approval form.
Accepted changes become the object's
current active change.

=cut

sub do_approve_change :Chained('base') :PathPart('approve_change/submit') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my $change_item = $params->{change_item};
    my $change_rs;
    my $type;

    if ($change_item == 1) { #group contact change
        $change_rs = $c->model('DB::GroupContactChange');
        $type = "GroupContactChange";
    } elsif ($change_item == 2) { #group change
        $change_rs = $c->model('DB::GroupChange');
        $type = "GroupChange";
    } elsif ($change_item == 3) { #contact change
        $change_rs = $c->model('DB::ContactChange');
        $type = "ContactChange";
    } elsif ($change_item == 4) { #channel namespace change
        $change_rs = $c->model('DB::ChannelNamespaceChange');
        $type = "ChannelNamespaceChange";
    } elsif ($change_item == 5) { #cloak namespace change
        $change_rs = $c->model('DB::CloakNamespaceChange');
        $type = "CloakNamespaceChange";
    }

    my $account = $c->user->account;

    my @approve_changes = split / /, $params->{approve_changes};
    try {
        $c->model('DB')->schema->txn_do(sub {
            foreach my $change_id (@approve_changes) {
                my $change = $change_rs->find({ id => $change_id });
                my $action = $params->{"action_$change_id"};
                my $freetext = $params->{"freetext_$change_id"};

                if ($action eq 'approve') {
                    $c->log->info("Approving $type id $change_id" .
                        " by " . $c->user->username . "\n");
                    $change->approve ($account, $freetext);
                } elsif ($action eq 'reject') {
                    $c->log->info("Rejecting $type id $change_id" .
                        " by " . $c->user->username . "\n");
                    $change->reject ($account, $freetext);
                } elsif ($action eq 'hold') {
                    next;
                } else {
                    $c->log->error("Got unknown action $action for $type id
                        $change_id in Admin::do_approve_change");
                }
            }
        });
        $c->response->redirect($c->uri_for('approve_change', '', { 'change_item' => $change_item }));
    }
    catch (GMS::Exception $e) {
        $c->stash->{error_msg} = $e->message;
        $c->detach ("/admin/approve_change");
    }
}

=head2 approve_cloak

Presents the form to approve cloak changes.

=cut

sub approve_cloak :Chained('base') :PathPart('approve_cloak') :Args(0) {
    my ($self, $c) = @_;

    my $change_rs = $c->model('DB::CloakChange');

    my @to_approve = $change_rs->search_pending;

    $c->stash->{to_approve} = \@to_approve;

    $c->stash->{template} = 'admin/approve_cloak.tt';
}

=head2 do_approve_cloak

Processes the form to approve cloak changes and grants the cloaks to the users.

=cut

sub do_approve_cloak :Chained('base') :PathPart('approve_cloak/submit') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my $change_item = $params->{change_item};

    my $account = $c->user->account;

    my $change_rs = $c->model('DB::CloakChange');
    my @approve_changes = split / /, $params->{approve_changes};

    try {
        $c->model('DB')->schema->txn_do(sub {
            foreach my $change_id (@approve_changes) {
                my $change = $change_rs->find({ id => $change_id });
                my $action = $params->{"action_$change_id"};
                my $freetext = $params->{"freetext_$change_id"};

                if ($action eq 'approve') {
                    $c->log->info("Approving CloakChange id $change_id" .
                        " by " . $c->user->username . "\n");
                    $change->approve ($c, $freetext);
                } elsif ($action eq 'reject') {
                    $c->log->info("Rejecting CloakChange id $change_id" .
                        " by " . $c->user->username . "\n");
                    $change->reject ($freetext);
                } elsif ($action eq 'hold') {
                    next;
                } else {
                    $c->log->error("Got unknown action $action for CloakChange id
                        $change_id in Admin::do_approve_cloak");
                }
            }
        });
        $c->response->redirect($c->uri_for('approve_cloak'));
    }
    catch (RPC::Atheme::Error $e) {
        $c->stash->{error_msg} = $e->description;
        $c->detach ("/admin/approve_cloak");
    }
}

=head2 approve_namespaces

Presents the form to accept channel and cloak namespaces.

=cut

sub approve_namespaces :Chained('base') :PathPart('approve_namespaces') :Args(0) {
    my ($self, $c) = @_;

    my $approve_item = $c->request->params->{approve_item};
    my @to_approve;
    $c->stash->{approve_item} = $approve_item;

    if ($approve_item && $approve_item == 1) { #channel namespaces
        @to_approve = $c->model ("DB::ChannelNamespace")->search_pending();
    } elsif ($approve_item && $approve_item == 2) { #cloak namespces
        @to_approve = $c->model ("DB::CloakNamespace")->search_pending();
    }

    $c->stash->{to_approve} = \@to_approve;

    $c->stash->{pending_channel} = $c->model ("DB::ChannelNamespace")->search_pending->count;
    $c->stash->{pending_cloak} = $c->model ("DB::CloakNamespace")->search_pending->count;

    if ($approve_item && $approve_item == 1) {
        $c->stash->{template} = 'admin/approve_channel_namespaces.tt';
    } elsif ($approve_item && $approve_item == 2) {
        $c->stash->{template} = 'admin/approve_cloak_namespaces.tt';
    }
}

=head2 do_approve_namespaces

Processes the form to approve namespaces.

=cut

sub do_approve_namespaces :Chained('base') :PathPart('approve_namespaces/submit') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my $namespace_rs;
    my $type;

    my $approve_item = $c->request->params->{approve_item};

    if ($approve_item == 1) { #channel namespaces
        $namespace_rs = $c->model ("DB::ChannelNamespace");
        $type = "ChannelNamespace";
    } elsif ($approve_item == 2) { #cloak namespces
        $namespace_rs = $c->model ("DB::CloakNamespace");
        $type = "CloakNamespace";
    }

    my $account = $c->user->account;

    my @approve_namespaces = split / /, $params->{approve_namespaces};

    try {
        $c->model('DB')->schema->txn_do(sub {
            foreach my $namespace_id (@approve_namespaces) {
                my $namespace = $namespace_rs->find({ id => $namespace_id });
                my $action = $params->{"action_$namespace_id"};
                my $freetext = $params->{"freetext_$namespace_id"};

                if ($action eq 'approve') {
                    $c->log->info("Approving $type id $namespace_id" .
                        " by " . $c->user->username . "\n");
                    $namespace->approve ($account, $freetext);
                } elsif ($action eq 'reject') {
                    $c->log->info("Rejecting $type id $namespace_id" .
                        " by " . $c->user->username . "\n");
                    $namespace->reject ($account, $freetext);
                } elsif ($action eq 'hold') {
                    next;
                } else {
                    $c->log->error("Got unknown action $action for channel namespace id
                        $namespace_id in Admin::do_approve_channel_namespaces");
                }
            }
        });
        $c->response->redirect($c->uri_for('approve_namespaces', '', { 'approve_item' => $approve_item }));
    }
    catch (GMS::Exception $e) {
        $c->stash->{error_msg} = $e->message;
        $c->detach ("/admin/approve_namespaces");
    }
}

=head2 view

Displays information about a single group.

=cut

sub view :Chained('single_group') :PathPart('view') :Args(0) {
    my ($self, $c) = @_;

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
        my $group = $c->stash->{group};

        try {
            $group->add_contact ($contact, $c->user->account->id, { 'freetext' => $p->{freetext} });
        }
        catch (GMS::Exception $e) {
            $c->stash->{error_msg} = $e;
            $c->detach ("add_gc");
        }
    }

    $c->stash->{msg} = "Successfully added the group contact.";
    $c->stash->{template} = 'staff/action_done.tt';
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
    my $group = $c->stash->{group};
    my $address;

    try {
        if ($p->{has_address} eq 'y' && $p->{update_address} eq 'y') {
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
            "If the group has its own address, then a valid address must be specified.",
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
    $c->stash->{template} = 'staff/action_done.tt';
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

    my $group = $c->stash->{group};
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
    $c->stash->{template} = 'staff/action_done.tt';
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

    my $group = $c->stash->{group};
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
    $c->stash->{template} = 'staff/action_done.tt';
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

    my $group = $c->stash->{group};
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
    $c->stash->{template} = 'staff/action_done.tt';
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

    my $address = $change->address;

    if (!$c->stash->{form_submitted}) {
        $c->stash->{user_name} = $change->name;
        $c->stash->{user_email} = $change->email;

        $c->stash->{address_one} = $address->address_one;
        $c->stash->{address_two} = $address->address_two;
        $c->stash->{city} = $address->city;
        $c->stash->{state} = $address->state;
        $c->stash->{postcode} = $address->code;
        $c->stash->{country} = $address->country;
        $c->stash->{phone_one} = $address->phone;
        $c->stash->{phone_two} = $address->phone2;
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
    my $address;

    try {
        if ($params->{update_address} eq 'y') {
            $address = $c->model('DB::Address')->create({
                    address_one => $params->{address_one},
                    address_two => $params->{address_two},
                    city => $params->{city},
                    state => $params->{state},
                    code => $params->{postcode},
                    country => $params->{country},
                    phone => $params->{phone_one},
                    phone2 => $params->{phone_two}
                });
        }

        $contact->change ($c->user->account->id, 'admin', { 'name' => $params->{user_name}, 'email' => $params->{user_email}, address => $address, 'change_freetext' => $params->{freetext} });
    }
    catch (GMS::Exception::InvalidAddress $e) {
        $c->stash->{errors} = $e->message;
        %{$c->stash} = ( %{$c->stash}, %$params );
        $c->stash->{form_submitted} = 1;
        $c->detach('edit_account');
    }
    catch (GMS::Exception::InvalidChange $e) {
        $c->stash->{errors} = $e->message;
        %{$c->stash} = ( %{$c->stash}, %$params );
        $c->stash->{form_submitted} = 1;
        $c->detach('edit_account');
    }

    $c->stash->{msg} = "Successfully edited the user's contact information.";
    $c->stash->{template} = 'staff/action_done.tt';
}

=head2 search_changes

Presents the form to search changes.

=cut

sub search_changes :Chained('base') :PathPart('search_changes') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'admin/search_changes.tt';
}

=head2 do_search_changes

Processes the form to search changes,
and displays the results.

=cut

sub do_search_changes :Chained('base') :PathPart('search_changes/submit') :Args(0) {
    my ($self, $c) = @_;
    my ($change_rs, $rs, $page);

    my $p = $c->request->params;
    my $change_item = $p->{change_item};

    my $current_page = $p->{current_page} || 1;
    my $next = $p->{next};

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
        my $groupname = $p->{gc_groupname};

        $accname =~ s#_#\\_#g; #escape _ so it's not used as a wildcard.
        $groupname =~ s#_#\\_#g;

        $rs = $change_rs -> search(
            {
                'account.accountname' => { 'ilike', $accname },
                'group.group_name' => { 'ilike', $groupname }
            },
            {
                join => { 'group_contact' => [ { 'contact' => 'account' }, 'group' ] },
                order_by => 'id',
                page => $page,
                rows => 15
            },
        );

        $c->stash->{template} = 'admin/search_gcc_results.tt';
    } elsif ($change_item == 2) { #GroupChanges
        $change_rs = $c->model('DB::GroupChange');

        my $groupname = $p->{group_name};
        $groupname =~ s#_#\\_#g;

        $rs = $change_rs -> search(
            { 'group.group_name' => { 'ilike', $groupname } },
            {
                join => 'group',
                order_by => 'id',
                page => $page,
                rows => 15
            },
        );

        $c->stash->{template} = 'admin/search_gc_results.tt';
    } elsif ($change_item == 3) { #ContactChanges
        $change_rs = $c->model('DB::ContactChange');

        my $accname = $p->{accname};
        $accname =~ s#_#\\_#g;

        $rs = $change_rs -> search(
            { 'account.accountname' => { 'ilike', $accname } },
            {
                join => { contact => 'account' },
                order_by => 'id',
                page => $page,
                rows => 15
            }
        );

        $c->stash->{template} = 'admin/search_cc_results.tt';
    } elsif ($change_item == 4) { #ChannelNamespaceChanges
        $change_rs = $c->model('DB::ChannelNamespaceChange');

        my $namespace = $p->{namespace};
        my $groupname = $p->{groupname};

        $namespace =~ s#_#\\_#g;
        $groupname =~ s#_#\\_#g;

        $rs = $change_rs -> search(
            {
                'namespace.namespace' => { 'ilike', $namespace },
                'group.group_name' => { 'ilike', $groupname }
            },
            {
                join => [ 'namespace', 'group' ],
                order_by => 'id',
                page => $page,
                rows => 15
            },
        );

        $c->stash->{template} = 'admin/search_cnc_results.tt';
    } elsif ($change_item == 5) { #CloakNamespaceChanges
        $change_rs = $c->model('DB::CloakNamespaceChange');

        my $namespace = $p->{cloak_namespace};
        my $groupname = $p->{cloak_groupname};

        $namespace =~ s#_#\\_#g;
        $groupname =~ s#_#\\_#g;

        $rs = $change_rs -> search(
            {
                'namespace.namespace' => { 'ilike', $namespace },
                'group.group_name' => { 'ilike', $groupname }
            },
            {
                join => [ 'namespace', 'group' ],
                order_by => 'id',
                page => $page,
                rows => 15
            },
        );

        $c->stash->{template} = 'admin/search_clnc_results.tt';
    } elsif ($change_item == 6) { #CloakChanges
        $change_rs = $c->model('DB::CloakChange');

        my $cloak = $p->{cloak};
        my $accountname = $p->{cloak_accountname};

        $accountname =~ s#_#\\_#g;

        $rs = $change_rs -> search(
            {
                'account.accountname' => { 'ilike', $accountname }
            },
            {
                join => { contact => 'account' },
                order_by => 'id',
                page => $page,
                rows => 15
            }
        );

        $c->stash->{template} = 'admin/search_clc_results.tt';
    }

    my $pager = $rs->pager;
    my @results = $rs->all;

    %{$c->stash} = ( %{$c->stash}, %$p );
    $c->stash->{current_page} = $page;
    $c->stash->{last_page} = $pager->last_page;

    $c->stash->{results} = \@results;
}
1;
