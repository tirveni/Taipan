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

=cut

sub index :Path('/staff/index') :Args(1)
{
  my ( $self, $c, $in_userid ) = @_;

  my $fn	= "staff/index";
  #$c->response->body('Matched Taipan::Controller::Staff in Staff.');
  $c->stash->{page} = {'title' => 'Modify User' };
  $c->stash->{template} = 'User/add.tt.html';

  # Input Types
  my $pars      = makeparm(@_);
  my $aparams   = $c->request->params;

  ##Edit User(Can Change the role of the User)/(Disable  the User).

  ##Display User


  $c->stash->{page} = {'title' => 'User' };
  $c->stash->{template} = 'src/user/staff.tt';

}


=head2 list

List Users

=cut

sub list :Path('/staff/list') :Args(2)
{
  my $self		= shift;
  my $c			= shift;
  my $startpage		= shift;
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
     listname     => 'Users',
     namefn       => 'list',
     nameclass    => 'user',
    );

  my $table_users = $c->model('TDB::Appuser')->search() ;
  my $rs_users = Class::General::paginationx
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

}




=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;