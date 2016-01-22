package GMS::Web::Controller::JSON::Staff;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use TryCatch;
use GMS::Exception;
use RPC::Atheme::Error;

=head1 NAME

GMS::Web::Controller::JSON::Staff - Controller for GMS::Web

=head1 DESCRIPTION

This controller contains handlers for the staff pages.

=head1 METHODS

=head2 base

Base method for all the handler chains. Verifies that the user has the 'staff'
role, and presents an error page if not.

=cut

sub base :Chained('/') :PathPart('json/staff') :CaptureArgs(0) {
    my ($self, $c) = @_;

    if (! $c->check_user_roles('staff') && ! $c->check_user_roles('admin') ) {
        $c->stash->{json_success} = 0;
        $c->stash->{json_error} = "You are not staff.";
        $c->response->status(403);
        $c->detach;
    }

    $c->stash->{json_staff} = 1;
}

=head2 search_group_name

Returns a list of groups matching a partial name.

=cut

sub search_group_name :Chained('base') :PathPart('search_group_name') :Args(0) {
    my ($self, $c) = @_;

    my $rs = $c->model('DB::Group');
    my $p = $c->request->params;

    my $name = $p->{name};
    return if !$name;

    my @results;
    my @matching = $rs->search(
        {
            'group_name' => {
                'ilike' => "$name%"
            }
        }
    );

    foreach my $group ( @matching ) {
        push @results, $group->group_name;
    }

    $c->stash->{json_groups} = \@results;
}

=head2 search_account_name

Returns a list of accounts matching a partial name.

=cut

sub search_account_name :Chained('base') :PathPart('search_account_name') :Args(0) {
    my ($self, $c) = @_;

    my $rs = $c->model('DB::Account');
    my $p = $c->request->params;

    my $name = $p->{name};
    return if !$name;

    my @results;
    my @matching = $rs->search(
        {
            'accountname' => {
                'ilike' => "$name%"
            }
        }
    );

    foreach my $account ( @matching ) {
        push @results, $account->accountname;
    }

    $c->stash->{json_accounts} = \@results;
}

=head2 search_full_name

Returns a list of contacts matching a partial fullname.

=cut

sub search_full_name :Chained('base') :PathPart('search_full_name') :Args(0) {
    my ($self, $c) = @_;

    my $rs = $c->model('DB::Contact');
    my $p = $c->request->params;

    my $name = $p->{name};
    return if !$name;

    my @results;
    my @matching = $rs->search(
        {
            'active_change.name' => {
                'ilike' => "$name%"
            }
        },
        {
            join => 'active_change'
        }
    );

    foreach my $contact ( @matching ) {
        push @results, $contact->name;
    }

    $c->stash->{json_names} = \@results;
}


=head2 search_ns_name

Returns a list of namespaces matching a partial name.

=cut

sub search_ns_name :Chained('base') :PathPart('search_ns_name') :Args(0) {
    my ($self, $c) = @_;

    my $channel_rs = $c->model('DB::ChannelNamespace');
    my $cloak_rs = $c->model('DB::CloakNamespace');

    my $p = $c->request->params;

    my $name = $p->{name};
    return if !$name;

    my @results;

    my @channels = $channel_rs->search(
        {
            'namespace' => {
                'ilike' => "$name%"
            }
        }
    );

    my @cloaks = $cloak_rs->search(
        {
            'namespace' => {
                'ilike' => "$name%"
            }
        }
    );

    foreach my $ns ( @channels, @cloaks ) {
        push @results, $ns->namespace;
    }

    @results = keys %{{ map { $_ => 1 } @results }};

    $c->stash->{json_namespaces} = \@results;
}

1;
