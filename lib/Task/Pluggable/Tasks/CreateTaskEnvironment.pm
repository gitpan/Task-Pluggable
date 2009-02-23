package Task::Pluggable::Tasks::CreateTaskEnvironment;
use base Task::Pluggable::AbstractTask;
__PACKAGE__->task_name('create_task_env');
__PACKAGE__->task_description('create task environment for current directory');
__PACKAGE__->mk_classdata('task_script_name'=>'ptm');


sub execute{
	my $self = shift;	
	$self->create_task_dir();
	$self->create_task_script();
}	
sub create_task_dir{
	my $self = shift;
	my $pwd = $ENV{'PWD'};
	opendir my $fh ,$pwd;
	while(my $dir = readdir $fh){
		die 'Current directory not empty' if($dir ne '.' and $dir ne '..');
	}	
	close $fh;
	print "create task dirctory\n";
	$self->create_dir($pwd."/bin");	
	$self->create_dir($pwd."/conf");
	$self->create_dir($pwd."/lib");
	$self->create_dir($pwd."/lib/Tasks");
}
sub get_pwd{
}
sub create_task_script{
	my $self = shift;
	my $perl_path = $ENV{_};
	my $pwd = $ENV{'PWD'};
	my $manager_name = 'Task::Pluggable::CommandLineTaskManager';

	my $script = "#!$perl_path\n";
	$script   .= 'use lib qw(/usr/beat/leport/lib /usr/beat/leport/site-perl '.$pwd."/lib);\n";
	$script   .= <<'__END_SCRIPT__';
use Task::Pluggable;
my $task  = new Task::Pluggable();
__END_SCRIPT__
	$script .= '$task->run(new '.$manager_name. '())';

	my $script_path = $pwd."/bin/".$self->task_script_name();
	print "create task script\n";
	print $script_path ."\n";

	open my $fh,">".$script_path or die $!;
	flock($fh,2) or die $!;
	print $fh $script;
	close $fh;
	chmod 0755 ,$script_path;
}

sub create_dir{
	my $self = shift;
	my $path = shift;
	print $path."\n";
	mkdir $path;
}


1;
