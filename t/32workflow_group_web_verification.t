#!/usr/bin/perl
use strict;
use warnings;
use Test::Most;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

use HTTP::Server::Simple::CGI;
use base qw(HTTP::Server::Simple::CGI);

our ($file, $content);

my $schema = need_database 'basic_db';
my $user = $schema->resultset('Account')->search({ accountname => 'test01' })->single;

my $group = $schema->resultset('Group')->create({
        account => $user,
        group_type => 'informal',
        group_name => 'Test Group',
        url => 'http://localhost:51000',
        address => undef,
    });

isa_ok $group, "GMS::Schema::Result::Group";

$file = $group->verify_url;
$content = $group->verify_token;

{ # for the tiny httpd started to test web verification

    sub handle_request {
        my ($self, $cgi) = @_;

        my $path = $cgi->path_info;
        
        if ($file =~ /$path/) {
            print $content . "\n";
        }

        exit;
    }
}

# Start an HTTPD in a high port and test web verification.
__PACKAGE__->new(51000)->background;
is $group->auto_verify ($user), 1, 'Web verification works';

ok $group->status->is_pending_auto, 'Group status is now pending-auto after passing automatic verification';

done_testing;
