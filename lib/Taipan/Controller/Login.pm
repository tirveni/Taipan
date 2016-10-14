package Taipan::Controller::Login;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

use Captcha::reCAPTCHA;
use Class::Utils qw(unxss trim config valid_email);
use Class::Appuser;


use Class::General;
use TryCatch;


=head1 NAME

Taipan::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

Action to login an user to the application.

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;

# Input Types
  my $aparams = $c->request->params;
  my $m = "Login/index";

# Page and Template
  $c->stash->{template} = 'src/user/login.tt';

  # Get the username and password from form
  my $app_userid	= trim($aparams->{userid});
  my $password		= trim($aparams->{password});
  $c->log->debug("$m: $app_userid:$password");

  my $o_ltry;
  my ($ip,$user_agent,$h_attempt);
  {
    $ip		= $c->req->address;
    $user_agent = $c->request->user_agent();
    $h_attempt->{user_agent}	= $user_agent;
    $h_attempt->{ip}		= $ip	;
    $h_attempt->{userid}	= $app_userid ;
    $h_attempt->{login_success} = 'f';
    $h_attempt->{url}		= "login";
  }

#Realperson Code, Captcha
  my ($cap_response_field,$captcha_obj,
      $pvt_key_captcha,$pub_key_captcha,$cap_challenge_field);
#  my $pvt_key_captcha  = config(qw/Recaptcha private_key/);
#  my $pub_key_captcha  = config(qw/Recaptcha public_key/);
#  $c->log->debug("$m: C Pub Key: $pub_key_captcha");
#  my $captcha_obj = Captcha::reCAPTCHA->new;
##Recaptcha Start

#  my $captcha_html = $captcha_obj->get_html
#    ($pub_key_captcha);

#  $c->stash->{captcha_html} = $captcha_html;

#  my $cap_challenge_field =$aparams->{recaptcha_challenge_field};
#  my $cap_response_field  =$aparams->{recaptcha_response_field};

  my $captcha_valid = 1;##

  if($cap_response_field && $cap_response_field)
  {

    my $ip = $c->req->address;
    $c->log->debug("$m: IP:$ip");

    my $cap_result = $captcha_obj->check_answer
      ($pvt_key_captcha,$ip,
       $cap_challenge_field,$cap_response_field
      );


    if ( $cap_result->{is_valid} )
    {
      $c->log->debug("$m: CAPTCHA(Valid) $ip ");
      $captcha_valid=1;
    }
    else {
      # Error
      my $error = $cap_result->{error};
      $c->log->debug("$m: CAPTCHA(InValid) $ip $error ");

    }
 }

#End Recaptcha, google
  my $dbic = $c->model('TDB')->schema;
  my $rs_appuser = $dbic->resultset('Appuser');
  my $user_validated;
  my $row_appuser;

  # If the username and password values were found in form
  if ($app_userid && $password && $captcha_valid)
  {

    $row_appuser = $rs_appuser->find({ userid => $app_userid });
    my $user_validated;
    $c->log->debug("$m: User Obj: $row_appuser");

    $user_validated = $row_appuser->get_column('active')
      if($row_appuser);
    $c->log->debug("$m Validated:$user_validated ");

    if ($row_appuser )
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
	#      $c->set_authenticated($row_appuser); 
	$c->log->info("L/index: We are through");

	##For increased security change the session after Login
	$c->change_session_id;

	##Change the Session Period, Does not work
	$c->change_session_expires( 4000 );

	#my $biscuit = Class::Appuser::set_auth_keys
	#  ($dbic,$app_userid);##Testing Purpose only.
	try
	{
	  $o_ltry = Class::Logintry::login_valid($dbic,$h_attempt);
	}

	##
	$c->response->redirect('/home') ;

	return;
      }

    }##IF Appuser

    my $user_is_logged_in = $c->user_exists;
    if (!$user_is_logged_in)
    {
      my $err_msg;
      if ($row_appuser &&
	     ($user_validated < 1 || $user_validated eq 'f')
	    )
      {
	$err_msg  = "This Email is not verified.";
      }
      else
      {
	$err_msg = "Wrong username or password.";
      }


      $c->stash(error_msg => $err_msg );

      try
      {
	$o_ltry = Class::Logintry::user_pass_invalid($dbic,$h_attempt);
      }

    }
    #my $loggedin_userid = $c->user->get('userid');
  }
  else
  {
    # Set an error message
    #$c->stash(error_msg => "Captcha is Invalid.");
    $c->stash(error_msg => "");
  }

}



=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
