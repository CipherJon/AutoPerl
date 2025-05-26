# AutoPerl - Automated Scripting Application

A robust Perl-based automation framework for running and managing automated scripts. This application provides a structured way to execute, monitor, and log the execution of various Perl scripts.

## Features

- **Script Management**: Configure and manage multiple scripts through YAML configuration
- **Automated Execution**: Run scripts automatically with proper error handling
- **Comprehensive Logging**: Detailed logging system with rotation and backup
- **Configuration Management**: Flexible configuration system using YAML
- **Error Handling**: Robust error handling and reporting

## Prerequisites

- Perl 5.32.1 or higher
- Required Perl modules (automatically installed during setup):
  - YAML::XS
  - DateTime
  - Try::Tiny
  - File::Path
  - File::Copy

## Quick Start

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/AutoPerl.git
   cd AutoPerl
   ```

2. **Install Dependencies**:
   ```bash
   cpanm --installdeps .
   ```

3. **Configure Your Scripts**:
   Edit `config/app_config.yaml` to add your scripts:
   ```yaml
   scripts:
     - name: My Script
       path: scripts/my_script.pl
   ```

4. **Run the Application**:
   ```bash
   perl bin/run.pl
   ```

## Project Structure

```
AutoPerl/
├── bin/                    # Executable scripts
│   └── run.pl             # Main runner script
├── config/                # Configuration files
│   └── app_config.yaml    # Main configuration
├── lib/                   # Core modules
│   └── AutomatedScriptingApp/
│       ├── Config.pm      # Configuration management
│       ├── ScriptRunner.pm # Script execution engine
│       └── Utils.pm       # Utility functions
├── logs/                  # Log files
├── scripts/              # Your automation scripts
└── t/                    # Test files
```

## Configuration

The application is configured through `config/app_config.yaml`. Here's a sample configuration:

```yaml
scripts:
  - name: Example Script
    path: scripts/example_script.pl
  - name: Another Script
    path: scripts/another_script.pl
```

## Logging

Logs are stored in the `logs/` directory. The application automatically:
- Rotates logs when they reach the maximum size
- Maintains a configurable number of backup files
- Includes timestamps and log levels

## Development

### Adding New Scripts

1. Create your script in the `scripts/` directory
2. Add the script to `config/app_config.yaml`
3. Ensure your script has proper error handling

Example script:
```perl
#!/usr/bin/env perl
use strict;
use warnings;
use AutomatedScriptingApp::Utils qw(log_message log_error);

try {
    # Your script logic here
    log_message("Script started");
    
    # ... your code ...
    
    log_message("Script completed successfully");
} catch {
    log_error("Script failed: $_");
};
```

### Running Tests

```bash
prove -l t/
```

## Troubleshooting

1. **Script Not Found**:
   - Verify the script path in `app_config.yaml`
   - Ensure the script has execute permissions

2. **Permission Issues**:
   - Check file permissions in the `logs/` directory
   - Ensure write access to the configuration directory

3. **Module Not Found**:
   - Run `cpanm --installdeps .` to install dependencies
   - Check Perl version with `perl -v`

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.