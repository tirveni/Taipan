package Taipan::Controller::Staff;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }


use Class::Utils qw(makeparm selected_language unxss chomp_date trim 
		  valid_date);


=head1 NAME

Taipan::Controller::Staff - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

Dispaly User Info.

AND Edit: Change Role OR Disable/Enable OR Password.

=cut

sub index :Path('/staff') :Args(1)
{
  my ( $self, $c, $sel_userid ) = @_;

  my $fn		= "staff/index";
  $c->stash->{page}	= {'title' => 'User' };
  $c->stash->{template} = 'src/user/staff.tt';
  my $dbic		= $c->model('TDB')->schema;

  # Input Types
  my $pars      = makeparm(@_);
  my $aparams   = $c->request->params;

  ##--- Input
  my ($inrole,$inpassword);
  {
    $inrole	= $aparams->{inrole};
    $inpassword = $aparams->{reset_password};
  }

  my ($c_userid,$o_sel_appuser);
  $c_userid = Class::Utils::user_login($c);
  if ($sel_userid)
  {
    $o_sel_appuser = Class::Appuser->new( $dbic, $sel_userid );
  }

  ##Edit User(Can Change the role of the User)/(Disable  the User).

  my $sel_user_role = $o_sel_appuser->role;
  my $updated = 0;
  my ($new_role,$new_password);

  if ( $o_sel_appuser )
  {
    $c->log->debug("$fn Update Appuser");

    ##-- Edit Role
    if (defined($inrole) && $sel_user_role ne 'SU')
    {
      if ($inrole eq 'DISABLED')
      {
	$new_role = $o_sel_appuser->set_role($inrole);
	$o_sel_appuser->set_active('f');
	$updated++;
      }
      elsif ($inrole ne 'SU' && $inrole ne 'UNKN')
      {
	$new_role = $o_sel_appuser->set_role($inrole);
	$o_sel_appuser->set_active('t');
	$updated++;
      }
    }

    ##--- Set New Password
    if ($inpassword && ($c_userid ne $sel_userid))
    {
      $new_password = $o_sel_appuser->reset_password();
    }

    if ($updated)
    {
      my $str_redirect = "/staff/$sel_userid";
      $c->log->debug("$fn REDIRECT URL:$str_redirect");

      ##--- Redirect
      $c->res->redirect( $c->uri_for($str_redirect) );
      $c->detach();
    }

  }
#Update/Modify End.

  ##Display User
  my $name = $o_sel_appuser->aname;
  my $userinfo;
  if ($name)
  {
    $userinfo->{userid}  = $o_sel_appuser->userid;
    $userinfo->{name}    = $o_sel_appuser->aname;
    $userinfo->{email}   = $o_sel_appuser->email || $o_sel_appuser->userid;
    $userinfo->{details} = $o_sel_appuser->details;
    $userinfo->{active}  = $o_sel_appuser->active;
    $userinfo->{role}	 = $sel_user_role;

    $c->stash->{userinfo} = $userinfo;
  }

  {
    $c->stash->{updated}->{password}	= $new_password;
    $c->stash->{updated}->{role}	= $new_role;
  }

  my $all_roles			= Class::Appuser::roles($dbic);
  $c->stash->{roles}		= $all_roles;
  $c->stash->{selected_role}	= $sel_user_role;

  ##BreadCrumbs
  {
    my @crumbs;
    my $parent_url  = "/staff/list";
    push(@crumbs,{url => $parent_url,  name=> "staff"});
    my $child_url  = "/staff/$sel_userid";
    push(@crumbs,{url => $parent_url,  name=> "$sel_userid"});
    $c->stash->{bcrumbs} = \@crumbs;
    $c->stash->{page}	= {'title' => "$sel_userid" };

  }

}


=head2 list

List Staff

=cut

