package Task::Pluggable::CommandLineTaskManager;
use strict;
use warnings;
use base qw(Task::Pluggable::AbstractTaskManager);
my $_instance;

sub get_instance{
	my $class = shift;
	unless(defined $_instance){
		$_instance = new $class;
	}	
	return $_instance;
}

sub load_args{
	my $self = shift;
	$self->task_name(shift @ARGV);
	$self->args(\@ARGV);
}
1;
