#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";       # Add the lib directory to @INC
use lib "$FindBin::Bin/../local/lib/perl5";  # Add the local lib directory to @INC
use AutomatedScriptingApp::ScriptRunner;
use AutomatedScriptingApp::Config;
use Data::Dumper;

# Load configuration
my $config_file = "$FindBin::Bin/../config/app_config.yaml";
my $config = AutomatedScriptingApp::Config->new($config_file);

# Initialize the script runner
my $script_runner = AutomatedScriptingApp::ScriptRunner->new($config);

# Run the scripts
$script_runner->run_scripts();

print Dumper($config);