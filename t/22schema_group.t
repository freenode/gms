#!/usr/bin/perl

use strict;
use warnings;
use Test::Most;
use Test::MockModule;

use lib qw(t/lib);
use GMSTest::Common;
use GMSTest::Database;

my $schema = need_database 'three_groups';

# Let's not make the test get stuck if web verification does,
# we don't care about it right now.

my $mock_lwp = Test::MockModule->new('LWP::UserAgent');
$mock_lwp->mock('new', sub { my ($mock) = @_; return $mock; });
$mock_lwp->mock('request', sub { my ($mock) = @_; return $mock; });
$mock_lwp->mock('content', sub { return ''; });

my $mock_dns = Test::MockModule->new('Net::DNS::Resolver');
$mock_dns->mock('new', sub { my ($mock) = @_; return $mock; });
$mock_dns->mock('search', sub { return ''; });

#
# Test validation on construction
#

eval {
    $schema->resultset('Group')->create({ });
};
my $error = $@;
isa_ok $error, 'GMS::Exception::InvalidGroup';

is_deeply $error->message, [
    "Group type must be specified",
    "Group name must be provided",
    "Group URL must be provided",
], "Test group validation";

eval {
    $schema->resultset('Group')->create({
            group_type => 'informal',
            group_name => '~"#$ is not a valid group name',
            url => '~~ is not a valid group URL'
       });
};
$error = $@;
isa_ok $error, 'GMS::Exception::InvalidGroup';
is_deeply $error->message, [
    "Group name must contain only alphanumeric characters, space, underscores, hyphens and dots.",
    "Group URL contains invalid characters (valid characters are a-z, A-Z, 0-9, :_+-/)"
], "Test more group validation";

#
# Test change semantics
#

my $useraccount = $schema->resultset('Account')->search({accountname => 'test01'})->single;
ok $useraccount;
my $adminaccount = $schema->resultset('Account')->search({accountname => 'admin01'})->single;
ok $adminaccount;

$schema->resultset('Group')->reset();

is $schema->resultset('Group')->search_submitted_groups->count, 1;
is $schema->resultset('Group')->search_verified_groups->count, 1;
is $schema->resultset('Group')->search_active_groups->count, 0;
is $schema->resultset('GroupChange')->active_requests->count, 0;

my $group = $schema->resultset('Group')->create({
        account => $useraccount,
        group_type => 'informal',
        group_name => 'test',
        url => 'http://example.com'
    });
is $group->url, 'http://example.com';
is $group->group_type, 'informal';

my $change = $group->change($useraccount, 'request', { url => 'http://example.org' });

is $schema->resultset('GroupChange')->active_requests->count, 1, 'Requesting a change increases active_requests';

is $group->url, 'http://example.com', "Requested change doesn't update active state";
is $group->group_type, 'informal', "Requested change doesn't update active state";

my $approval = $change->approve($adminaccount);
isa_ok $approval, 'GMS::Schema::Result::GroupChange';

is $schema->resultset('GroupChange')->active_requests->count, 0, 'Approving a change decreases active_requests';

throws_ok { $group->approve } qr/Can't approve a group that isn't verified or pending verification/,
                                "Can't approve a group that isn't verified or pending verification";

throws_ok { $group->reject } qr/Can't reject a group not pending approval/,
                               "Can't reject a group not pending approval";
$group->discard_changes;

is $group->active_change->id, $approval->id, "Approval updates active_change";
is $group->active_change->url, 'http://example.org', "Approving a change updates group state";
is $group->url, 'http://example.org', "Approving a change updates group state";

like $group->verify_url, qr/example\.org/, 'changing the url changes verify url';
like $group->verify_dns, qr/example\.org$/, 'changing the url changes verify dns';

$group->auto_verify ($useraccount->id, { freetext => 'text here' });


is $schema->resultset('Group')->search_submitted_groups->count, 2, 'Submitted groups increment on submitting a new group';
is $schema->resultset('Group')->search_verified_groups->count, 1;
is $schema->resultset('Group')->search_active_groups->count, 0;

#
# Test that new groups can take over names of deleted ones
#

throws_ok {
    $schema->resultset('Group')->create({
            account => $useraccount,
            group_type => 'informal',
            group_name => 'test',
            url => 'http://example.com'
        });
} qr//; # XXX: Should check the type of exception here, but with_deferred_fk_checks eats it

is $group->deleted, 0;

$group->reject($adminaccount);
isnt $group->deleted, 0;

