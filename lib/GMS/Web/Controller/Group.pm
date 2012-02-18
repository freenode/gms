package GMS::Web::Controller::Group;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use TryCatch;
use GMS::Exception;

=head1 NAME

GMS::Web::Controller::Group - Controller for GMS::Web

=head1 DESCRIPTION

This controller contains the handlers for group management pages accessible to
group contacts.

=head1 METHODS

=head2 base

Base method for all of the handler chains in this controller. Verifies that the
user is logged in, and that they have contact information defined. If not, then
redirect to the contact information form.

=cut

sub base :Chained('/') :PathPart('group') :CaptureArgs(0) {
    my ($self, $c) = @_;

    if (! $c->user->account || ! $c->user->account->contact) {
        $c->flash->{status_msg} = "You don't yet have any contact information defined.\n" .
                                  "Use this form to enter it before registering a new group.";
        $c->session->{redirect_to} = $c->request->uri;
        $c->response->redirect($c->uri_for('/userinfo'));
    }
}

=head2 index

Show a group contact a list of his active and pending groups.

=cut

sub index :Chained('base') :PathPart('') :Args(0) {
    my ($self, $c) = @_;

    if (! $c->user->account || ! $c->user->account->contact) {
        $c->flash->{status_msg} = "You don't yet have any contact information defined.\n" .
                                  "Use this form to enter it before registering a new group.";
        $c->session->{redirect_to} = $c->request->uri;
        $c->response->redirect($c->uri_for('/userinfo'));
        return;
    }
    $c->stash->{groups} = [];
    $c->stash->{pendinggroups} = [];
    $c->stash->{invitedgroups} = [];

    my $change_rs = $c->model("DB::GroupContactChange");
    my $contact_id = $c->user->account->contact->id;
    my @invitations = $change_rs->active_invitations->search ( { 'contact_id' => $contact_id } );

    foreach my $group ($c->user->account->contact->groups)
    {
        my $list;
        my $gc = $c->user->account->contact->group_contacts->find ({ 'group_id' => $group->id });
        if ($group->status->is_active && $gc->status->is_active) {
            $list = $c->stash->{groups};
        } elsif (! $group->status->is_deleted && ! $group->status->is_active) {
            $list = $c->stash->{pendinggroups};
        }
        push @$list, $group;
    }

    foreach my $invitation (@invitations) {
        if ($invitation->group_contact->group->status->is_active) {
            my $list = $c->stash->{invitedgroups};
            push @$list, $invitation->group_contact->group;
        }
    }

    $c->stash->{template} = 'group/list.tt';
}

=head2 single_group

Chained handler which selects a single group of which the current user is a
contact. Groups for which the user is not a contact are treated as non-existent.

=cut

sub single_group :Chained('base') :PathPart('') :CaptureArgs(1) {
    my ($self, $c, $group_id) = @_;

    my $group = $c->user->account->contact->groups->find({ id => $group_id });

    my $gc = $c->user->account->contact->group_contacts->find ({ 'group_id' => $group_id });

    if ( $group && $gc->can_access ($group, $c->request->path) ) {
        $c->stash->{group} = $group;
    } else {
        $c->stash->{error_msg} = "That group doesn't exist or you can't access it.";
        $c->detach('index');
    }
}

=head2 view

Displays a group's information to one of its contacts.

=cut

sub view :Chained('single_group') :PathPart('view') :Args(0) {
    my ($self, $c) = @_;

    my $group = $c->stash->{group};
    $c->stash->{gc} = $group->group_contacts->find ({ contact_id => $c->user->account->contact->id });

    $c->stash->{template} = 'group/view.tt';
}

sub verify :Chained('single_group') :PathPart('verify') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'group/verify.tt';
}

sub verify_submit :Chained('single_group') :PathPart('verify/submit') :Args(0) {
    my ($self, $c) = @_;

    my $group = $c->stash->{group};
    my $result = $group->auto_verify($c->user->account->id, $c->request->params);
    if ($result == 1) {
        $c->stash->{msg} = "Group successfully verified. Please wait for staff to approve or decline your group request";
    }
    elsif ($result == 0) {
        $c->stash->{msg} = "Please wait for staff to verify your group and approve or decline your group request";
    }
    elsif ($result == -1) {
        $c->stash->{error_msg} = "Unable to complete auto verification. Please check that you have completed either of the steps below. If
        you are having trouble, please enter what you are trying to do in the freetext area below:";
        $c->detach ('verify');
    }

    $c->stash->{template} = 'group/action_done.tt';
}

