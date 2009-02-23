package Task::Pluggable::AbstractTaskManager;
use strict;
use warnings;
use Task::Pluggable::PluginManager;
use base qw(Class::Data::Inheritable Class::Accessor);
__PACKAGE__->mk_accessors(qw/tasks args task_name/);
my $_instance;

sub get_instance{
	my $class = shift;
	unless(defined $_instance){
		$_instance = new $class;
	}	
	return $_instance;
}

sub new{
	my $class = shift;
	my $self = $class->SUPER::new();
	$self->init();
	return $self;
}

sub init{
	my $self = shift;
	my $tasks = {};
	foreach my $task (Task::Pluggable::PluginManager->tasks()){
		die "task name repeat" if(exists $tasks->{$task->task_name});
		$task->task_manager($self);
		$tasks->{$task->task_name} = $task;	
	}
	$self->tasks($tasks);
}

sub load_args{
	my $self = shift;
	my @args = @_;
	$self->task_name(shift @args);
	$self->args(\@args);
}

sub do_task{
	my $self = shift;
	eval{
		die "task not exist" unless($self->task_name());
		die "task not exist" unless(exists $self->tasks->{$self->task_name()});
		$self->tasks->{$self->task_name()}->pre_execute($self);	
		$self->tasks->{$self->task_name()}->execute($self);	
		$self->tasks->{$self->task_name()}->post_execute($self);	
	};
	if($@){
		print '-----------------------------------------------------------------------'."\n";
		print 'Task Execute Error: '.$@;
		print '-----------------------------------------------------------------------'."\n";
		$self->help();
	}
}

sub help{
	my $self = shift;
print <<__END_HELP_HEADER__;
Perl Task Manager
usage:
  ptm <task_name> <arg0> <arg1> ..
 
tasklist:

__END_HELP_HEADER__
	foreach my $task_name (sort{ $a cmp $b } keys %{$self->tasks}){
		print '  ';
		printf('%-15s',$task_name);
		print '  ';
		print $self->tasks()->{$task_name}->task_description()."\n";
		if($self->tasks()->{$task_name}->task_args_description()){
			printf('  %-15s  ','');
			print sprintf('%-15s',$self->tasks()->{$task_name}->task_args_description())."\n";
		}
	}

print <<__END_HELP_FOOTER__;

__END_HELP_FOOTER__

}


1;