is $schema->resultset('Group')->search_submitted_groups->count, 1, 'Submitted groups decrease on rejecting a group';
is $schema->resultset('Group')->search_verified_groups->count, 1;
is $schema->resultset('Group')->search_active_groups->count, 0;

my $new_group = $schema->resultset('Group')->create({
          account => $useraccount,
          group_type => 'informal',
          group_name => 'test',
          url => 'http://example.com'
       });

isa_ok $new_group, 'GMS::Schema::Result::Group';

# Can't reactivate a group now that something else has taken its name.
throws_ok {
   $group->change($adminaccount, 'admin', { status => 'active' });
} qr/unique_group_name/;

my $address = $schema->resultset('Address')->create({
    address_one => 'Test address',
    city => 'Test city',
    state => 'Test state',
    code => 'Test001',
    country => 'Test country',
    phone => '0123456789'
});
isa_ok $address, 'GMS::Schema::Result::Address';

$group = $schema->resultset('Group')->create({
    account => $useraccount,
    group_name => 'new_name',
    group_type => 'informal',
    url => 'http://localhost/',
    address => $address->id
});
isa_ok $group, 'GMS::Schema::Result::Group';

is $group->address->id, $address->id, 'Address is correct';


$address = $schema->resultset('Address')->create({
    address_one => 'Another Test address',
    city => 'Test city 2',
    state => 'Test state 2',
    code => 'Test002',
    country => 'Test country2',
    phone => '0123456789'
});
isa_ok $address, 'GMS::Schema::Result::Address';

ok $group->change ( $useraccount, 'request', { 'address' => $address } );
$change = $group->change ( $adminaccount, 'admin', { } );

is $group->address->id, $address->id, 'Change inherits previous change; changing address works.';

$group->change ( $adminaccount, 'admin', { 'address' => -1 } );

is $group->address, undef, 'Removing address works';

ok $group->add_to_channel_namespaces ({
        'group_id' => $group->id,
        'account' => $useraccount,
        'namespace' => 'test_namespace',
        'status' => 'pending_staff'
    });

my $namespace = ($group->channel_namespaces)[0];
is $namespace->namespace, 'test_namespace', 'Adding and accessing channel namespaces works';
is $group->channel_namespaces->count, 1, 'Adding and accessing channel namespaces works';

is $namespace->status, 'pending_staff', 'Namespace is not active';
is $group->active_channel_namespaces->count, 0, 'Namespace is not active';

ok $group->add_to_cloak_namespaces ({
        'group_id' => $group->id,
        'account' => $useraccount,
        'namespace' => 'testnamespace',
        'status' => 'pending_staff'
    });

$namespace = ($group->cloak_namespaces)[0];
is $namespace->namespace, 'testnamespace', 'Adding and accessing cloak namespaces works';
is $group->cloak_namespaces->count, 1, 'Adding and accessing cloak namespaces works';

is $namespace->status, 'pending_staff', 'Namespace is not active';
is $group->active_cloak_namespaces->count, 0, 'Namespace is not active';

$group->auto_verify ($useraccount->id, { freetext => 'text here' });
isnt $group->status->is_verified, 1, 'Just entering free text will not verify the group';

is $group->verify_freetext, 'text here', 'Retrieving free text works.';

is $schema->resultset('Group')->search_submitted_groups->count, 2, 'Submitted groups increase when a group becomes pending-staff';

ok $group->verify ($adminaccount);

is $group->status->is_verified, 1, 'Manually Verifying a group works.';
isnt $group->status->is_active, 1, 'Verify does not approve';

is $schema->resultset('Group')->search_submitted_groups->count, 1, 'Submitted groups decrease on verifying a group';
is $schema->resultset('Group')->search_verified_groups->count, 2, 'Verified groups increase on verifying a group';
is $schema->resultset('Group')->search_active_groups->count, 0;

throws_ok { $group->verify ( $adminaccount ) } qr/Can't verify a group that isn't pending verification/, "Can't verify a group that isn't pending verification";

$group->approve ($adminaccount);
is $group->status->is_active, 1, 'Approving group works';

is $schema->resultset('Group')->search_submitted_groups->count, 1;
is $schema->resultset('Group')->search_verified_groups->count, 1, 'Verified groups decrease on approving a group';
is $schema->resultset('Group')->search_active_groups->count, 1, 'Active groups increase on approving a group';

ok $group->change ($adminaccount, 'admin', { 'status' => 'pending_auto' });
$group->approve ($adminaccount);
is $group->status->is_active, 1, 'We can approve pending_auto groups';

ok $group->change ($adminaccount, 'admin', { 'status' => 'pending_auto' });
$group->reject ($adminaccount);
is $group->status->is_deleted, 1, 'We can reject pending_auto groups';

