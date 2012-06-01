use Mojolicious::Lite;

get '/:foo' => sub {
    my $self = shift;
    my $foo = $self->param('foo');
    $self->render(text => "<html><head><title>XX</title></head><body>Hello from $foo.</body></html>");
};

app->start;
