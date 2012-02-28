package GMS::Web::Controller::Staff;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use TryCatch;
use GMS::Exception;

=head1 NAME

GMS::Web::Controller::Staff - Controller for GMS::Web

=head1 DESCRIPTION

This controller contains handlers for the staff pages.

=head1 METHODS

=head2 base

Verifies the user has the 'staff' role and presents an
error page if not.

=cut

sub base :Chained('/') :PathPart('staff') :CaptureArgs(0) {
    my ($self, $c) = @_;

    if (! $c->check_user_roles('staff') && ! $c->check_user_roles('admin')) {
        $c->detach ('/forbidden');
    }

    $c->stash->{staff} = 1;

    if ($c->check_user_roles('admin')) {
        $c->stash->{admin} = 1;
    }
}

=head2 index

Staff index page

=cut

sub index :Chained('base') :PathPart('') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'staff/index.tt';
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

=head2 account

Chained method to select an account.

=cut

sub account :Chained('base') :PathPart('account') :CaptureArgs(1) {
    my ($self, $c, $account_id) = @_;

    my $account = $c->model('DB::Account')->find({ id => $account_id });

    if ($account) {
        $c->stash->{account} = $account;
    } else {
        $c->detach('/default');
    }
}

=head2 search_groups

Presents the form to search groups.

=cut

sub search_groups :Chained('base') :PathPart('search_groups') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = "staff/search_groups.tt";
}

=head2 do_search_groups

Performs a search with the criteria provided and displays the groups found.

=cut

sub do_search_groups :Chained('base') :PathPart('search_groups/submit') :Args(0) {
    my ($self, $c) = @_;

    my $p = $c->request->params;
    my $group_rs = $c->model("DB::Group");
    my $mode = $p->{mode}; #1 - At least 1 criterion must be satisfied (OR)
                           #2 - All criteria must be satisfied (AND)
    my (@search, @join, $page);

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

    if ($p->{group_name}) {
        my $group_name = $p->{group_name};
        $group_name =~ s#_#\\_#g; #escape _ so it's not used as a wildcard.

        push @search, 'group_name' => { 'ilike', $group_name };
    }

    if ($p->{gc_accname}) {
        my $accname = $p->{gc_accname};
        $accname =~ s#_#\\_#g;

        push @search, 'account.accountname' => { 'ilike', $accname };
        push @join, { 'group_contacts' => [ { 'contact' => 'account' } ] };
    }

    if ($p->{group_type}) {
        push @search, 'active_change.group_type' => $p->{group_type};
        push @join, 'active_change';
    }

    if ($p->{group_status}) {
        push @search, 'active_change.status' => $p->{group_status};
        push @join, 'active_change';
    }

    my $m = ($mode == 1?"-or":"-and");

    my $rs = $group_rs->search (
        { $m => \@search },
        {
            join => \@join,
            distinct => 1,
            page => $page,
            rows => 15
        }
    );

    my $pager = $rs->pager;
    my @results = $rs->all;

    %{$c->stash} = ( %{$c->stash}, %$p );
    $c->stash->{current_page} = $page;
    $c->stash->{last_page} = $pager->last_page;

    if (scalar (@results) == 0) {
        $c->stash->{error_msg} = "Unable to find any groups that match your search criteria. Please try again.";
        $c->detach ('search_groups');
    }

    $c->stash->{results} = \@results;
    $c->stash->{template} = 'staff/search_groups_results.tt';
}

=head2 search_users

Presents the form to search users.

=cut

sub search_users :Chained('base') :PathPart('search_users') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'staff/search_users.tt';
}

=head2 do_search_users

Performs a search with the criteria provided and displays the users found.

=cut

sub do_search_users :Chained('base') :PathPart('search_users/submit') :Args(0) {
    my ($self, $c) = @_;

    my $p = $c->request->params;
    my $account_rs = $c->model("DB::Account");
    my (@search, @join, $page);

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

    if ($p->{accountname}) {
        my $accountname = $p->{accountname};
        $accountname =~ s#_#\\_#g;

        push @search, { accountname => { ilike => $accountname } };
    }

    if ($p->{fullname}) {
        my $name = $p->{fullname};
        $name =~ s#_#\\_#g;

        push @search, { 'active_change.name' => { ilike => $name } };
        push @join, { 'contact' => 'active_change' };
    }

    my $rs = $account_rs -> search(
        { -or => \@search },
        {
            join => \@join,
            page => $page,
            rows => 15
        }
    );

    my $pager = $rs->pager;
    my @results = $rs->all;

    %{$c->stash} = ( %{$c->stash}, %$p );
    $c->stash->{current_page} = $page;
    $c->stash->{last_page} = $pager->last_page;

    if ( scalar (@results) == 0 ) {
        $c->stash->{error_msg} = "Unable to find any users that match your search criteria. Please try again.";
        $c->detach ('search_users');
    }

    $c->stash->{results} = \@results;
    $c->stash->{template} = "staff/search_users_results.tt";

}

=head2 search_namespaces

Presents the form to search namespaces.

=cut

sub search_namespaces :Chained('base') :PathPart('search_namespaces') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'staff/search_namespaces.tt';
}

=head2 do_search_namespaces

Performs a search with the criteria provided and displays the namespaces found.

=cut

sub do_search_namespaces :Chained('base') :PathPart('search_namespaces/submit') :Args(0) {
    my ($self, $c) = @_;

    my $p = $c->request->params;

    my (@search, @join, $page);
    my $search_item = $p->{search_item};

    my $namespace_rs;

    if ($search_item == 1) {
        $namespace_rs = $c->model("DB::ChannelNamespace");
    } elsif ($search_item == 2) {
        $namespace_rs = $c->model("DB::CloakNamespace");
    }

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

    my $namespace = $p->{namespace};
    $namespace =~ s#_#\\_#g; #escape _ so it's not used as a wildcard.

    my $rs = $namespace_rs -> search(
        { 'namespace' => { 'ilike' => $namespace } },
        {
            page => $page,
            rows => 15
        }
    );

    my $pager = $rs->pager;
    my @results = $rs->all;

    %{$c->stash} = ( %{$c->stash}, %$p );
    $c->stash->{current_page} = $page;
    $c->stash->{last_page} = $pager->last_page;

    if ( scalar (@results) == 0 ) {
        $c->stash->{error_msg} = "Unable to find any namespaces that match your search criteria. Please try again.";
        $c->detach ('search_namespaces');
    }

    $c->stash->{results} = \@results;
    $c->stash->{template} = "staff/search_namespaces_results.tt";

}

=head2 view

Displays information about a single group.

=cut

sub view :Chained('single_group') :PathPart('view') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'staff/view_group.tt';
}

=head2 view_account

Displays account & contact information about a user,
admins can view more information than staff.

=cut

sub view_account :Chained('account'):PathPart('view') :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{template} = 'staff/view_account.tt';
}

1;
