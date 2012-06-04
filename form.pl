
#
# Trivial example of how to use HTML::FormHandler with Mojolicious
#

use Mojolicious::Lite;

use HTML::FormHandler;

any [qw{post get}] =>  '/' => sub {
    my $self = shift;

    my @fields = (
	name => { type => 'Text', id => "foo", text => 'A Name:' }
    );

    my $form = HTML::FormHandler->new(field_list => \@fields);
    $form->process( params => $self->req->params->to_hash);

    if( $form->validated ){
        $self->render( text => 'SAVING NAME AS ' . $form->field('name')->value());
    }
    else {
	$self->render( text => $form->render);
    }
};

app->start;

