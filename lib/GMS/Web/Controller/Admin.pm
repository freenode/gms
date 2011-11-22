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

sub approve_gcc :Chained('base') :PathPart('approve_gcc') :Args(0) {
    my ($self, $c) = @_;

    my @to_approve = $c->model ("DB::GroupContactChange")->active_requests();
    
    $c->stash->{to_approve} = \@to_approve;
    $c->stash->{template} = 'admin/approve_gcc.tt';
}

sub do_approve_gcc :Chained('base') :PathPart('approve_gcc/submit') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my $change_rs = $c->model('DB::GroupContactChange');
    my $account = $c->user->account;

    my @approve_changes = split / /, $params->{approve_changes};
    try { 
        $c->model('DB')->schema->txn_do(sub {
            foreach my $change_id (@approve_changes) {
                my $change = $change_rs->find({ id => $change_id });
                my $action = $params->{"action_$change_id"};
                if ($action eq 'approve') {
                    $c->log->info("Approving GroupContactChange id $change_id" .
                        " by " . $c->user->username . "\n");
                    $change->group_contact->approve_change($change, $account);
                } elsif ($action eq 'reject') {
                    $c->log->info("Rejecting GroupContactChange id $change_id" .
                        " by " . $c->user->username . "\n");
                    $change->group_contact->reject_change ($change, $account);
                } elsif ($action eq 'hold') {
                    next;
                } else {
                    $c->log->error("Got unknown action $action for change id
                        $change_id in Admin::do_approve_gcc");
                }
            }
        });
        $c->response->redirect($c->uri_for('approve_gcc'));
    }
    catch (GMS::Exception $e) {
        $c->stash->{error_msg} = $e->message;
        $c->detach ("/admin/approve_gcc");
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
    }

    else {
        my $contact = $account->contact;
        my $group = $c->stash->{group};

        try {
            $group->add_contact ($contact, $c->user->account->contact->id, { 'freetext' => $p->{freetext} });
        }
        catch (GMS::Exception $e) {
            $c->stash->{error_msg} = $e;
            $c->detach ("add_gc");
        }
    }

    $c->stash->{msg} = "Successfully added the group contact.";
    $c->stash->{template} = 'staff/action_done.tt';
}

1;