sub invite :Chained('single_group') :PathPart('invite') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'group/invite.tt';
}

sub invite_submit :Chained('single_group') :PathPart('invite/submit') :Args(0) {
    my ($self, $c) = @_;

    my $account = $c->model("DB")->resultset("Account")->find ({ "accountname" => $c->request->params->{contact} });
    if (! $account || ! $account->contact) {
        $c->stash->{error_msg} = "This user does not exist or has no contact information defined.";
        $c->detach ('invite');
    } else {
        my $contact = $account->contact;
        my $group = $c->stash->{group};
        try {
            $group->invite_contact ($contact, $c->user->account->id);
        }
        catch (GMS::Exception $e) {
            $c->stash->{error_msg} = $e;
            $c->detach ('invite');
        }
    }
    $c->stash->{msg} = "Successfully invited the contact.<br/>";
    $c->stash->{template} = 'group/action_done.tt';
}

sub invite_accept :Chained('single_group') :PathPart('invite/accept') :Args(0) {
    my ($self, $c) = @_;

    my $group = $c->stash->{group};
    my $gc = $c->user->account->contact->group_contacts->find ({ 'group_id' => $group->id });
    $gc->accept_invitation();
    $c->stash->{msg} = "Successfully accepted the group invitation. Please wait for staff to accept this.<br/>";
    $c->stash->{template} = 'group/action_done.tt';
}

sub invite_decline :Chained('single_group') :PathPart('invite/decline') :Args(0) {
    my ($self, $c) = @_;

    my $group = $c->stash->{group};
    my $gc = $c->user->account->contact->group_contacts->find ({ 'group_id' => $group->id });
    $gc->decline_invitation ();
    $c->stash->{msg} = "Successfully declined the group invitation.<br/>";
    $c->stash->{template} = 'group/action_done.tt';
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

    if ($last_change->change_type eq 'request') {
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

        if ($address) {
            $c->stash->{has_address} = 'y';

            foreach (qw /address_one address_two city state code country phone phone2/) {
                $c->stash->{$_} = $address->$_;
            }
        } else {
            $c->stash->{has_address} = 'n';
        }
    }

    $c->stash->{template} = 'group/edit.tt';
}

=head2 do_edit

Processes the group edit form, and creates a GroupChange with the
change_type being 'request'

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

        $group->change ($c->user->account->id, 'request', { 'group_type' => $p->{group_type}, 'url' => $p->{url}, address => $address });
    }
    catch (GMS::Exception::InvalidAddress $e) {
        $c->stash->{errors} = [
            "If the group has its own address, then a valid address must be specified.",
            @{$e->message}
        ];
        %{$c->stash} = ( %{$c->stash}, %$p );
        $c->stash->{form_submitted} = 1;
        $c->detach('edit');
    }

    $c->stash->{msg} = "Successfully submitted the change request. Please wait for staff to approve the change.";
    $c->stash->{template} = 'group/action_done.tt';
}

=head2 edit_gc

Displays the form to edit Group Contact information.
GroupContacts can edit information for active and retired contacts.

=cut

sub edit_gc :Chained('single_group') :PathPart('edit_gc') :Args(0) {
    my ($self, $c) = @_;

    my $group = $c->stash->{group};
    my @group_contacts = $group->editable_group_contacts;

    $c->stash->{group_contacts} = \@group_contacts;

    $c->stash->{template} = 'group/edit_gc.tt';
}

=head2 do_edit_gc

Processes the Group Contact edit form and creates a
GroupContactChange with 'request' as the change type.

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

            if (!$primary) {
                $primary = -1;
            }

            $contact->change ($c->user->account->id, 'request', { 'status' => $status, 'primary' => $primary });
        } elsif ($action eq 'hold') {
            next;
        }
    }

    $c->stash->{msg} = "Successfully requested the GroupContactChanges.";
    $c->stash->{template} = 'group/action_done.tt';
}