ok $group->change ($adminaccount, 'admin', { 'status' => 'pending_staff' });
$group->approve ($adminaccount);
is $group->status->is_active, 1, 'We can approve pending_staff groups';

ok $group->change ($adminaccount, 'admin', { 'status' => 'verified' });
$group->reject ($adminaccount);
is $group->status->is_deleted, 1, 'We can reject verified groups';

my $account = $schema->resultset('Account')->search({ accountname => 'test02' })->single;
isa_ok $account, 'GMS::Schema::Result::Account';

ok $group->invite_contact($account->contact, $useraccount);

$group->discard_changes;

is $group->group_contacts->count, 1, 'Group has 1 contacts';
is $group->active_group_contacts->count, 0, 'Invited contact is not active';

$account = $schema->resultset('Account')->search({ accountname => 'test03' })->single;
isa_ok $account, 'GMS::Schema::Result::Account';

ok $group->add_contact($account->contact, $adminaccount);
is $group->group_contacts->count, 2, 'Group has 2 contacts';
is $group->active_group_contacts->count, 1, 'Added contact is active';

$group = $schema->resultset('Group')->create({
    account => $useraccount,
    group_name => 'new_name_2',
    group_type => 'informal',
    url => 'https://example.com/',
    address => $address->id
});
isa_ok $group, 'GMS::Schema::Result::Group';

is $group->url, 'https://example.com/', 'We can also give https urls';

$group = $schema->resultset('Group')->create({
    account => $useraccount,
    group_name => 'new_name_3',
    group_type => 'informal',
    url => 'example.com/',
    address => $address->id
});
isa_ok $group, 'GMS::Schema::Result::Group';

is $group->url, 'http://example.com/', 'No http or https means http:// is added automatically';

# We need to test what happens if $parts[-1] && $parts[-2]
# in GMS::Schema::Result::Group is empty. Because we can't
# provide an empty URL, we'll have to mock the URI module.

my $mock = new Test::MockModule("URI::http");
$mock->mock ('host' => sub {
        undef;
    });

$group = $schema->resultset('Group')->create({
    account => $useraccount,
    group_name => 'some_other_test',
    group_type => 'informal',
    url => 'http://example.com/',
    address => $address->id
});
isa_ok $group, 'GMS::Schema::Result::Group';

is $group->verify_dns, undef, 'No verify DNS if host will be empty';

$mock->unmock_all;

eval {
    $schema->resultset('Group')->create({
        account => $useraccount,
        group_name => 'LoremipsumdolorsitametconsecteturadipiscingelitVivamusutfelisipsumPellentesquealiquamdictumpretiumClassaptenttacitisociosquadlitoratorquentperconubianostraperinceptoshimenaeosAliquamorcifelishendreritetorcialiquam',
        group_type => 'informal',
        url => 'LoremipsumdolorsitametconsecteturadipiscingelitVivamusutfelisipsumPellentesquealiquamdictumpretiumClassaptenttacitisociosquadlitoratorquentperconubianostraperinceptoshimenaeosAliquamorcifelishendreritetorcialiquam',
        address => $address->id
    });
};

$error = $@;
ok $error;

is_deeply $error->message, [
    "Group name must be up to 32 characters.",
    "Group URL must be up to 64 characters."
];

ok $group->change ( $adminaccount, 'admin', { 'status' => 'deleted' });
my $time = $group->deleted;

ok $time;

$change = $group->change ( $adminaccount, 'admin', { 'status' => 'deleted' });
ok $change;

my $time2 = $group->deleted;

is $time, $time2, 'Changing status to "deleted" twice in a row will not update the deleted timestamp.';

throws_ok { $change->approve ( $adminaccount ); } qr/Can't approve a change that isn't a request/, "Can't approve a change that isn't a request";
throws_ok { $change->reject ( $adminaccount ); } qr/Can't reject a change that isn't a request/, "Can't reject a change that isn't a request";

$change = $group->change ( $useraccount, 'request', { 'status' => 'active' });
ok $change;

is $schema->resultset('GroupChange')->active_requests->count, 1, 'Requesting a change increases active_requests';

throws_ok { $change->approve; } qr/Need an account to approve a change/, "Need an account to approve a change";
throws_ok { $change->reject; } qr/Need an account to reject a change/, "Need an account to reject a change";

ok $change->reject ($adminaccount);

is $schema->resultset('GroupChange')->active_requests->count, 0, 'Rejecting a change decreases active_requests';

isnt $group->status->is_active, 1, 'Rejected change does not take effect';

