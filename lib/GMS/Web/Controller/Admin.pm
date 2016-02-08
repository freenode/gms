package GMS::Web::Controller::Admin;

use strict;
use warnings;
use base qw (GMS::Web::TokenVerification);

use TryCatch;
use GMS::Exception;
use RPC::Atheme::Error;

=head1 NAME

GMS::Web::Controller::Admin - Controller for GMS::Web

=head1 DESCRIPTION

This is the root controller for administrative pages.

=head1 METHODS

=head2 base

Base method for all the handler chains. Verifies that the user has the neccessary
role, and presents an error page if not.

=cut

sub base :Chained('/') :PathPart('admin') :CaptureArgs(0) :Local :VerifyToken {
    my ($self, $c) = @_;

    if (! $c->check_any_user_role('admin', 'staff', 'approver')) {
        $c->detach('/forbidden');
    }

    if ($c->check_user_roles('admin')) {
        $c->stash->{admin} = 1;
    }

    if ($c->check_user_roles('approver')) {
        $c->stash->{approver} = 1;
    }
}

=head2 admin_only

Actions only allowed for the admin role.

=cut

sub admin_only :Chained('base') :PathPart('') :CaptureArgs(0) {
    my ($self, $c) = @_;

    if (! $c->check_user_roles('admin')) {
        $c->detach('/forbidden');
    }
}

=head2 approver_only

Actions only allowed for the approver role.

=cut

sub approver_only :Chained('base') :PathPart('') :CaptureArgs(0) {
    my ($self, $c) = @_;

    if (! $c->check_any_user_role('admin', 'approver')) {
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

1;
