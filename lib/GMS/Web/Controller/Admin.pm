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
    my @to_verify  = $c->model('DB::Group')->search_submitted_groups->search({ verify_auto => 0 });

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

=head2 view

Displays information about a single group.

=cut

sub view :Chained('single_group') :PathPart('view') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'group/view.tt';
}

1;