eval {
    $group->change ( $adminaccount, 'admin', {
            url => '~! is not a valid URL'
        });
};

$error = $@;
ok $error;

is_deeply $error->message, [
    "Group URL contains invalid characters (valid characters are a-z, A-Z, 0-9, :_+-/)"
];

eval {
    $group->change ( $adminaccount, 'admin', {
            url => 'LoremipsumdolorsitametconsecteturadipiscingelitVivamusutfelisipsumPellentesquealiquamdictumpretiumClassaptenttacitisociosquadlitoratorquentperconubianostraperinceptoshimenaeosAliquamorcifelishendreritetorcialiquam'
        });
};

$error = $@;
ok $error;

is_deeply $error->message, [
    "Group URL must be up to 64 characters."
];

eval {
    GMS::Schema::Result::GroupChange->new({ });
};

$error = $@;
ok $error;

is_deeply $error->message, [
    "Group type cannot be empty",
    "Group status cannot be empty",
    "URL cannot be empty"
], "We can't create a GroupChange without the necessary arguments";

$mock = new Test::MockModule("DBIx::Class::ResultSet");
$mock->mock ('find', sub {
        undef;
    });

is $group->verify_url, undef, "Returning empty url works";
is $group->verify_token, undef, "Returning empty token works";
is $group->verify_dns, undef, "Returning empty dns works";
is $group->verify_freetext, undef, "Returning empty freetext works";

$mock->unmock_all;

throws_ok {
    $schema->resultset('Group')->create({
        account => $useraccount,
        group_name => 'no_address',
        group_type => 'corporation',
        url => 'http://localhost/',
    });
} qr/Corporation, education, NFP and government groups must have an address/, "This type of group requires an address";

throws_ok {
    $schema->resultset('Group')->create({
        account => $useraccount,
        group_name => 'no_address',
        group_type => 'education',
        url => 'http://localhost/',
    });
} qr/Corporation, education, NFP and government groups must have an address/, "This type of group requires an address";

throws_ok {
    $schema->resultset('Group')->create({
        account => $useraccount,
        group_name => 'no_address',
        group_type => 'nfp',
        url => 'http://localhost/',
    });
} qr/Corporation, education, NFP and government groups must have an address/, "This type of group requires an address";

throws_ok {
    $schema->resultset('Group')->create({
        account => $useraccount,
        group_name => 'no_address',
        group_type => 'government',
        url => 'http://localhost/',
    });
} qr/Corporation, education, NFP and government groups must have an address/, "This type of group requires an address";

$address = $schema->resultset('Address')->create({
    address_one => 'Test address',
    city => 'Test city',
    state => 'Test state',
    code => 'Test001',
    country => 'Test country',
    phone => '0123456789'
});
isa_ok $address, 'GMS::Schema::Result::Address';

$group = $schema->resultset('Group')->create({
    account => $useraccount,
    group_name => 'addr_group',
    group_type => 'corporation',
    url => 'http://localhost/',
    address => $address->id
});
ok $group, "group creation works if we give an address";

$group = $schema->resultset('Group')->create({
    account => $useraccount,
    group_name => 'addr_group_2',
    group_type => 'education',
    url => 'http://localhost/',
    address => $address->id
});
ok $group, "group creation works if we give an address";

$group = $schema->resultset('Group')->create({
    account => $useraccount,
    group_name => 'addr_group_3',
    group_type => 'nfp',
    url => 'http://localhost/',
    address => $address->id
});
ok $group, "group creation works if we give an address";

$group = $schema->resultset('Group')->create({
    account => $useraccount,
    group_name => 'addr_group_4',
    group_type => 'government',
    url => 'http://localhost/',
    address => $address->id
});
ok $group, "group creation works if we give an address";

$namespace = $group->add_to_channel_namespaces ({
        'group_id' => $group->id,
        'account' => $adminaccount,
        'namespace' => 'test',
        'status' => 'active'
    });
my $cloak_namespace = $group->add_to_cloak_namespaces ({
        'group_id' => $group->id,
        'account' => $adminaccount,
        'namespace' => 'test',
        'status' => 'active'
    });

ok $namespace;
ok $namespace->status eq 'active';

ok $cloak_namespace;
ok $cloak_namespace->status eq 'active';

ok $group->change ( $adminaccount, 'admin', { 'status' => 'deleted' });
$namespace->discard_changes;
$cloak_namespace->discard_changes;

ok $namespace->status eq 'deleted', 'namespaces are deleted when deleting a group';
ok $cloak_namespace->status eq 'deleted', 'namespaces are deleted when deleting a group';

done_testing;
