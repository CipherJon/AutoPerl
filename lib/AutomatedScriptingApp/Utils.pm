package AutomatedScriptingApp::Utils;
use strict;
use warnings;
use Exporter 'import';
use File::Basename;
use File::Spec;

our @EXPORT_OK = qw(log_message);

sub log_message {
    my ($message) = @_;
    my $log_file = File::Spec->catfile(dirname(__FILE__), '../../logs/example.log');
    open my $fh, '>>', $log_file or die "Could not open log file: $!";
    print $fh "$message\n";
    close $fh;
}

1;