# Automated Scripting Application

This is an automated scripting application written in Perl. It allows you to run multiple Perl scripts automatically.

## File Structure

```plaintext
automated_scripting_app/
├── bin/
│   └── run.pl
├── lib/
│   ├── AutomatedScriptingApp/
│   │   ├── ScriptRunner.pm
│   │   ├── Config.pm
│   │   └── Utils.pm
├── scripts/
│   ├── example_script.pl
│   └── another_script.pl
├── t/
│   ├── 00-load.t
│   ├── 01-script_runner.t
│   └── 02-config.t
├── config/
│   └── app_config.yaml
├── logs/
│   └── README.md
├── Makefile.PL
├── README.md
└── .gitignore
```

## Usage

1. Clone the repository.
2. Install the required Perl modules.
3. Place your scripts in the `scripts/` directory.
4. Run the application using `bin/run.pl`.

## Configuration

The application configuration is stored in `config/app_config.yaml`. Update the `scripts_dir` key to point to the directory containing your scripts.

## Logging

Log files are stored in the `logs/` directory. The main log file is `app.log`.

## Testing

To run the tests, use the following command:

```sh
prove -l t/
```
