package AutomatedScriptingApp::Config;

use strict;
use warnings;
use YAML::XS qw(LoadFile);
use Carp;

sub new {
    my ($class, $file) = @_;
    my $self = {
        file => $file,
        config => LoadFile($file),
    };
    bless $self, $class;
    return $self;
}

sub get {
    my ($self, $key) = @_;
    return $self->{config}{$key} // croak "Key '$key' not found in config";
}

1;