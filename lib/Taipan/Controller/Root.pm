package Taipan::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

use TryCatch;


use Class::Utils;
use Class::Utils qw(today now trim unxss valid_date push_errors print_errors);
use Class::Pagestatic;

use Class::Rock;
use Class::Key;
use Class::General;
use Class::Appuser;
use Class::Advise;


=head1 NAME

Taipan::Controller::Root - Root Controller for Taipan

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{page}->{title} = 'Perl Catalyst';
    $c->stash->{template} = 'src/begin.tt';

    # Hello World
    #$c->response->body( $c->welcome_message );
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2

Runs on every request

=cut

sub auto : Private
{
  my ( $self, $c ) = @_;

  my $error;
  my @errors;
  my $m = "R/auto";

 TODAY_NOW:
  my ($today,$now,$todaynow) = undef;
  $today	= Class::Utils::today;
  $now		= Class::Utils::now;
  $todaynow	= $today . " " . $now;

 GET_IP:
  my $ip =  $c->request->address;

 GET_URL:
  my ($i_action,$i_path, $i_user_exist) = undef;
  $i_action	= $c->action();
  $i_path	= $c->request->path;

 SET_DEFAULT_USER:
  my ($i_login);
  $i_login	= 'UNKN';

 BUSINESS_AND_BRANCH_AND_APP:
  my ($i_app_id,$i_business_id,$i_branch_id) = undef;
  $i_app_id	= 'USERMAN';

  my $h_attempt;
  {
    $h_attempt->{ip}	= $ip		;
    $h_attempt->{date}	= $todaynow	;
    $h_attempt->{url}   = $i_path	;
    $c->log->debug("$m Start Action:$i_action ");
  }


 USER_IN_SESSION:
  try
  {
    $i_user_exist = $c->user_exists;
    $c->log->debug("$m IP:$ip Action:$i_action , ".
		 " Path:$i_path");

    my $first_args = $c->request->args->[0];

    $c->log->debug("$m path args: $first_args ");

    ### IF User Exists,then
  USER_EXISTS_THEN:
    if ($i_user_exist)
    {
      $i_login = $c->user->get('userid');
      $c->log->info("$m $i_action: LoginID: $i_login ..");
    }
  };


  ##Default
 FILL_IN_DISPLAY:
  my %ah = ( user => $i_login );
  $c->stash->{hello} = \%ah;

  if ( ($i_action eq 'default'))
  {
    return 1;
    ##Rx_1
  }

  ##--- Get PSQL,Redis DB Object.
  my ($dbic,$o_redis);
  {
    $dbic = $c->model('TDB')->schema;
    $o_redis = Class::Utils::get_redis();
  }

  ##--- Check On Redis,DBIC
  if (!$o_redis || !$dbic)
  {

    if (!defined($dbic))
    {
      $c->log->info("$m Error:3110111 DBIc Object missing");
    }
    if (!defined($o_redis))
    {
      $c->log->info("$m Error:3110222 Redis Object missing");
    }

    $c->response->body( 'Page not found' );
    $c->response->status(503);
    ##Set this up when page is ready
    $c->response->redirect( $c->uri_for('/default') );
    return 0;
    ##Rx_2
  }


 CHECK_USER_EXISTS:
  my ($fruit_userid,$fruit_errors,$h_xkey);

  ##--- B1: GET API KEYS And BranchID
  ##--- Also BranchID
 GET_API_KEYS:
  {
    my $is_key_given_but_failed;

    ($h_xkey,$is_key_given_but_failed) = Class::General::input_keys($c);

    if ($is_key_given_but_failed <= 0)
    {
      $fruit_userid = $h_xkey->{userid};
      $fruit_errors = $h_xkey->{errors};
      $c->log->info("$m  Key User: $fruit_userid ");
    }
    elsif ($is_key_given_but_failed > 0)
    {
      $c->log->info("$m Is_key_given_but_Failed:$is_key_given_but_failed");
      ##Display Error, If Keys were used and Authorization Failed.
      my $message = "Key Authorization Failed \n";
      _fishy($c,$i_login,$i_action,0);

      $c->response->body("$message");
      $c->response->status(403);

      ##--- If Keys invalid, Then Access Failed. Return 0
      return 0;
      ##Rx_3
    }

  }

  my $path_default_fwd = "default?url=$i_action";

  ##--- C. PERMISSION Handling BEGIN
  ##-----------------------------------------------------------
  ##--- Variables for User Permissions
  ##---
  my ($pg_allow,$user_role);
  $pg_allow  = 0;

  ##--- User  -> PSQL PERMIT
#  try  {

    my ($o_appuser);
    $c->log->info("$m  Appuser($i_login): $o_appuser ");

    ##--- C1. Get User Object
    ##---
  USER_OBJ:
    $o_appuser = Class::Appuser->new($dbic,$i_login);
    $c->log->info("$m  Appuser($i_login): $o_appuser ");
    $user_role = $o_appuser->role;

    ##--- C2. Get Admit Permission
    ##---
    if ($o_appuser)
    {
      $c->log->info("$m Check Permission ");
      $pg_allow = $o_appuser->url_allowed($dbic,$i_action);

    }

    $c->log->info("$m PG Result: $pg_allow");

    if ($pg_allow > 0)
    {
      _fishy($c,$i_login,$i_action,$pg_allow);

      #    $c->log->info("$m Go Ahead True:$is_go_ahead" );
      $c->stash->{hello}->{role} = $user_role;

      return 1;##1
      ##Rx_4
    }
    else
    {
      _fishy($c,$i_login,$i_action,$pg_allow);

      $c->log->info("$m Refused PG:$pg_allow  ");
      $c->response->body( 'Page not found' );
      $c->response->status(404);
      ##Set this up when page is ready
      $c->response->redirect( $c->uri_for('/default') );
      return 0;
      ##Rx_5
    }

#  }				##Try
#    catch($error)
#    {
#      push_errors(\@errors,1110221,$error) if($error);
#    }  ;

  ##--- D. Errors are put in the Log
  ##---
 ERROR_LOG:
  if (@errors)
  {
    Class::Utils::print_errors(\@errors);
  }


  ##--- E. ELSE FAILURE.
  ##----
  ##--- Every thing has Failed. No Reason
  ##--- We assume No Permission.Security First
  ##--- Hence ZERO
  ##---
 NOTHING_WORKS:
  {
    _fishy($c,$i_login,$i_action,-1);

    $c->log->info("$m Nothing Working 1110222");
    $c->response->body( 'Page not found' );
    $c->response->status(404);
    ##Set this up when page is ready
    $c->response->redirect( $c->uri_for('/default') );
    return 0;
    ##Rx_9
  }


  ## IF nothing works then move to Home
  ## $c->response->redirect( $c->uri_for('/') );

# Comment: Action and USer END



}

