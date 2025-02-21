package AutomatedScriptingApp::Utils;

use strict;
use warnings;
use Exporter qw(import);
use File::Basename;
use POSIX qw(strftime);

our @EXPORT_OK = qw(log_message);

sub log_message {
    my ($message) = @_;
    my $log_dir = dirname(__FILE__) . '/../../logs';
    my $log_file = "$log_dir/app.log";
    
    my $timestamp = strftime "%Y-%m-%d %H:%M:%S", localtime;
    open my $fh, '>>', $log_file or die "Could not open log file '$log_file': $!";
    print $fh "[$timestamp] $message\n";
    close $fh;
}

1;