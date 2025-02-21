use strict;
use warnings;
use Test::More tests => 2;
use AutomatedScriptingApp::ScriptRunner;
use AutomatedScriptingApp::Config;

my $config = AutomatedScriptingApp::Config->new('config/app_config.yaml');
my $script_runner = AutomatedScriptingApp::ScriptRunner->new($config);

ok($script_runner, 'ScriptRunner object created');
can_ok($script_runner, 'run_scripts');
