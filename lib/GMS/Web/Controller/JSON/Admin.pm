package GMS::Web::Controller::JSON::Admin;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use TryCatch;
use GMS::Exception;
use RPC::Atheme::Error;

=head1 NAME

GMS::Web::Controller::JSON::Admin - Controller for GMS::Web

=head1 DESCRIPTION

This controller contains handlers for the administrative pages.

=head1 METHODS

=head2 base

Base method for all the handler chains. Verifies that the user has an appropriate
role, and presents an error page if not.

=cut

sub base :Chained('/') :PathPart('json/admin') :CaptureArgs(0) {
    my ($self, $c) = @_;

    if (! $c->check_any_user_role('admin', 'staff', 'approver')) {
        $c->stash->{json_success} = 0;
        $c->stash->{json_error} = "You do not have permission to access the requested page.";
        $c->response->status(403);
        $c->detach;
    }

    if ($c->check_user_roles('admin')) {
        $c->stash->{json_admin} = 1;
    }

    if ($c->check_user_roles('approver')) {
        $c->stash->{json_approver} = 1;
    }
}

=head2 admin_only

Actions only allowed for the admin role.

=cut

sub admin_only :Chained('base') :PathPart('') :CaptureArgs(0) {
    my ($self, $c) = @_;

    if (! $c->check_user_roles('admin')) {
        $c->stash->{json_success} = 0;
        $c->stash->{json_error} = "You do not have permission to access the requested page.";
        $c->response->status(403);
        $c->detach;
    }
}

=head2 approver_only

Actions only allowed for the approver role.

=cut

sub approver_only :Chained('base') :PathPart('') :CaptureArgs(0) {
    my ($self, $c) = @_;

    if (! $c->check_any_user_role('admin', 'approver')) {
        $c->stash->{json_success} = 0;
        $c->stash->{json_error} = "You do not have permission to access the requested page.";
        $c->response->status(403);
        $c->detach;
    }
}

1;
