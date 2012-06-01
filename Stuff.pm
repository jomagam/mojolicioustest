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

1;
