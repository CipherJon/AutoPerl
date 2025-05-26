use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'AutomatedScriptingApp',
    VERSION             => '1.0',
    ABSTRACT            => 'A scripting automation framework',
    AUTHOR              => 'Your Name <your@email.com>',
    LICENSE             => 'artistic_2',
    PREREQ_PM           => {
        'strict'   => 0,
        'warnings' => 0,
        'Carp'     => 0,
        'YAML'     => '1.30',
    },
    TEST_REQUIRES       => {
        'Test::More' => 0,
    },
    META_MERGE          => {
        'meta-spec' => {
            version => '2',
        },
    },
    BUILD_REQUIRES      => {
        'Test::More' => 0,
    },
    test                => {
        'TESTS' => 't/*.t',
    },
);
