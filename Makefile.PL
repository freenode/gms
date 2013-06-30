#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install;

name 'GMS-Web';
all_from 'lib/GMS/Web.pm';

requires 'Catalyst::Runtime' => '5.80005';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::View::TT';
requires 'Catalyst::View::Email::Template';
requires 'Catalyst::View::JSON';
requires 'Catalyst::Model::DBIC::Schema';
requires 'parent';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

requires 'MooseX::OneArgNew';
requires 'Test::MockModule';
requires 'TryCatch';
requires 'RPC::XML';
requires 'DBIx::Class' => '0.08124';
requires 'DBIx::Class::Fixtures';
requires 'DBIx::Class::InflateColumn::Object::Enum';
requires 'DBIx::Class::InflateColumn::DateTime';
requires 'DBIx::Class::InflateColumn::Boolean';
requires 'String::Random';
requires 'Dir::Self';
requires 'Config::JFDI';
requires 'SQL::Translator' => '0.11002';

test_requires 'Test::WWW::Mechanize::Catalyst';

# XXX: remove these dependencies eventually -- they're here for development/debugging
requires 'Catalyst::Plugin::StackTrace';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
