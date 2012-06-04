
#
# Trivial example of how to use HTML::FormHandler with Mojolicious
#

use Mojolicious::Lite;

use HTML::FormHandler;

any [qw{post get}] =>  '/' => sub {
    my $self = shift;

    my @fields = (
		{ name => 'name',
		  label => 'Your name:',
		  type => 'Text', 
	          id => "username", 
		  required => 1,
		  minlength => 3,
		  minlength_message => '3 characters at least pls',
		  required_message => 'DDDD',
		  maxlength => 30,
		},
		{ name => 'message',
		  label => 'Message:',
		  type => 'Text', 
	          id => "message", 
		},
		{
		  name => 'submit',
		  type => 'Submit',
		  value => 'OK',
		},


    );
    
    my %form = (
		  required_message => 'Tell me your name!!!',
		  );

    my $form = HTML::FormHandler->new(field_list => \@fields, %form);
    $form->process( params => $self->req->params->to_hash);

    if( $form->validated ){
        $self->render( text => 'SAVING NAME AS ' . $form->field('name')->value());
    }
    else {
	$self->render( text => $form->render);
    }
};

app->start;