=head2 take_over

Displays the form to take over channels for the group.

=cut

sub take_over :Chained('single_group') :PathPart('take_over') :Args(0) {
    my ($self, $c) = @_;

    my $group = $c->stash->{group};
    my @group_contacts = $group->group_contacts;
    my @channel_namespaces = $group->active_channel_namespaces;

    $c->stash->{group_contacts} = \@group_contacts;
    $c->stash->{channel_namespaces} = \@channel_namespaces;

    $c->stash->{template} = 'group/take_over.tt';
}

=head2 do_take_over

Processes the form to take over channels and transfers channel
ownership to the new founder.

=cut

sub do_take_over :Chained('single_group') :PathPart('take_over/submit') :Args(0) {
    my ($self, $c) = @_;

    my $p = $c->request->params;

    my $channel = $p->{channel};
    my $gc = $p->{group_contact};
    my $namespace = $p->{channel_namespace};
    my $group = $c->stash->{group};
    my $action = $p->{action};

    my $group_contact = $group->group_contacts->find({ contact_id => $gc });
    my $gc_name = $group_contact->contact->account->accountname;

    try {
        if ($action == 1) {
            $group->take_over ($c, $channel, $namespace, $gc_name);
        } elsif ($action == 2) {
            $group->drop ($c, $channel, $namespace);
        }
    }
    catch (RPC::Atheme::Error $e) {
        $c->stash->{error_msg} = $e->description;
        %{$c->stash} = ( %{$c->stash}, %$p );

        $c->detach ('take_over');
    }
    catch (GMS::Exception $e) {
        $c->stash->{error_msg} = $e;
        %{$c->stash} = ( %{$c->stash}, %$p );

        $c->detach ('take_over');
    }

    if ($action == 1) {
        $c->stash->{msg} = "Successfully transferred the channel to $gc_name.";
    } elsif ($action == 2) {
        $c->stash->{msg} = "Successfully dropped the channel.";
    }

    $c->stash->{template} = 'group/action_done.tt';
}

=head2 edit_channel_namespaces

Shows the group's current channel namespaces and allows the group contact to
request changes or request a new namespace.

=cut

sub edit_channel_namespaces :Chained('single_group') :PathPart('edit_channel_namespaces') :Args(0) {
    my ($self, $c) = @_;

    my $group = $c->stash->{group};
    my @channel_namespaces = $group->active_channel_namespaces;

    $c->stash->{channel_namespaces} = \@channel_namespaces;
    $c->stash->{template} = 'group/edit_channel_namespaces.tt';
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
            $namespace->change ($c->user->account, 'request', { 'status' => $status });
        }
    }

    if ($new_namespace) {
        if ( ( my $ns = $namespace_rs->find({ 'namespace' => $new_namespace }) ) ) {
            if ($ns->status ne 'deleted') {
                $c->stash->{error_msg} = "That namespace is already taken";
                $c->detach ('edit_channel_namespaces');
            } else {
                if ($ns->last_change->change_type eq 'request' && !$p->{'do_confirm'}) {
                    $c->stash->{error_msg} = "Another group has requested that namespace. Are you sure you want to create a conflicting request?";
                    $c->stash->{confirm} = 1;
                    $c->stash->{prev_namespace} = $new_namespace;
                    $c->detach ('edit_channel_namespaces');
                }

                $ns->change ($c->user->account, 'request', { 'status' => 'active', 'group_id' => $group->id });
            }
        } else {
            $group->add_to_channel_namespaces ({ 'group_id' => $group->id, 'account' => $c->user->account, 'namespace' => $new_namespace, 'status' => 'pending-staff' });
        }
    }

    $c->stash->{msg} = 'Namespace updates requested successfully,';
    $c->stash->{template} = 'group/action_done.tt';
}

=head2 new_form

Displays the form to register a new group.

=cut

sub new_form :Chained('base') :PathPart('new') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'group/new.tt';
}

=head2 do_new

Submit handler for the new group form.

Using the information submitted, creates a new Address if applicable, then a
Group, then adds the current user as the first group contact. Any channel and
cloak namespaces claimed are also added.

