package Taipan::Controller::Logout;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Taipan::Controller::Logout - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

Action to logout an user from the application

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'src/user/login.tt';
    my $m = "LO/index";
    $c->log->debug("$m ::Inside Logout");  

    # Clear the user's state
    $c->logout;
    $c->delete_session;

    # Send the user to the starting point
    $c->response->redirect($c->uri_for('/login'));


}


=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
