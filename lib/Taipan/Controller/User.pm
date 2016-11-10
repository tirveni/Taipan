package Taipan::Controller::User;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }


use Class::Utils qw(makeparm selected_language unxss chomp_date trim 
		  valid_date);


=head1 NAME

Taipan::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

=cut

sub auto : Private
{
  my $self		= shift;
  my $c			= shift;

  my $f = "User/auto";
  my $dbic = $c->model('TDB')->schema;
  my $home_url = "/";

  my $c_userid = Class::Utils::user_login($c);

  if ($c_userid)
  {
    $c->log->info("$f U:$c_userid");
  }
  else
  {
    $c->log->info("$f ");
    $c->response->redirect( $home_url);
    $c->detach();
  }

}


=head2 index

Info of User

=cut

sub index :Path('/user')
{
  my $self	= shift;
  my $c		= shift;

  $c->stash->{page} = {'title' => 'User Info' };
  $c->stash->{template} = 'src/user/info.tt';

  my $fn = "User/index";

  my $aparams   = $c->request->params;
  my $dbic = $c->model('TDB')->schema;

  my ($userid,$o_appuser,$updated,$role);
  $updated = 0;
  $userid = $c->user->get('userid');
  $o_appuser = Class::Appuser->new( $dbic, $userid );
  $c->log->debug("$fn Logged user Obj: $o_appuser");
  $role = $o_appuser->role;

  ##--- Info For Display
  my $name;
  $name = $o_appuser->aname;

  my $userinfo;
  if ($name)
  {
    $userinfo->{userid}  = $o_appuser->userid;
    $userinfo->{name}    = $o_appuser->aname;
    $userinfo->{email}   = $o_appuser->email || $o_appuser->userid;
    $userinfo->{details} = $o_appuser->details;
    $userinfo->{active}  = $o_appuser->active;

    $c->stash->{userinfo} = $userinfo;
    $c->stash->{page} = {'title' => "$name" };
  }

  my $row_appuserkey = $o_appuser->api_key;
  $c->log->info("$fn Role:-$role-, Key row:$row_appuserkey");
  if ($role eq 'BUSINESS' )
  {
    my $h_key;
    $c->log->info("$fn Role:-$role ");
    $h_key->{role} = $role;
    if ( defined($row_appuserkey))
    {
      $h_key->{key1} = $row_appuserkey->key_guava;
      $h_key->{key2} = $row_appuserkey->key_jamun;
      $h_key->{valid_till} = $row_appuserkey->valid_till;
    }

    $c->stash->{key} = $h_key;
  }

  ##BreadCrumbs
  {
    my @crumbs;
    my $parent_url  = "/home";
    push(@crumbs,{url => $parent_url,  name=> "User"});
    $c->stash->{bcrumbs} = \@crumbs;
  }

}



=head2 edit

Modify Users.

Need to move most of logic to the Class.

=cut

sub edit :Path('/user/edit')
{
  my $self	= shift;
  my $c		= shift;

  $c->stash->{page} = {'title' => 'Edit' };
  $c->stash->{template} = 'src/user/edit.tt';

  my $aparams   = $c->request->params;
  my $dbic = $c->model('TDB')->schema;

  my $fn = "User/modify";

##USer Operating
#
  my ($userid,$o_appuser,$updated,$role);
  $updated = 0;
  $userid = $c->user->get('userid');
  $o_appuser = Class::Appuser->new( $dbic, $userid );
  $c->log->debug("$fn User Obj: $o_appuser");
  #my $role = $o_appuser->role;

=head3 Make changes

If the userid if submitted Or change_allowed is set.

After the change come back to the same page.With new info.

=cut

  if ( $o_appuser )
  {
    $c->log->debug("$fn Update Appuser");

    if ($aparams->{name})
    {
      $c->log->debug("$fn Update Name");
      $updated = $o_appuser->edit($dbic,$aparams);
    }

    ##--- Update Password
    if ($aparams->{passwordx})
    {
      $c->log->debug("$fn Update Password");
      $updated = $o_appuser->edit($dbic,$aparams);
    }

    if ($updated)
    {
      my $str_redirect = "/user";
      $c->log->debug("$fn REDIRECT URL:$str_redirect");

      ##--- Redirect
      $c->res->redirect( $c->uri_for($str_redirect) );
      $c->detach();
    }

  }
#Update/Modify End.


  ##--- Info For Display
  my $userinfo;
  {
    $userinfo->{userid}  = $o_appuser->userid;
    $userinfo->{name}    = $o_appuser->aname;
    $userinfo->{email}   = $o_appuser->email || $o_appuser->userid;
    $userinfo->{details} = $o_appuser->details;
    $userinfo->{active}  = $o_appuser->active;

    $c->stash->{userinfo} = $userinfo;
  }

}

=head2 apikey

Create/Edit/Disable API Key

=cut

sub apikey  :Path('/user/apikey')
{
  my $self	= shift;
  my $c		= shift;

  $c->stash->{page} = {'title' => 'Edit' };
  $c->stash->{template} = 'src/user/add.tt.html';

  my $aparams   = $c->request->params;
  my $dbic = $c->model('TDB')->schema;

  my $fn = "User/modify";

##USer Operating
#
  my $userid = $c->user->get('userid');
  my $o_appuser = Class::Appuser->new( $dbic, $userid );

  my $role = $o_appuser->role;

  my $valid_till = valid_date($aparams->{valid_till_submit});
  my $valid_from = valid_date($aparams->{valid_from_submit});

  $c->log->debug("$fn Till :$valid_till");

  my $row_appuserkey;
  if ($role eq 'BUSINESS' && $aparams->{generate} && $valid_till)
  {
    $row_appuserkey = $o_appuser->generate_key($valid_till);
  }


  my $str_redirect = "/user";
  $c->log->debug("$fn REDIRECT URL:$str_redirect");
  ##--- Redirect
  $c->res->redirect( $c->uri_for($str_redirect) );
  $c->detach();

}



=head PRIVATE FUNCTIONS


=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
