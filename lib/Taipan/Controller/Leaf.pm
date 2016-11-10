package Taipan::Controller::Leaf;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Class::Pagestatic;

=head1 NAME

Taipan::Controller::Leaf - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(1)
{
  my ( $self, $c,$in_pageid ) = @_;

  my $m = "Leaf/index";


  my $dbic = $c->model('TDB')->schema;

  my $pageid = $in_pageid || 'contactus';

  my ( $i_action, $i_user_exist, $i_login );
  $i_action = $c->action();
  $c->log->info("$m We are here at index: $i_action");

  $c->stash->{page} = {'title' => 'Our Services',};
  $c->stash->{template} = 'src/leaf.tt';


  my $content = Class::General::page_details($c,$pageid);
  $c->log->debug("$m :: OBJ content "); 

  $c->stash->{TT_RIGHT_SIDE_HIDDEN} = 1;


}


=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
