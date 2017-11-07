package Taipan::Controller::G::User;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

use TryCatch;

use Class::Utils qw(makeparm selected_language unxss unxss_an chomp_date
		    valid_date get_array_from_argument trim user_login);


my ($o_appuser,$h_user,$c_userid,$in_data);

=head1 NAME


G::User Rest services

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub auto : Private
{
  my $self		= shift;
  my $c			= shift;

  my $f = "G/user";
  my $dbic = $c->model('TDB')->schema;

  my $c_userid;
  {
    $c_userid = $c->stash->{hello}->{user};
    $c_userid = 'UNKN' if(!$c_userid);
  }

  $o_appuser = Class::Appuser->new($dbic,$c_userid)
    if($c_userid);

  $h_user =
  {
   userid	=> $c_userid,
   name		=> $o_appuser->aname,
   details	=> $o_appuser->details,
   active	=> $o_appuser->active,
  };

  $in_data	=  Class::General::get_json_hash($c);
  #$c->log->info("$f begin");


}


=head1 index

Info about the User

=cut

sub index :Path('/g/user') :Args(0)  : ActionClass('REST')
{
}

=head2 /g/user

REST Verb index_GET

Returns: Hash {userid,name,details,active}

=cut

sub index_GET
{
  my ( $self, $c ) = @_;

  my $f = "G/user/index_GET";
  $c->log->debug("$f Start GET");

  my $dbic	= $c->model('TDB')->schema;
  my $o_redis	= Class::Utils::get_redis;

  my $h_rest;
  $h_rest->{user} = $h_user;

  if($o_appuser)
  {
    $self->status_ok( $c, entity => $h_rest );
  }
  else
  {
    $self->status_no_content($c,
       message => "Cannot Find User. ");
  }


}


=head1 login

Login user through REST

=cut

sub login :Path('/g/user/login') :Args(0)  : ActionClass('REST')
{
}

=head2 /g/user/login

REST Verb POST

In Data: Hash{userid,password}

Returns: Hash {userid}

=cut

