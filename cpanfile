
requires 'Catalyst::Runtime' => '5.80005';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Action::RenderView';
requires 'Catalyst::View::TT';
requires 'Catalyst::View::JSON';
requires 'Catalyst::View::Email::Template';
requires 'Catalyst::Model::DBIC::Schema';
requires 'parent';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats

requires 'MooseX::OneArgNew';
requires 'TryCatch';
requires 'RPC::XML';
requires 'DBIx::Class' => '0.08124';
requires 'DBIx::Class::DeploymentHandler';
requires 'DBIx::Class::Fixtures';
requires 'DBIx::Class::InflateColumn::Object::Enum';
requires 'DBIx::Class::InflateColumn::DateTime';
requires 'DBD::Pg';
requires 'String::Random';
requires 'Dir::Self';
requires 'Config::JFDI';
requires 'SQL::Translator' => '0.11002';
requires 'JSON::XS';

requires 'Net::DNS';
requires 'FCGI';
requires 'FCGI::ProcManager';
requires 'Daemon::Control';

requires 'Catalyst::Plugin::StackTrace';
requires 'LWP::Protocol::https';
requires 'Domain::PublicSuffix';
requires 'Text::Glob';


requires 'DBIx::Class::DeploymentHandler';
requires 'MooseX::AttributeShortcuts';

on 'test' => sub {

requires 'Test::WWW::Mechanize::Catalyst';
requires 'Test::MockModule';
requires 'Test::MockObject';
requires 'Test::Most';
requires 'Test::Pod';
requires 'Test::Pod::Coverage';
}


