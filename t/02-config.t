use strict;
use warnings;
use Test::More tests => 3;
use AutomatedScriptingApp::Config;

my $config_file = 'config/app_config.yaml';
my $config = AutomatedScriptingApp::Config->new($config_file);

ok($config, 'Config object created');
ok($config->get('scripts_dir'), 'Config key "scripts_dir" exists');

throws_ok { $config->get('non_existent_key') } qr/Key 'non_existent_key' not found in config/, 'Non-existent key throws exception';
