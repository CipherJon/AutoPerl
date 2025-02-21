use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'AutomatedScriptingApp',
    VERSION_FROM => 'lib/AutomatedScriptingApp/ScriptRunner.pm',
    PREREQ_PM    => {
        'YAML::XS' => 0,
    },
    EXE_FILES    => ['bin/run.pl'],
);
