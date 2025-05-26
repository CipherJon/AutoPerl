#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 11;
use AutomatedScriptingApp::ScriptRunner;
use Test::Exception;

BEGIN { use_ok('AutomatedScriptingApp::ScriptRunner') }

# Module Initialization
{
    my $runner = AutomatedScriptingApp::ScriptRunner->new();
    isa_ok($runner, 'AutomatedScriptingApp::ScriptRunner',
        "ScriptRunner object created successfully");
}

# Basic Script Execution
{
    my $script = "print 'Hello, Test!\\n';";
    my $result = AutomatedScriptingApp::ScriptRunner->run($script);
    like($result, qr/Hello, Test!/,
        "Script execution produces expected output");
}

# Error Handling
{
    my $invalid_script = "invalid_perl_code";
    throws_ok {
        AutomatedScriptingApp::ScriptRunner->run($invalid_script)
    } qr/syntax error/,
      "Invalid script throws syntax error";

    my $script = "print 1/0;";
    throws_ok {
        AutomatedScriptingApp::ScriptRunner->run($script)
    } qr/division by zero/,
      "Division by zero error is caught";

    throws_ok {
        AutomatedScriptingApp::ScriptRunner->new(some_invalid_param => 1)
    } qr/Usage/,
      "Invalid parameters throw error";
}

# Advanced Script Execution
{
    my $script = <<'SCRIPT';
        print 'First line\n';
        print 'Second line\n';
        print 'Third line\n';
    SCRIPT
    my $result = AutomatedScriptingApp::ScriptRunner->run($script);
    like($result, qr/First line\nSecond line\nThird line/,
        "Multiple statements in script execute correctly");
}

{
    my $script = <<'SCRIPT';
        use strict;
        use warnings;
        print 'Hello from strict and warnings!\n';
    SCRIPT
    my $result = AutomatedScriptingApp::ScriptRunner->run($script);
    like($result, qr/Hello from strict and warnings!/,
        "Script with pragmas executes successfully");
}

{
    my $script = <<'SCRIPT';
        use Data::Dumper;
        print Dumper({ key => 'value' });
    SCRIPT
    my $result = AutomatedScriptingApp::ScriptRunner->run($script);
    like($result, qr/\$VAR1 = {.*key.*=>.*'value'/s,
        "Script using external modules executes correctly");
}

# Consecutive Execution
{
    my $runner = AutomatedScriptingApp::ScriptRunner->new();
    
    # First run
    my $result1 = $runner->run("print 'First run\n';");
    like($result1, qr/First run/,
        "First run executes successfully");
    
    # Second run
    my $result2 = $runner->run("print 'Second run\n';");
    like($result2, qr/Second run/,
        "Second run executes successfully");
}