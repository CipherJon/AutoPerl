# Automated Scripting App

This is an automated scripting application built with Perl. It runs predefined scripts automatically, often on a scheduled basis or in response to specific events. These scripts can perform various tasks such as data processing, system maintenance, report generation, automated testing, and more.

## Features

- **Script Configuration**: Easily configure multiple scripts to be run by specifying them in the `app_config.yaml` file.
- **Execution of Scripts**: Automatically runs each specified script and logs the execution.
- **Logging**: Logs messages to a specified log file, capturing important events and errors for later review.

## Requirements

- **Strawberry Perl**: This project uses Strawberry Perl for Unix tools and commands.
- **Berrybrew**: Berrybrew is used to manage the Perl virtual environment.

## Setup

1. **Install Strawberry Perl**: Download and install Strawberry Perl from [Strawberry Perl Downloads](http://strawberryperl.com/).

2. **Install Berrybrew**: Download and install Berrybrew from [Berrybrew](https://github.com/stevieb9/berrybrew).

3. **Clone the Repository**:
   ```sh
   git clone https://github.com/yourusername/AutoPerl.git
   cd AutoPerl
   ```

4. **Configure Perl Environment with Berrybrew**:
   ```sh
   berrybrew install 5.32.1_64
   berrybrew switch 5.32.1_64
   ```

5. **Install Required Perl Modules**:
   ```sh
   cpanm --installdeps .
   ```

## Running the Application

To run the application and execute the configured scripts:

1. **Open a Terminal in VS Code**:
   - In the VS Code terminal, ensure you are in your project directory:
     ```sh
     cd E:\Git\AutoPerl
     ```

2. **Run the Main Script**:
   - Execute the main Perl script:
     ```sh
     perl bin/run.pl
     ```

## Directory Structure

```
AutoPerl/
├── bin/
│   └── run.pl
├── config/
│   └── app_config.yaml
├── lib/
│   └── AutomatedScriptingApp/
│       ├── Config.pm
│       ├── ScriptRunner.pm
│       └── Utils.pm
├── local/
│   └── lib/
│       └── perl5/
├── logs/
│   ├── example.log
│   └── README.md
├── scripts/
│   ├── another_script.pl
│   ├── clear_log.pl
│   └── example_script.pl
└── t/
    ├── 00-load.t
    ├── 01-script_runner.t
    └── 02-config.t
```

## Example Files

### `bin/run.pl`
```perl
#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";  # Add the lib directory to @INC
use lib "$FindBin::Bin/../local/lib/perl5";  # Add the local lib directory to @INC
use AutomatedScriptingApp::ScriptRunner;
use AutomatedScriptingApp::Config;

# Load configuration
my $config_file = "$FindBin::Bin/../config/app_config.yaml";
my $config = AutomatedScriptingApp::Config->new($config_file);

# Initialize the script runner
my $script_runner = AutomatedScriptingApp::ScriptRunner->new($config);

# Run the scripts
$script_runner->run_scripts();
```

### `config/app_config.yaml`
```yaml
# Configuration settings for Automated Scripting App
scripts:
  - name: Example Script
    path: scripts/example_script.pl
  - name: Another Script
    path: scripts/another_script.pl
logs: logs/example.log
```

### `lib/AutomatedScriptingApp/Config.pm`
```perl
package AutomatedScriptingApp::Config;
use strict;
use warnings;
use YAML::XS 'LoadFile';

sub new {
    my ($class, $file) = @_;
    my $self = {};
    bless $self, $class;
    $self->{config} = LoadFile($file);
    return $self->{config};
}

1;
```

### `lib/AutomatedScriptingApp/ScriptRunner.pm`
```perl
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
```

### `lib/AutomatedScriptingApp/Utils.pm`
```perl
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
```

### `scripts/example_script.pl`
```perl
#!/usr/bin/env perl
use strict;
use warnings;

print "Hello from example_script.pl!\n";
```

### `scripts/another_script.pl`
```perl
#!/usr/bin/env perl
use strict;
use warnings;

print "Hello from another_script.pl!\n";
```

### `scripts/clear_log.pl`
```perl
#!/usr/bin/env perl
use strict;
use warnings;

# Path to the log file
my $log_file = 'logs/example.log';

# Open the file for writing, which will clear its contents
open my $fh, '>', $log_file or die "Could not open log file: $!";
close $fh;

print "Log file cleared successfully.\n";
```

### `logs/example.log`
```text
# Log file for the Automated Scripting App
```

### `logs/README.md`
```markdown
# Log Directory

This directory contains log files generated by the Automated Scripting App.

The main log file is `example.log`.
```

### `t/00-load.t`
```perl
#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;

BEGIN { use_ok('AutomatedScriptingApp::Config') }
```

### `t/01-script_runner.t`
```perl
#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;

BEGIN { use_ok('AutomatedScriptingApp::ScriptRunner') }
```

### `t/02-config.t`
```perl
#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 2;  # Update the number of planned tests to 2

my $config_file = 'config/app_config.yaml';
BEGIN { use_ok('AutomatedScriptingApp::Config') }

my $config = AutomatedScriptingApp::Config->new($config_file);
isa_ok($config, 'HASH', 'Config is a hash reference');
```

## Contributing

Feel free to fork this repository and contribute by submitting a pull request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License.