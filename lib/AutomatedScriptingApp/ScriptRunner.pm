package AutomatedScriptingApp::ScriptRunner;

use strict;
use warnings;
use File::Find;
use File::Basename;
use AutomatedScriptingApp::Utils qw(log_message);

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
    my $scripts_dir = $self->{config}->get('scripts_dir');
    my @scripts;

    find(sub {
        return unless -f;
        return unless /\.pl$/;
        push @scripts, $File::Find::name;
    }, $scripts_dir);

    foreach my $script (@scripts) {
        log_message("Running script: $script");
        system($^X, $script);
        if ($? == -1) {
            log_message("Failed to execute: $!");
        } elsif ($? & 127) {
            log_message(sprintf("Script died with signal %d, %s coredump",
                                ($? & 127),  ($? & 128) ? 'with' : 'without'));
        } else {
            log_message(sprintf("Script exited with value %d", $? >> 8));
        }
    }
}

1;