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