package Stuff;

sub save_users {
    my $users = shift;

    open F, '>/home/balazs/interests.txt';
    foreach my $name (keys %$users){
	print F "$name\t$users->{$name}{is_favorite}\n";
    }
    close(F);
}

sub get_users {
    my %users;
    open F, '/home/balazs/interests.txt';
    while(my $line = <F>){
	chomp($line);
	my ($name, $is_favorite) = split /\t/, $line;
	$users{$name} = {is_favorite => $is_favorite};
    }
    close(F);
    return \%users;
}

sub ajaxhandler {
    my $self = shift;

    my $results = 'ERROR';

    my $function = $self->param('function');

    my $user = lc $self->param('param');
    $user =~ s{_.*}{}; # sometimes the user name passed in has _$TIMESTAMP appended to it

    my $users = Stuff::get_users();

    if($function eq 'addnewuser'){
	if(exists $users->{$user}){
	    $results = "$user already exists";
	}
	else {
	    $users->{$user} = {};
	    Stuff::save_users($users);
	    $results = 'OK';
	}
    }
    elsif($function eq 'remove'){
	if(exists $users->{$user}){
	    delete $users->{$user};
	    Stuff::save_users($users);
	    $results = 'OK';
	}
	else {
	    $results = "NO SUCH USER >$users<";
	}
    }
    elsif($function =~ m{^(no|yes)favorite$}){
	my $is_favorite = ($1 eq 'yes');
	if(exists $users->{$user}){
	    $users->{$user}{is_favorite} = $is_favorite;
	    Stuff::save_users($users);
	    $results = 'OK';
	}
	else {
	    $results = "NO SUCH USER: >$user<";
	}
    }
    else {
        $results = "INVALID ACTION: >$function<";
    }

    $self->render_json({ result => $results});
}

1;