sub login_POST
{
  my ( $self, $c,$in_page ) = @_;

  my $m = "G/user/login_POST";
  $c->log->debug("$m Start ");

  my $dbic	= $c->model('TDB')->schema;
  my $o_redis	= Class::Utils::get_redis;

  my $c_action = "/g/user/login";
  my ($o_appuser,$h_rest,$row_appuser,$err_msg);
  $err_msg = "Userid or password is missing";

  # Get the username and password from form

  ##-- 1. Get Basic stuff: userid,password,ip,url
  my $o_ltry;
  my ($ip,$user_agent,$h_attempt,$app_userid,$password,$is_user_validated);
  {
    $app_userid		= trim($in_data->{userid});
    $password		= trim($in_data->{password});
    $c->log->debug("$m  $app_userid");

    $ip			= $c->req->address;
    $user_agent		= $c->request->user_agent();

    ##-- Fill in the Details in Hash for Logging Purpose
    $h_attempt->{user_agent}	= $user_agent;
    $h_attempt->{ip}		= $ip	;
    $h_attempt->{userid}	= $app_userid ;
    $h_attempt->{login_success} = 'f';
    $h_attempt->{url}		= "g/user/login";
  }

  ##-- 2. Captcha Section
  ##-- Commented out Currently
  my ($is_captcha_valid,$o_captcha);
  $is_captcha_valid = 1;
  {
    #Realperson Code, Captcha
    my ($cap_response_field,$pvt_key_captcha,
	$pub_key_captcha,$cap_challenge_field);
    #  my $pvt_key_captcha  = config(qw/Recaptcha private_key/);
    #  my $pub_key_captcha  = config(qw/Recaptcha public_key/);
    #  $c->log->debug("$m: C Pub Key: $pub_key_captcha");
    #  $o_captcha = Captcha::reCAPTCHA->new;
    ##Recaptcha Start

    #  my $captcha_html = $captcha_obj->get_html
    #    ($pub_key_captcha);

    #  $c->stash->{captcha_html} = $captcha_html;

    #  my $cap_challenge_field =$aparams->{recaptcha_challenge_field};
    #  my $cap_response_field  =$aparams->{recaptcha_response_field};

    if ($cap_response_field && $cap_response_field)
    {

      my $ip = $c->req->address;
      $c->log->debug("$m: IP:$ip");

      my $cap_result = $o_captcha->check_answer
	($pvt_key_captcha,$ip,
	 $cap_challenge_field,$cap_response_field
	);

      if ( $cap_result->{is_valid} )
      {
	$c->log->debug("$m: CAPTCHA(Valid) $ip ");
	$is_captcha_valid=1;
      }
      else
      {
	# Error
	my $error = $cap_result->{error};
	$c->log->debug("$m: CAPTCHA(InValid) $ip $error ");

      }
    }

  }##-- Captcha Section

  ##--3 Authenticate Here.
  # If the username and password values were found in form
  $is_user_validated = 0;

  if ($app_userid && $password && $is_captcha_valid)
  {

    $row_appuser = $c->find_user({ userid => $app_userid });
    $c->log->debug("$m: User Obj: $row_appuser");

    ##-- 3A: User Validated
    my $appuser_validated;
    if($row_appuser)
    {
      $appuser_validated = $row_appuser->get_column('active');
    }
    if ($appuser_validated > 0 || $appuser_validated eq 't')
    {
      $is_user_validated = 1;
    }
    $c->log->debug("$m Validated:$is_user_validated ");

    ##-- 3B: Check Password
    if ($row_appuser && ($is_user_validated > 0))
    {

      my $encoded_password = 
	Class::Appuser::encode_password($password);
      $c->log->debug("$m: Encoded PW: $encoded_password");

      my $h_user_au = 
      {
       userid	=> $app_userid,
       #password	=> $password, 
       #Simple Un-Encrypted Password
       password	=> $encoded_password,
      };

      $c->log->debug("$m: Going for authentication.");
      if($c->authenticate($h_user_au, 'simpledb'))
      {
	#      $c->set_authenticated($app_user); 
	$c->log->info("$m We are through");

	try
	{
	  ##1. Appuser Obj
	  $o_appuser = Class::Appuser->new($dbic,$app_userid);

	  ##2. For increased security change the session after Login
	  $c->change_session_id;

	  ##3. Session Expire Customized.
	  ##-- Doesn't work with Redis/FastMmap
	  #$c->session_expires(3600);

	  ##4. Log the user-Login
	  $o_ltry = Class::Logintry::login_valid($dbic,$h_attempt);

	}

	##
	#$c->response->redirect('/home') ;
	#  return;

      }

    }##IF Appuser
    #my $loggedin_userid = $c->user->get('userid');
  }

  ## 4. Handle Failure Message and fill in the Log
  my $is_user_logged_in = $c->user_exists;
  if (!$is_user_logged_in)
  {

    if ($row_appuser && $is_user_validated == 0)
    {
      $err_msg  = "This Email is not verified.";
    }
    else
    {
      $err_msg = "Wrong username or password.";
    }

    try
    {
      $o_ltry = Class::Logintry::user_pass_invalid($dbic,$h_attempt);
    }
  }


  ##-- Return the Data
  if($o_appuser)
  {
    $h_rest->{userid} = $app_userid;
    $self->status_ok( $c, entity => $h_rest );
  }
  else
  {
    $c->log->info("$m Failed");
    $self->status_bad_request($c, message => $err_msg);
  }


}

=head1 TODO

=head2 token

User Token

=cut

#sub index_PUT
#{
#}

=head2 token

Info about the User

=cut

sub token :Path('/g/user/token') :Args(0)  : ActionClass('REST')
{
}

=head2 token_GET

REST Verb index_GET

{id,key,expiry}

=cut

sub token_GET
{
  my ( $self, $c ) = @_;

}

=head2 token_POST

REST Verb index_GET

Returns: A New Fresh Token in 
{id,key,expiry}

=cut

sub token_POST
{
  my ( $self, $c ) = @_;

}





=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as AGPLv3 itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