=cut

sub do_new :Chained('base') :PathPart('new/submit') :Args(0) {
    my ($self, $c) = @_;

    my $account = $c->user->account;

    my $p = $c->request->params;
    my @errors;

    my $group_rs = $c->model('DB::Group');
    my $namespace_rs = $c->model('DB::ChannelNamespace');

    my $group;

    if ($group_rs->find ({ group_name => $p->{group_name}, deleted => 0 })) {
        $c->stash->{error_msg} = "This group name is already taken.";
        %{$c->stash} = ( %{$c->stash}, %$p );
        $c->detach('new_form');
    }

    my @channels = split /, */, $p->{channel_namespace};

    foreach my $channel_ns ( @channels ) {
        if ( ( my $ns = $namespace_rs->find({ 'namespace' => $channel_ns }) ) ) {
            if ($ns->status ne 'deleted') {
                push @errors, "The namespace $channel_ns is already taken";
            } else {
                if ($ns->last_change->change_type eq 'request' && !$p->{'do_confirm'}) {
                    push @errors, "Another group has requested the $channel_ns namespace. Are you sure you want to create a conflicting request?";
                    $c->stash->{confirm} = 1;
                }
            }
        }
    }

    if (@errors) {
        $c->stash->{errors} = \@errors;
        %{$c->stash} = ( %{$c->stash}, %$p );
        $c->detach('new_form');
    }

    try {
        $c->model('DB')->schema->txn_do(sub {
            my $address;

            if ($p->{has_address} eq 'y')
            {
                $address = $c->model('DB::Address')->create({
                        address_one => $p->{address_one},
                        address_two => $p->{address_two},
                        city => $p->{city},
                        state => $p->{state},
                        code => $p->{postcode},
                        country => $p->{country},
                        phone => $p->{phone},
                        phone2 => $p->{phone2}
                    });
            }

            $group = $group_rs->create({
                    group_name => $p->{group_name},
                    group_type => $p->{group_type},
                    url => $p->{group_url},
                    address => $address,
                    account => $c->user->account,
                });

            foreach my $channel_ns ( @channels ) {
                if ( ( my $ns = $namespace_rs->find({ 'namespace' => $channel_ns }) ) ) {
                    $ns->change ($c->user->account, 'request', { 'status' => 'active', 'group_id' => $group->id });
                } else {
                    $group->add_to_channel_namespaces ({ 'group_id' => $group->id, 'account' => $c->user->account, 'namespace' => $channel_ns, 'status' => 'pending-staff' });
                }
            }

            $group->add_to_group_contacts({ contact_id => $account->contact->id, primary => 1, account => $account->id });

            $c->stash->{contact} = $account->contact;
            $c->stash->{group} = $group;

            $c->stash->{join_gab} = $p->{join_gab};
            $c->stash->{gab_email} = $p->{gab_email} || $account->contact->email;

            $c->stash->{email} = {
                to => $account->contact->email,
                bcc => $c->config->{email}->{admin_address},
                from => $c->config->{email}->{from_address},
                subject => "Group Registration for " . $group->group_name,
                template => 'new_group.tt',
            };

            #$c->forward($c->view('Email'));
            #if (scalar @{$c->error}) {
            #    my $message = $c->error->[0];
            #    $c->error(0);
            #    die GMS::Exception->new("Email sending failed. Please try again later.");
            #}

            $group->update;
        });
    }
    catch (GMS::Exception::InvalidGroup $e) {
        $c->stash->{errors} = $e->message;
        %{$c->stash} = ( %{$c->stash}, %$p );
        $c->detach('new_form');
    }
    catch (GMS::Exception::InvalidAddress $e) {
        $c->stash->{errors} = [
            "If the group has its own address, then a valid address must be specified.",
            @{$e->message}
        ];
        %{$c->stash} = ( %{$c->stash}, %$p );
        $c->detach('new_form');
    }
    catch (GMS::Exception $e) {
        $c->stash->{error_msg} = $e;
        %{$c->stash} = ( %{$c->stash}, %$p );
        $c->detach('new_form');
    }

    $c->stash->{template} = 'group/added.tt';
}

1;