sub list :Path('/staff/list') :ChainedArgs(0)
{
  my $self		= shift;
  my $c			= shift;
  my $startpage		= shift || 1;
  my $desired_page      = shift || 1 ;

  my $f = "User/list";
  $c->log->debug("$f StartPage: $startpage,desired:$desired_page");
  my $dbic = $c->model('TDB')->schema;

##USer Operating
#
  my ($o_appuser,$logged_user_role);
  $logged_user_role	= 'UNKN';
  my $c_userid = Class::Utils::user_login($c);

  if ($c_userid)
  {
    $o_appuser = Class::Appuser->new( $dbic, $c_userid );
    $logged_user_role = $o_appuser->role;
  }

  $c->log->debug("$f userid:$c_userid");
  $c->log->debug("$f Logged user obj:$o_appuser");
  $c->log->debug("$f User Role: $logged_user_role");

  if ($o_appuser && ($logged_user_role eq 'SU' ) )
  {
    $c->log->debug("$f User Pref. for Role: $logged_user_role. ");
  }
  else
  {
    my $str_redirect = "/home";
    $c->log->debug("$f REDIRECT URL:$str_redirect");
    ##Redirect
    $c->res->redirect( $c->uri_for($str_redirect) );
    $c->detach();
  }


  my $rows_per_page = 10;
  my @order_list = ('userid','role');

  my %page_attribs;
  my $user_searchterm = $c->session->{'listusers'};
  %page_attribs =
    (
     desiredpage  => $desired_page,
     startpage    => $startpage,
     rowsperpage  => $rows_per_page,
     inputsearch  => $user_searchterm,
     order	  => \@order_list,
     listname     => 'staff',
     namefn       => 'list',
     nameclass    => 'staff',
    );

  my $table_users	= Class::Appuser::list($dbic);
  my $rs_users		= Class::General::paginationx
    ( $c, \%page_attribs,$table_users );

  my @list;
  while ( my $user = $rs_users->next() )
  {

    my $str_active='No';
    my $active = $user->active;
    $str_active = 'Yes'
      if ($active);

    push
      (@list,
       {
	userid		=> $user->userid,
	name		=> $user->name,
	details		=> $user->details,
	datejoined	=> chomp_date($user->date_joined),
	active		=> $str_active,
	role		=> $user->get_column('role'),
       }
      );

  }

  $c->stash->{users} = \@list;
  $c->stash->{page} = {'title' => 'List Users' };
  $c->stash->{template} = 'src/user/listusers.tt';

  ##BreadCrumbs
  {
    my @crumbs;
    my $parent_url  = "/staff/list";
    push(@crumbs,{url => $parent_url,  name=> "staff"});
    $c->stash->{bcrumbs} = \@crumbs;
  }


}


=head2 add

Dispaly User Info.

AND Edit: Change Role OR Disable/Enable OR Password.

=cut

sub add :Path('/staff/add') :Args(1)
{

  my ( $self, $c  ) = @_;

  my $f ="R->index";
  #Form, Page and Template Issues
  $c->stash->{template} = 'src/User/add.tt';
  $c->stash->{page} = {'title' => 'Add User'};
  my $pars      = makeparm(@_);
  my $aparams   = $c->request->params;

  my $verification_reqd = 0;

  my $today     = Class::Utils::today ;
  my $now       = Class::Utils::now ;
  my $todaynow  = $today . " " . $now;
  my $dbic      = $c->model('HDB')->schema;

  #--input assignment
  my $o_appuser;
  my $password;
  my ($password_x,$password_y);
  my ($name,$dob,$email_input,$sex,$email);
  $name		= unxss($aparams->{name});

  $c->log->info("$f Name: $name ");
  my $existing_user_obj;

  if ($name)
  {
    $dob        = unxss(chomp_date( $aparams->{dob} ) );
    my $x_email = $aparams->{email};

    my $valid_email = Class::Utils::valid_email($x_email);
    $c->log->info("$f Valid Email:$valid_email ");

    $email_input = $x_email if($valid_email);
    $c->log->info("$f In Email: $email_input ");

    $sex		= unxss($aparams->{sex});
    $existing_user_obj  = Class::Appuser->new( $dbic, $email_input );

    if ( !$existing_user_obj )
    {
      $email = $email_input      ;

      $password_x	= unxss($aparams->{passwordx});
      $password_y       = unxss($aparams->{passwordy});
      $c->log->info("$f $password_x/$password_y ");

      if ($password_x eq $password_y)
      {
	$password = Class::Appuser::encode_password($password_y);
      }

    }				##If Existing User

  }				##If Name

  $c->log->info("$f Going In for Creation Email:$email".
		",Name:$name,pw:$password ");

  my $h_user;

  if ($password && $email && $name )
  {
    $c->log->info("$f Ready Steady Go ");

    $h_user =
    {
     userid     => $email,
     name	=> $name,
     #    dob           => $dob,
     active     => 'f',
     password   => $password,
    };

    $o_appuser = Class::Appuser::create($dbic,$h_user);


    if ($o_appuser && $verification_reqd > 0)
    {
      $c->log->info("$f Sending Mail with Verification Code ");
      #Send this to User by email.
      Class::EMail::send_appuser_verify($o_appuser);
      ##Send mail Now

    }
    else
    {
      ##-- Verification Part through Email
      my $verification_code = $o_appuser->verification_code(1);
      $o_appuser->validate_user($dbic,$verification_code);
    }

    if ($o_appuser)
    {

      ## And Redirect to verification form
      my $url = "/registration/validate/$email";
      $c->response->redirect($url) ;
    }


    #

  }

  ##-- Already Existing
  if ($existing_user_obj)
  {
    my $err_msg = "This Email address is already registered with us.";
    $c->stash(error_msg => $err_msg );
  }

  if ($password_y && $password_x && ($password_x ne $password_y))
  {
    my $err_msg = "Passwords do not match.";
    $c->stash(error_msg => $err_msg );
    $c->stash->{xuser}->{name}  = $name;
    $c->stash->{xuser}->{email} = $email;
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
