package AutomatedScriptingApp::ScriptRunner;
use strict;
use warnings;
use AutomatedScriptingApp::Utils;
use IPC::Run qw(run timeout);
use File::Spec;
use File::Basename;
use Cwd qw(abs_path);
use Carp qw(croak);
use File::Find;
use constant __DIR__ => (File::Spec->splitpath(__FILE__))[1];

=head1 NAME

AutomatedScriptingApp::ScriptRunner - A module for executing scripts with configuration validation and security checks

=head1 SYNOPSIS

  use AutomatedScriptingApp::ScriptRunner;
  
  my $config = { scripts => [...] }; # Script configuration
  my $runner = AutomatedScriptingApp::ScriptRunner->new($config);
  $runner->run_scripts();

=head1 DESCRIPTION

This module provides a controlled environment for executing scripts with built-in security validation and logging. It supports script execution with timeout handling, configuration validation, and security checks.

=head1 METHODS

=head2 new($config)

Creates a new ScriptRunner instance with the provided configuration.

B<Parameters>:
- B<$config>: A hash reference containing the script configuration. The configuration should have a 'scripts' key containing an array of script definitions. Each script definition should be a hash with at least a 'path' key.

B<Returns>:
A new ScriptRunner object.

=head2 run_scripts()

Executes the scripts defined in the configuration. Each script is executed in sequence with validation and security checks.

B<Parameters>:
None.

B<Returns>:
Nothing.

B<Throws>:
- "Configuration not initialized" if no configuration was provided.
- "No scripts defined in configuration" if no scripts are configured.
- "Invalid script configuration" if any script entry is invalid.

=cut

sub new {
    my ($class, $config) = @_;
    my $self = {
        config => $config,
        allowed_paths => [
            __DIR__ . '/../../scripts',
            __DIR__ . '/../../config',
            __DIR__ . '/../../logs'
        ]
    };
    bless $self, $class;
    return $self;
}

sub run_scripts {
    my ($self) = @_;
    my $scripts = $self->{config}->{scripts};
    
    # Validate configuration first
    $self->validate_config();
    
    foreach my $script (@$scripts) {
        my $path = $script->{path};
        my $name = $script->{name} || $path;
        
        # Log script start with detailed information
        AutomatedScriptingApp::Utils::log_message("Starting script execution: $name");
        AutomatedScriptingApp::Utils::log_debug("Script path: $path");
        AutomatedScriptingApp::Utils::log_debug("Script parameters: " . $self->_sanitize_log($script->{parameters} || "None"));
        
        # Enhanced security checks
        $self->_validate_script_file($path) or next;
        
        # Prepare for script execution with timeout
        my $timeout = $script->{timeout} || 30;
        my $stdout = "";
        my $stderr = "";
        
        # Prepare command and arguments
        my @cmd = ($path);
        if (defined $script->{parameters}) {
            if (ref $script->{parameters} eq 'ARRAY') {
                push @cmd, @{$script->{parameters}};
            } elsif (ref $script->{parameters} eq 'HASH') {
                while (my ($key, $value) = each %{$script->{parameters}}) {
                    push @cmd, "--$key", $value;
                }
            } else {
                push @cmd, $script->{parameters};
            }
        }
        
        eval {
            # Use IPC::Run for better process control
            run(
                \@cmd,
                \undef, # stdin
                \$stdout, # stdout
                \$stderr, # stderr
                timeout($timeout)
            );
            
            if ($? != 0) {
                AutomatedScriptingApp::Utils::log_error("Script execution failed: $name (Return code: $?)");
                AutomatedScriptingApp::Utils::log_debug("STDOUT: $stdout");
                AutomatedScriptingApp::Utils::log_debug("STDERR: $stderr");
            }
        };
        
        if ($@) {
            if ($@ =~ /timeout/) {
                AutomatedScriptingApp::Utils::log_error("Script timed out after $timeout seconds: $name");
                AutomatedScriptingApp::Utils::log_debug("Partial output: $stdout");
            } else {
                AutomatedScriptingApp::Utils::log_error("Script execution error: $name - $@");
            }
        }
        
        # Log successful execution
        unless ($@ || $?) {
            AutomatedScriptingApp::Utils::log_message("Script completed successfully: $name");
            AutomatedScriptingApp::Utils::log_debug("Output: $stdout");
        }
    }
}

sub validate_config {
    my ($self) = @_;
    
    # Validate that config object exists
    unless (defined $self->{config}) {
        croak "Configuration not initialized";
    }
    
    # Validate scripts array exists and is populated
    unless (defined $self->{config}->{scripts} &&
            ref $self->{config}->{scripts} eq 'ARRAY' &&
            scalar(@{$self->{config}->{scripts}}) > 0) {
        croak "No scripts defined in configuration";
    }
    
    # Validate each script entry
    foreach my $script (@{$self->{config}->{scripts}}) {
        unless (defined $script && ref $script eq 'HASH') {
            croak "Invalid script configuration";
        }
        
        unless (defined $script->{path} && -f $script->{path}) {
            croak "Invalid script path: " . ($script->{path} || "undefined");
        }
        
        # Validate timeout if specified
        if (defined $script->{timeout}) {
            unless ($script->{timeout} =~ /^\d+$/ && $script->{timeout} > 0) {
                croak "Invalid timeout value for script: " . $script->{path};
            }
        }
    }
}

