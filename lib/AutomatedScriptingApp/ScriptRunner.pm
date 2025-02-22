package AutomatedScriptingApp::ScriptRunner;
use strict;
use warnings;
use AutomatedScriptingApp::Utils;

sub new {
    my ($class, $config) = @_;
    my $self = {
        config => $config,
    };
    bless $self, $class;
    return $self;
}

sub run_scripts {
    my ($self) = @_;
    my $scripts = $self->{config}->{scripts};
    foreach my $script (@$scripts) {
        my $path = $script->{path};
        AutomatedScriptingApp::Utils::log_message("Running script: $path");
        system("perl", $path);
    }
}

1;