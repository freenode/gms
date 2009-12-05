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
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::View::TT';
requires 'Catalyst::View::Email::Template';
requires 'Catalyst::Model::DBIC::Schema';
requires 'parent';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

requires 'TryCatch';
requires 'RPC::XML';
requires 'DBIx::Class';
requires 'String::Random';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
