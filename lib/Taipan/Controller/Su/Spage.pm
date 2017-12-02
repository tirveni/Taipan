package Taipan::Controller::Su::Spage;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

use Class::General;


use TryCatch;
use Class::Utils
  qw(makeparm selected_language unxss unxss_an xnatural xfloat valid_email
     chomp_date valid_date get_array_from_argument trim user_login);

my ($c_userid,$o_pagestatic,$in_data);

=head1 NAME

Tapan::Controller::Su::Spage - Catalyst Controller

This Controller is used for managing Static Pages.

=head1 DESCRIPTION

Catalyst Controller.

=head1 BRANCHES

=head2 auto

Checks if the PageID is Valid and User has permission. 

=cut

sub auto : Private
{
  my $self		= shift;
  my $c			= shift;
  my $in_pageid		= shift;

  my $fx = "Su/Page->auto";
  $c->log->info("$fx Begin Auto ");
  my $dbic = $c->model('TDB')->schema;

  my ($bx_owner,$o_biz);
  {
    $c_userid = Class::Utils::user_login($c);
  }
  $c->log->info("$fx User:$c_userid");

  if ($in_pageid)
  {
    $o_pagestatic = Class::Pagestatic->new($dbic,$in_pageid);
  }

  $in_data=  Class::General::get_json_hash($c);
  $c->log->info("$fx PS: $o_pagestatic");

}

=head2 su/spage/index

Business Page

=cut

sub index :Path('/su/spage') :ChainedArgs(0)  : ActionClass('REST')
#sub index :Path('/su/spage') :ChainedArgs(0) 
{
  my ( $self, $c, $pageid ) = @_;

  my $f = "Su/Spage::index";

}

=head2 /su/spage/:pageid	GET

Returns: {pageid,pagename,content,created_at}

Output is in JSON/XML format.


=cut

sub index_GET
{
  my $self	= shift;
  my $c		= shift;
  my $in_pageid	= shift;

  my $fx = "su/spage/index_GET";

  my $page_content	= $o_pagestatic->content;
  my $page_name		= $o_pagestatic->pagename;
  my $pageid		= $o_pagestatic->pageid;

  $c->log->info("$fx PageID:$pageid / $o_pagestatic");

  my $h_rest;
  $h_rest->{pageid}	= $pageid;
  $h_rest->{content}	= $page_content;
  $h_rest->{pagename}	= $page_name;
  #$h_rest->{created_at} = $o_pagestatic->created_at;

  if ($o_pagestatic)
  {
    $self->status_ok( $c, entity => $h_rest );
  }
  else
  {
    $self->status_not_found($c, message => 'Page not found');
  }


}

=head2 /su/spage/:pageid	POST

Returns: {pageid,pagename,content,created_at}

Output is in JSON/XML format.


=cut

sub index_POST
{
  my $self	= shift;
  my $c		= shift;

  my $fx = "su/spange/index_POST";
  my ($h_rest,$error,$row_page);
  my $dbic = $c->model('TDB')->schema;

  my ($content,$pagename,$pageid);
  {
    $pageid	= trim($in_data->{pageid});
    $content	= trim($in_data->{content});
    $pagename	= trim($in_data->{pagename});
  }

  my $h_in;
  {
    $h_in->{pageid}	= $pageid;
    $h_in->{content}	= $content;
    $h_in->{pagename}	= $pagename;
    $h_in->{userid}	= $c_userid;
  }
  $c->log->info("$fx Error:$error, U:$c_userid");

  if ($c_userid && $pageid && $content)
  {
    ($error,$row_page) = Class::Pagestatic::create($dbic,$h_in);
    $c->log->info("$fx Error:$error");
  }

  if (defined($row_page))
  {
    $pageid = $row_page->get_column('pageid');
    $o_pagestatic = Class::Pagestatic->new($dbic,$pageid);
  }

  if ($o_pagestatic)
  {
    my $h_rest;
    $h_rest->{pageid}	= $pageid;
    $h_rest->{content}	= $o_pagestatic->content;
    $h_rest->{pagename}	= $o_pagestatic->pagename;
    $self->status_ok( $c, entity => $h_rest );
  }
  else
  {
    my $msg = "Page could not be added:$error";
    $h_rest->{error_msg} = $msg;
    $c->res->status(402);
    $c->stash->{rest} = $h_rest;
    return;
    ##R_1
  }


}


=head1 Tags of Static Page

=head2 su/spage/tag/index

Business Page

=cut

sub tag :Path('/su/spage/tag') :Args(3)
{
  my ( $self, $c, $pageid,$tagtype,$in_priority ) = @_;

  my $f = "Su/Spage/tag";

}


=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as AGPLv3 itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
