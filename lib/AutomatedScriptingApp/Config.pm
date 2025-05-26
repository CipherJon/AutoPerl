package AutomatedScriptingApp::Config;
 
use strict;
use warnings;
use YAML::XS 'LoadFile';
use File::Spec;
use File::Path qw(make_path);
use Carp qw(croak);

use constant {
    LOG_FILE            => 'example.log',
    LOG_DIRECTORY       => 'logs/',
    MAX_LOG_SIZE        => 10 * 1024 * 1024,  # 10MB
    MAX_BACKUP_FILES    => 5,
    DEFAULT_SCRIPT_TIMEOUT => 30,  # seconds
};

sub new {
    my ($class, $file) = @_;
    my $self = {};
    bless $self, $class;
    
    # Load and validate configuration
    $self->{config} = LoadFile($file);
    my ($is_valid, $error) = $self->validate_config();
    
    unless ($is_valid) {
        die "Configuration validation failed: $error";
    }
    
    return $self;
}

sub validate_config {
    my ($self) = @_;
    
    # Define validation rules
    my @validations = (
        {
            name        => 'LOG_DIRECTORY',
            value       => LOG_DIRECTORY,
            required    => 1,
            type        => 'dir',
            create_ok   => 1
        },
        {
            name        => 'LOG_FILE',
            value       => LOG_FILE,
            required    => 1,
            pattern     => '^\w+\.log$',
            case_insensitive => 1
        },
        {
            name        => 'MAX_LOG_SIZE',
            value       => MAX_LOG_SIZE,
            required    => 1,
            type        => 'integer',
            min         => 1
        },
        {
            name        => 'MAX_BACKUP_FILES',
            value       => MAX_BACKUP_FILES,
            required    => 1,
            type        => 'integer',
            min         => 1
        }
    );

    # Perform validations
    for my $validation (@validations) {
        my ($param_name, $param_value) = ($validation->{name}, $validation->{value});
        
        if ($validation->{required} && !defined($param_value)) {
            return (0, "$param_name is required");
        }
        
        if ($validation->{type} && $validation->{type} eq 'dir') {
            if (!-d $param_value) {
                if ($validation->{create_ok}) {
                    my ($success, $error) = create_directory($param_value);
                    unless ($success) {
                        return (0, $error);
                    }
                } else {
                    return (0, "Invalid directory: $param_value");
                }
            }
        }
        
        if ($validation->{pattern}) {
            if (!defined($param_value) ||
                ($validation->{case_insensitive} ? $param_value !~ /$validation->{pattern}/i : $param_value !~ /$validation->{pattern}/)) {
                return (0, "Invalid format for $param_name");
            }
        }
        
        if ($validation->{type} && $validation->{type} eq 'integer') {
            if (!defined($param_value) || $param_value !~ /^\d+$/ || $param_value < $validation->{min}) {
                return (0, "$param_name must be an integer >= $validation->{min}");
            }
        }
    }
    
    # Validate scripts configuration
    unless (defined $self->{config}->{scripts} && ref $self->{config}->{scripts} eq 'ARRAY') {
        return (0, "Scripts configuration is missing or invalid");
    }
    
    foreach my $script (@{$self->{config}->{scripts}}) {
        unless (defined $script && ref $script eq 'HASH') {
            return (0, "Invalid script configuration format");
        }
        
        unless (defined $script->{path} && -f $script->{path}) {
            return (0, "Invalid script path: " . ($script->{path} || "undefined"));
        }
        
        # Validate timeout if specified
        if (defined $script->{timeout}) {
            unless ($script->{timeout} =~ /^\d+$/ && $script->{timeout} > 0) {
                return (0, "Invalid timeout value for script: " . $script->{path});
            }
        } else {
            # Set default timeout
            $script->{timeout} = DEFAULT_SCRIPT_TIMEOUT;
        }
    }

    return (1, "Configuration is valid");
}

sub create_directory {
    my ($dir) = @_;
    my $error;
    
    eval {
        make_path($dir, {
            verbose => 0,
            mode    => 0755,
        });
        1;
    } or do {
        $error = $@;
        # Clean up the error message
        $error =~ s/at .* line \d+\.$//;  # Remove file/line info
        $error =~ s/^\s+|\s+$//g;         # Trim whitespace
        return (0, "Failed to create directory '$dir': $error");
    };
    
    return (1, "Directory created successfully");
}

1;