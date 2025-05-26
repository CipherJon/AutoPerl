package AutomatedScriptingApp::Utils;
use strict;
use warnings;
use Exporter 'import';
use File::Basename;
use File::Spec;
use File::Copy qw(move);
use File::Path qw(make_path);
use DateTime;
use Try::Tiny;
use AutomatedScriptingApp::Config;

our @EXPORT_OK = qw(log_message log_debug log_error);

# Log configuration
our $MAX_LOG_SIZE = $AutomatedScriptingApp::Config::MAX_LOG_SIZE;
our $MAX_BACKUP_FILES = $AutomatedScriptingApp::Config::MAX_BACKUP_FILES;
our $LOG_DIRECTORY = File::Spec->catdir(dirname(__FILE__), $AutomatedScriptingApp::Config::LOG_DIRECTORY);
our $LOG_FILE = $AutomatedScriptingApp::Config::LOG_FILE;

# Log levels
use constant {
    LOG_LEVEL_DEBUG => 0,
    LOG_LEVEL_INFO  => 1,
    LOG_LEVEL_ERROR => 2
};

our $CURRENT_LOG_LEVEL = LOG_LEVEL_INFO;

sub set_log_level {
    my ($level) = @_;
    $CURRENT_LOG_LEVEL = $level;
}

sub log_debug {
    my ($message) = @_;
    _log_message($message, LOG_LEVEL_DEBUG) if $CURRENT_LOG_LEVEL <= LOG_LEVEL_DEBUG;
}

sub log_message {
    my ($message) = @_;
    _log_message($message, LOG_LEVEL_INFO) if $CURRENT_LOG_LEVEL <= LOG_LEVEL_INFO;
}

sub log_error {
    my ($message) = @_;
    _log_message($message, LOG_LEVEL_ERROR) if $CURRENT_LOG_LEVEL <= LOG_LEVEL_ERROR;
}

sub _log_message {
    my ($message, $level) = @_;
    
    my $log_file = File::Spec->catfile($LOG_DIRECTORY, $LOG_FILE);
    
    try {
        # Create log directory if it doesn't exist
        if (!-d $LOG_DIRECTORY) {
            make_path($LOG_DIRECTORY, { mode => 0755 }) or die "Could not create log directory: $!";
        }

        # Check if file exists and needs rotation
        if (-e $log_file && -s $log_file >= $MAX_LOG_SIZE) {
            # Rotate logs
            my $datetime = DateTime->now()->strftime("%Y-%m-%d_%H-%M-%S");
            my $backup_file = File::Spec->catfile($LOG_DIRECTORY, "$LOG_FILE.$datetime");
            move($log_file, $backup_file) or die "Could not rotate log file: $!";

            # Remove old backup files if necessary
            my $glob = File::Spec->catfile($LOG_DIRECTORY, "$LOG_FILE.*");
            my @backup_files = glob($glob);
            if (@backup_files > $MAX_BACKUP_FILES) {
                # Sort by modification time and remove oldest
                @backup_files = sort { -M $a <=> -M $b } @backup_files;
                my $removed = pop @backup_files;  # Remove the oldest file (last in sorted array)
                unlink $removed or die "Could not remove old log file: $!";
            }
        }

        # Open log file for appending
        open my $fh, '>>', $log_file or die "Could not open log file: $!";
        
        # Format timestamp
        my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime();
        my $timestamp = sprintf("%04d-%02d-%02d %02d:%02d:%02d",
                             $year + 1900, $mon + 1, $mday,
                             $hour, $min, $sec);
        
        # Add log level prefix
        my $level_prefix = $level == LOG_LEVEL_DEBUG ? "[DEBUG]" :
                          $level == LOG_LEVEL_ERROR ? "[ERROR]" :
                          "[INFO]";
        
        print $fh "[$timestamp]$level_prefix $message\n";
        close $fh;
        return 1;  # Success
    }
    catch {
        my $error = $_;
        # Log the error to STDERR and re-throw for proper error handling
        print STDERR "Logging error: $error\n";
        die "Failed to write to log file: $error";
    };
}

1;