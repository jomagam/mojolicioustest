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

    my $user = lc $self->param('user');
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

sub current_interests {
    my $html;

    my $users = Stuff::get_users();

    foreach my $name (keys %$users){
	my $is_favorite = $users->{$name}{is_favorite};
	$html .= qq{<div class="auser" id="$name">};
	if($is_favorite){
	    $html .= qq|<span class="favorite" id="${name}_name">$name</span> <a id="${name}_fave_change_link" class="unfavorite_link" href="#"><span id="${name}_fave_change_text">Unfavorite</span></a> <a class="remove_link" href="#">Remove</a>|;
	}
	else {
	    $html .= qq|<span class="notfavorite" id="${name}_name">$name</span> <a id="${name}_fave_change_link" class="favorite_link" href="#"><span id="${name}_fave_change_text">Favorite</span></a> <a class="remove_link" href="#">Remove</a>|;
	}
	$html .= "</div>\n";
    }
    return $html;
}


1;