sub _validate_script_file {
    my ($self, $path) = @_;
    
    # Check if file exists and is readable
    unless (-f $path && -r $path) {
        AutomatedScriptingApp::Utils::log_error("Script file not accessible: $path. Absolute path: " . abs_path($path));
        return 0;
    }
    
    # Check if file is executable
    unless (-x $path) {
        AutomatedScriptingApp::Utils::log_error("Script not executable: $path. Suggestion: Run 'chmod +x $path'");
        return 0;
    }
    
    # Verify file ownership
    my $file_owner = (stat($path))[4];
    unless ($file_owner == $<) {
        AutomatedScriptingApp::Utils::log_error("Script ownership mismatch: $path");
        return 0;
    }
    
    # Validate file permissions
    my $file_mode = (stat($path))[2] & 07777;
    if ($file_mode & 0222) { # Check if group/world writable bits are set
        AutomatedScriptingApp::Utils::log_error("Script permissions are too permissive: $path (mode: " . sprintf("%04o", $file_mode) . ")");
        return 0;
    }
    
    # Check if script is within allowed paths
    my $abs_path = abs_path($path);
    my $is_allowed = 0;
    
    # Normalize the absolute path
    my @path_parts = File::Spec->splitdir($abs_path);
    
    foreach my $allowed_path (@{$self->{allowed_paths}}) {
        # Normalize the allowed path
        my $abs_allowed = abs_path($allowed_path);
        my @allowed_parts = File::Spec->splitdir($abs_allowed);
        
        # Check if the path is a subdirectory of an allowed path
        my $is_subdir = 1;
        for (my $i = 0; $i < @allowed_parts; $i++) {
            if ($i >= @path_parts || $path_parts[$i] ne $allowed_parts[$i]) {
                $is_subdir = 0;
                last;
            }
        }
        
        if ($is_subdir) {
            $is_allowed = 1;
            last;
        }
    }
    
    unless ($is_allowed) {
        AutomatedScriptingApp::Utils::log_error("Script path not in allowed directories: $path (Absolute path: $abs_path)");
        return 0;
    }
    
    # Basic content validation
    unless ($self->_validate_script_content($path)) {
        AutomatedScriptingApp::Utils::log_error("Script contains unauthorized content: $path");
        return 0;
    }
    
    return 1;
}

sub _validate_script_content {
    my ($self, $path) = @_;
    
    # Read file content
    open my $fh, '<', $path or return 0;
    my @lines = <$fh>;
    close $fh;
    
    # Check for suspicious patterns
    foreach my $line (@lines) {
        # Prevent system commands - match only actual command invocations
        if ($line =~ /(?:
            \b(?:system|exec)\s*\(|  # system() or exec() function calls
            \bfork\s*\(|            # fork() function calls
            \bopen\s*\([^)]*[|>]|   # open() with pipe or redirection
            \bsocket\s*\(|          # socket() function calls
            \b(?:qx|`)\s*[^`]*`|    # Backtick command execution
            \b(?:system|exec)\s+[a-zA-Z]|  # system/exec followed by command
            \b(?:eval|do)\s+['"]\s*[a-zA-Z]  # eval/do with command string
        )/x) {
            return 0;
        }
        
        # Prevent file operations outside allowed directories
        if ($line =~ /(?:^|\s)(?:open|copy|rename|unlink)\s*\([^)]*['"]([^'"]+)['"]/) {
            my $file = $1;
            my $is_allowed = 0;
            foreach my $allowed_path (@{$self->{allowed_paths}}) {
                if (index($file, $allowed_path) == 0) {
                    $is_allowed = 1;
                    last;
                }
            }
            unless ($is_allowed) {
                return 0;
            }
        }
        
        # Prevent network operations - match only actual function calls
        if ($line =~ /(?:
            \b(?:connect|bind|socket|inet_aton)\s*\(|  # Network function calls
            \b(?:IO::Socket|Net::|LWP::)  # Network-related modules
        )/x) {
            return 0;
        }
        
        # Prevent shell command execution - match only actual command execution
        if ($line =~ /(?:
            \b(?:system|exec|qx|`)\s*[^`]*[;&|]|  # Command with shell operators
            \b(?:eval|do)\s+['"]\s*[a-zA-Z].*[;&|]  # Eval/do with shell operators
        )/x) {
            return 0;
        }
        
        # Prevent environment variable manipulation - match only actual manipulation
        if ($line =~ /(?:
            \b(?:local|our|my)\s+\$ENV\{|  # ENV variable declaration
            \b\$ENV\{[^}]+\}\s*=/  # ENV variable assignment
        )/x) {
            return 0;
        }
    }
    
    return 1;
}

sub _sanitize_log {
    my ($self, $data) = @_;
    
    # Sanitize input for logging
    return undef unless defined $data;
    
    my $str = $data;
    $str =~ s/[^a-zA-Z0-9 _\-\.]/[REMOVED]/g;
    return $str;
}

1;