=head2 home

=cut
sub home : Path('home') :Args(0)
{
  my ( $self, $c) = @_;

  my $m = "R/home";

  my ( $i_action, $i_user_exist, $i_login );
  $i_action = $c->action();
  $i_login  = Class::Utils::user_login($c);

  $c->log->info("$m We are here at index: $i_action");

  $c->stash->{page} = {'title' => 'Taipan: Home',};
  $c->stash->{template} = 'src/home.tt';

  my $pageid = 'home';

  my ($o_redis,$dbic,$aparams,$o_appuser,$verify_list,$role,$userid);
  $aparams	= $c->request->params;
  $o_redis	= Class::Utils::get_redis;
  $dbic = $c->model('TDB')->schema;


  ##User
  $o_appuser = Class::Appuser->new($dbic,$i_login);
  $role  = $o_appuser->role;


  ##IF Notifications Are permitted
  my $is_notify_sys_on;

  if ($is_notify_sys_on eq 't')
  {

    my @list;
    my $rs_advisories = Class::Advise::get_notifications($dbic);

    while (my $row_notify = $rs_advisories->next() )
    {
      my $o_advise = Class::Advise->new($dbic,$row_notify);
      $c->log->info("$m Notify: $o_advise");


      push(@list,
	   {
	    notifyid	=> $o_advise->notifyid,
	    message	=> $o_advise->message,
	   }
	  );
    }

    $c->stash->{notifications} = \@list;

  }


}


=head2 _fishy

Fishy: For fail2ban

=cut

sub _fishy
{
  my $c			= shift;
  my $userid		= shift;
  my $i_action		= shift;
  my $is_allowed	= shift;

  if($userid eq 'UNKN')
  {
    $c->log->info("FISHY:$is_allowed $i_action");
  }
  else
  {
    $c->log->info("LOGGED_IN:$is_allowed $i_action");
  }

}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as AGPLv3 itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
