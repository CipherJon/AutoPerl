#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 2;  # Update the number of planned tests to 2

my $config_file = 'config/app_config.yaml';
BEGIN { use_ok('AutomatedScriptingApp::Config') }

my $config = AutomatedScriptingApp::Config->new($config_file);
isa_ok($config, 'HASH', 'Config is a hash reference');