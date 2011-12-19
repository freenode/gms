package GMS::Web::Controller::Admin;

use strict;
use warnings;
use parent 'Catalyst::Controller';

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

sub base :Chained('/') :PathPart('admin') :CaptureArgs(0) {
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
                if ($action eq 'approve') {
                    $c->log->info("Approving group id $group_id (" .
                        $group->group_name . ") by " . $c->user->username . "\n");
                    $group->approve($account);
                } elsif ($action eq 'reject') {
                    $c->log->info("Rejecting group id $group_id (" .
                        $group->group_name . ") by " . $c->user->username . "\n");
                    $group->reject($account);
                } elsif ($action eq 'verify') {
                    $c->log->info("Verifying group id $group_id (" .
                        $group->group_name . ") by " . $c->user->username . "\n");
                    $group->verify($account);
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

sub approve_change :Chained('base') :PathPart('approve_change') :Args(0) {
    my ($self, $c) = @_;

    my $change_item = $c->request->params->{change_item};
    my @to_approve;
    $c->stash->{change_item} = $change_item;

    if ($change_item == 1) { #group contact change
        @to_approve = $c->model ("DB::GroupContactChange")->active_requests();
    } elsif ($change_item == 2) { #group change
        @to_approve = $c->model ("DB::GroupChange")->active_requests();
    } elsif ($change_item == 3) { #contact change
        @to_approve = $c->model ("DB::ContactChange")->active_requests();
    }

    $c->stash->{to_approve} = \@to_approve;

    if ($change_item == 1) {
        $c->stash->{template} = 'admin/approve_gcc.tt';
    } elsif ($change_item == 2) {
        $c->stash->{template} = 'admin/approve_gc.tt';
    } elsif ($change_item == 3) {
        $c->stash->{template} = 'admin/approve_cc.tt';
    } elsif (! $change_item) {
        $c->stash->{template} = 'admin/approve_change.tt';
    }
}

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
    }

    my $account = $c->user->account;

    my @approve_changes = split / /, $params->{approve_changes};
    try {
        $c->model('DB')->schema->txn_do(sub {
            foreach my $change_id (@approve_changes) {
                my $change = $change_rs->find({ id => $change_id });
                my $action = $params->{"action_$change_id"};
                if ($action eq 'approve') {
                    $c->log->info("Approving $type id $change_id" .
                        " by " . $c->user->username . "\n");
                    $change->approve ($account);
                } elsif ($action eq 'reject') {
                    $c->log->info("Rejecting $type id $change_id" .
                        " by " . $c->user->username . "\n");
                    $change->reject ($account);
                } elsif ($action eq 'hold') {
                    next;
                } else {
                    $c->log->error("Got unknown action $action for $type id
                        $change_id in Admin::do_approve_change");
                }
            }
        });
        $c->response->redirect($c->uri_for('approve_change', undef, { 'change_item' => $change_item }));
    }
    catch (GMS::Exception $e) {
        $c->stash->{error_msg} = $e->message;
        $c->detach ("/admin/approve_change");
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
    my $address = $group->address;

    if (!$c->stash->{form_submitted}) {
        $c->stash->{group_type} = $group->group_type;
        $c->stash->{url} = $group->url;

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

        $group->change ($c->user->account->id, 'admin', { 'group_type' => $p->{group_type}, 'url' => $p->{url}, address => $address });
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

    $c->stash->{msg} = "Successfully edited the group's information.";
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
    my $address = $contact->address;

    if (!$c->stash->{form_submitted}) {
        $c->stash->{user_name} = $contact->name;
        $c->stash->{user_email} = $contact->email;

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
        
        $contact->change ($c->user->account->id, 'admin', { 'name' => $params->{user_name}, 'email' => $params->{user_email}, address => $address });
    }
    catch (GMS::Exception::InvalidAddress $e) {
        $c->stash->{errors} = $e->message;
        %{$c->stash} = ( %{$c->stash}, %$params );
        $c->stash->{form_submitted} = 1;
        $c->detach('edit_account');
    }

    $c->stash->{msg} = "Successfully edited the user's contact information.";
    $c->stash->{template} = 'staff/action_done.tt';
}

1;
