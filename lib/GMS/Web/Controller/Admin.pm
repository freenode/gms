package GMS::Web::Controller::Admin;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use TryCatch;
use GMS::Exception;

sub base :Chained('/') :PathPart('admin') :CaptureArgs(0) {
    my ($self, $c) = @_;

    if (! $c->check_user_roles('admin')) {
        $c->detach('/forbidden');
    }
}

sub index :Chained('base') :PathPart('') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'admin/index.tt';
}

sub single_group :Chained('base') :PathPart('') :CaptureArgs(1) {
    my ($self, $c, $group_id) = @_;

    my $group = $c->model('DB::Group')->find({ id => $group_id });

    if ($group) {
        $c->stash->{group} = $group;
    } else {
        $c->detach('/default');
    }
}

sub approve :Chained('base') :PathPart('approve') :Args(0) {
    my ($self, $c) = @_;

    my @to_approve = $c->model('DB::Group')->search({ status => 'verified' });
    my @to_verify  = $c->model('DB::Group')->search({ status => 'manual_pending' });

    $c->stash->{to_approve} = \@to_approve;
    $c->stash->{to_verify} = \@to_verify;
    $c->stash->{template} = 'admin/approve.tt';
}

sub do_approve :Chained('base') :PathPart('approve/submit') :Args(0) {
    my ($self, $c) = @_;

    my $params = $c->request->params;
    my $group_rs = $c->model('DB::Group');

    my @approve_groups = split / /, $params->{approve_groups};
    my @verify_groups  = split / /, $params->{verify_groups};

    foreach my $group_id (@approve_groups, @verify_groups) {
        my $group = $group_rs->find({ id => $group_id });
        my $action = $params->{"action_$group_id"};
        if ($action eq 'approve') {
            $c->log->info("Approving group id $group_id (" .
                $group->groupname . ") by " . $c->user->username . "\n");
            $group->approve;
        } elsif ($action eq 'reject') {
            $c->log->info("Rejecting group id $group_id (" .
                $group->groupname . ") by " . $c->user->username . "\n");
            $group->reject;
        } elsif ($action eq 'verify') {
            $c->log_info("Verifying group id $group_id (" .
                $group->groupname . ") by " . $c->user->username . "\n");
            $group->verify;
        } elsif ($action eq 'hold') {
            next;
        } else {
            $c->log->error("Got unknown action $action for group id
                $group_id in Admin::do_approve");
        }
    }

    $c->response->redirect($c->uri_for('approve'));
}

sub view :Chained('single_group') :PathPart('view') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'group/view.tt';
}

1;
