#
# $Id: Privileges.pm,v 1.13 2009-06-05 12:54:31 tirveni Exp $
#
# of the accesslist and accesslista.
# CategoryPrivilegeType drop down box added to list specific categories.

# Added some error handling in the Privileges.
# And links to rolelist in privilege/lists .
#
# Deleting and Adding Privileges is working perfectly.
#
# Using New class functions for listing privileges.
#
# Privileges has RolesList with links for adding or removing privileges.
#
# Access Privilege List with checkbox working.Needed Class Fn()s to setPriv.
#
# Privileges List for the app.
#
package Taipan::Controller::Privileges;

use Class::Utils qw (makeparm);
use Class::General qw(paginationx);
use Class::Privileges;
use Class::Access;
use Class::Roles;


use strict;
use warnings;
use base 'Catalyst::Controller';


my ($c_rows_per_page);
{
  $c_rows_per_page = 10;
}

=head1 NAME

Eloor::Controller::Privileges - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

Cannot use Paths without POST/GET as urls might contain the slash(/).
Which might cause all sorts of trouble.

=cut

=head2 index

=cut

sub index : Private
{
  my ( $self, $c ) = @_;

  $c->response->body('Matched Taipan::Controller::Privileges in Privileges.');
}

=head3 list ()  Local

List Privileges .

=cut

sub list :Path('/privileges/list') :ChainedArgs(0)
{
  my $self                = shift;
  my $c                   = shift;

  my $startpage           = shift;
  my $desired_page        = shift;

  my $dbic = $c->model('TDB')->schema;

  my $privilegelistsearchterm = $c->session->{'PrivilegeSearchterm'};
  $c->log->error("Page $desired_page");
  $c->stash->{page} = {'title' => 'List Privilege',};

  my $total;

  if ( !defined($privilegelistsearchterm) ) # All privileges
  {
    $privilegelistsearchterm = [
				undef,
				{
				 order_by => [qw( privilege )],
				 rows     => $c_rows_per_page,
				}
			       ];

    $c->session->{PrivilegeListSearchterm} = $privilegelistsearchterm;
  }

  #Table Privilege
  my $table_privilege =   $dbic->resultset('Privilege')->search({});
  my @order_list = [qw(category privilege)];
  my %page_attribs;
  %page_attribs = (
		   desiredpage  => $desired_page,
		   startpage    => $startpage,
		   inputsearch  => $privilegelistsearchterm,
		   rowsperpage  => $c_rows_per_page,
		   order        => \@order_list,
		   listname     => 'Privileges',
		   namefn       => 'list',
		   nameclass    => 'privileges',
                  );

  my $rs_privileges;
  $rs_privileges =  paginationx( $c, \%page_attribs, $table_privilege );

  my @list = ();

  while ( my $privilege = $rs_privileges->next() )
  {
    my $category_rs   = $privilege->category;
    my $cat_description = 'N/A';
    $cat_description = $category_rs->description
      if ($category_rs);

    my $privilegename = $privilege->privilege   || 'N/A';
    my $description   = $privilege->description || 'N/A';

    push(
	 @list,
	 {
	  privilege   => $privilegename,
	  description => $description,
	  category    => $cat_description,
	 }
        );
  }

  $c->stash->{privilegelist} = \@list;


  $c->stash->{template} = 'src/access/privilegeslist.tt';
}

=head3 rolelist ()  Local

List Roles .

=cut

sub rolelist :Path('/privileges/rolelist') :ChainedArgs(0)
{
  my $self           = shift;
  my $c              = shift;

  my $startpage      = shift;
  my $desired_page   = shift;
  my $dbic = $c->model('TDB')->schema;

  my $rolesearchterm = $c->session->{'RolesSearchterm'};
  $c->log->error("Page $desired_page");
  $c->stash->{page} = {'title' => 'List Roles',};

  my $total;


  my @ignore_roles = [qw(UNKN DISABLED)];

  my $rs_roles	= $dbic->resultset('Role');
  $rs_roles	= $rs_roles->search
    (
     {
      -and =>	[role => {'!=','UNKN'}, role => {'!=','DISABLED'}],
     }
    );

  my @order_list = [qw(role)];
  my %page_attribs;
  %page_attribs = (
		   desiredpage  => $desired_page,
		   startpage    => $startpage,
		   inputsearch  => $rolesearchterm,
		   rowsperpage  => $c_rows_per_page,
		   order        => \@order_list,
		   listname     => 'Roles',
		   namefn       => 'rolelist',
		   nameclass    => 'privileges',
                  );

  $rs_roles =  paginationx( $c, \%page_attribs, $rs_roles );

  my @list = ();

  while (my $role = $rs_roles->next)
  {
    push(
	 @list,
	 {
	  role        => $role->role,
	  description => $role->description,
	 }
        );
  }

  $c->stash->{rolelist} = \@list;
  $c->stash->{template} = 'src/access/roleslist.tt';
}

=head2 info

P/info: only this function handles the permission change

=cut

sub info :Path('/privileges/info') :Args(0)
{
  my $self = shift;
  my $c    = shift;

  my $fn	= "P/info";

  my $pars	= makeparm(@_);
  my $aparams	= $c->req->params;
  my $dbic = $c->model('TDB')->schema;

  #Page and Template
  $c->stash->{page} = {'title' => 'Privilege Info',};
  $c->stash->{template} = 'src/access/privinfo.tt';

  my $in_privilege	= $aparams->{privilege};
  my $in_role		= $aparams->{role};
  $c->log->debug("$fn $in_role: $in_privilege");

  my $role;
  $role = Class::Roles->new( $dbic, $in_role )
    if ($in_role);
  if ( !($role) )
  {
    $c->log->debug("$fn \$role doesn't Exist:$in_role");
    $c->res->redirect( $c->uri_for('rolelist') );
    $c->detach();
  }
  my $roledesc = $role->description;

  my $o_privilege;
  $o_privilege	= Class::Privileges->new( $dbic, $in_privilege )
    if ($in_privilege);
  if (!$role)
  {
    my $error = "$fn: Role($in_role) is Not valid Role";
    $c->stash->{eloor}->{error} = $error;
    return;
  } elsif (!$o_privilege)
  {
    my $error = "$fn: Privilege($in_privilege) is Not valid Role";
    $c->stash->{eloor}->{error} = $error;
    return;
  }

  #Put the Values Back in the Form
  $c->stash->{input}=
  {
   privilege	=> $in_privilege,
   role		=> $in_role,
  };

  my $category		= $o_privilege->category;
  my $privilegename	= $o_privilege->privilege;
  my $privilegedesc	= $o_privilege->description;

  my $privilege_old_value = $role->check_privilege($privilegename);

  my $privilege_new_value = 0;
  my ( $access_allowed, $value );
  if ($privilege_old_value)
  {
    $access_allowed	= 'ALLOWED';
    $value		= 'CHECKED';
  }
  else
  {
    $access_allowed	= 'DENIED';
    $value		= '';
  }

  my $this_redirect;
  #Change the Permission
  #Do the Change
  if ( $aparams->{'Change'} )
  {
    if ( $aparams->{$privilegename} )
    {
      $privilege_new_value = 1;
    }

    if ( $privilege_new_value != $privilege_old_value )
    {
      $c->log->debug(   "$fn: DIFF Privilege: $privilegename ::OLD:NEW::"
			. $privilege_old_value . ":"
			. $privilege_new_value );

      my $new_access;
      if ( $privilege_old_value == 0 )
      {
	$new_access = Class::Access->create( $dbic, $role, $o_privilege );
	$this_redirect++;
      }
      if ( $privilege_old_value == 1 )
      {
	Class::Access->new
	    ( $dbic, $role->role, $o_privilege->privilege ) ->delete;
	$this_redirect++;
      }

    }
  }				#If Change


  #Display
  $c->stash->{display} =
  {
   roledesc		=> $roledesc,
   privilege		=> $privilegename,
   description		=> $privilegedesc,
   accessprivilege	=> $privilege_old_value,
   accessallowed	=> $access_allowed,
   value		=> $value,
   category		=> $category,
  };

  #redirect if permission has been changed
  if ( $this_redirect > 0 )
  {
    my $link	= "/privileges/accesslist/0/next/id=$in_role";
    $c->res->redirect( $c->uri_for( $link ) );
    $c->detach();
  }


}


=head3 accesslist ()  Local

List All Privileges. 

Available Permissions for a role.

[Which are available adding/deleting them to a role.]

$this_redirect is by default 0,if any change (adddition / deletion of
a privilege) then it is incremented.and if greater than 0 then this
method redirectes to itself afresh.

=cut

sub accesslist :Path('/privileges/accesslist') :ChainedArgs(0)
{
  my $self = shift;
  my $c    = shift;

  #Pagination
  my $startpage    = shift || 0;
  my $desired_page = shift || 0;
  my $dbic = $c->model('TDB')->schema;

  #input Ways
  my $pars	= makeparm(@_);
  my $aparams	= $c->request->params;
  my $fn	= "P/accesslist";

  $c->stash->{page}	= {'title' => 'List All Privileges',};
  $c->stash->{template} = 'src/access/accesslist.tt';

  my $role_input;
  my $category_input;

  #Role Input
  $role_input = $pars->{id} || $aparams->{id};
  $c->log->debug("$fn \$role_input : $role_input ");
  #Category Input
  $category_input = $pars->{category}||$aparams->{category}
    ||$aparams->{pcategory};


  my $o_role = Class::Roles->new( $dbic, $role_input );
  if ( !($o_role) )
  {
    $c->log->debug("$fn \$o_role doesn't Exist:$role_input ");
    $c->res->redirect( $c->uri_for('rolelist') );
    $c->detach();
  }

  $c->stash->{thisrole} = $o_role->role; # $role_input;
  $c->stash->{roledesc} = $o_role->description;


  my $table_privilege	= $dbic->resultset('Privilege')->search({});
  my @list;

  my $search_hash;
  $search_hash->{id}	= $role_input;

  #Search for the Selected input
  if ($category_input && ($category_input ne 'ALL'))
  {
    $c->log->debug("$fn \$category_input : $category_input");
    $table_privilege 	= $table_privilege->search
      (
       category		=> $category_input,
      );
    $search_hash->{category} = $category_input;
  }

  #Paginations
  my $alistsearchterm 	= $c->session->{'AllowedAccessListSearchTerm'};
  my @order_list	= [qw(category privilege)];

  my %page_attribs;
  %page_attribs =
    (
     desiredpage  => $desired_page,
     startpage    => $startpage,
     inputsearch  => $alistsearchterm,
     rowsperpage  => $c_rows_per_page,
     order        => \@order_list,
     listname     => 'Privileges',
     namefn       => 'accesslist',
     nameclass    => 'privileges',
     hashinsearch => $search_hash,
    );

  my $rs_privileges;
  $rs_privileges =  paginationx( $c, \%page_attribs, $table_privilege );

  my $this_redirect = 0;

  while (my $row_p = $rs_privileges->next() )
  {
    my $o_privilege	= Class::Privileges->new( $dbic, $row_p );
     my $category	= $o_privilege->category;
    my $privilegename	= $o_privilege->privilege;
    my $privilegedesc   = $o_privilege->description;

    my $privilege_old_value = $o_role->check_privilege($privilegename);

    #    $c->log->debug("$fn \$privilegename:$privilegename ");
    #    $c->log->debug("$fn \$privilegedesc:$privilegedesc ");

    my $privilege_new_value = 0;
    my ( $access_allowed, $value );
    if ($privilege_old_value)
    {
      $access_allowed	= 'ALLOWED';
      $value		= 'CHECKED';
    }
    else
    {
      $access_allowed	= 'DENIED';
      $value		= '';
    }

    push(
	 @list,
	 {
	  privilege       => $privilegename,
	  description     => $privilegedesc,
	  accessprivilege => $privilege_old_value,
	  accessallowed   => $access_allowed,
	  value           => $value,
	  category        => $category,
	 }
	);

  }

  if ( $this_redirect > 0 )
  {
    my $link	= "/privileges/accesslist/0/next/id=$role_input";
    $c->res->redirect( $c->uri_for( $link ) );
    $c->detach();
  }


  $c->stash->{privilegelist}  = \@list;

#  #Drop Down Box of Privilege Categor
  my @priv_category_vals = getprivilegescategories( $c, $category_input );
  $c->stash->{categoryvals} = \@priv_category_vals;

}


=head2 allowed

List Privileges which are allowed for a role.

Allowed Permissions for a role

Which are available to a role.

$this_redirect is by default 0,if any change (adddition / deletion of
a privilege) then it is incremented.and if greater than 0 then this
method redirectes to itself afresh.

=cut

sub allowed :Path('/privileges/allowed') :ChainedArgs(0)
{
  my $self = shift;
  my $c    = shift;

  #Pagination
  my $startpage    = shift || 0;
  my $desired_page = shift || 0;
  my $fn	= "P/allowed";

  my $pars 	= makeparm(@_);
  my $aparams 	= $c->req->params;
  my $dbic = $c->model('TDB')->schema;

  #Page and Template
  $c->stash->{page} = {'title' => 'List Allowed Privileges',};
  $c->stash->{template} = 'src/access/accesslist.tt';

  my $role_input;
  my $category_input;

  #Role Input
  $role_input = $pars->{id} || $aparams->{id};
  $c->log->debug("$fn \$role_input : $role_input ");
  #Category Input
  $category_input = $pars->{category}||$aparams->{category}
    ||$aparams->{pcategory};

  #Check if the Role Exist
  my $o_role = Class::Roles->new( $dbic, $role_input );
  if ( !($o_role) )
  {
    $c->log->debug("$fn \$o_role doesn't Exist:$role_input ");
    $c->res->redirect( $c->uri_for('rolelist') );
    $c->detach();
  }
  $c->stash->{thisrole} = $role_input;
  $c->stash->{roledesc} = $o_role->description;

  #Get the Table
  my $table_privilege 	= $dbic->resultset('Privilege')->search
    (
     {
     },
     {
      join => {'accesses' => 'privilege'}}
    );
  my @list;

  #
  my $search_hash;
  $search_hash->{id}  	= $role_input;

  if ($category_input && ($category_input ne 'ALL'))
  {
    $c->log->debug("$fn \$category_input : $category_input");
    $table_privilege 	= $table_privilege->search
      (
       'me.category'	=> $category_input,
      );
    $search_hash->{category} = $category_input;
  }

  #Join with Access for Selected Categories
  #Get Roles Allowed from the Join of Accesses
  if ($role_input)
  {
    $c->log->debug("$fn Join \$role_input : $role_input");
    $table_privilege 	= $table_privilege->search
      (
       'role'		=> $role_input,
      );
  }

  my $order_field_a	= "me.category";
  my $order_field_b	= "me.privilege";
  my $alistsearchterm 	= $c->session->{'AllowedAccessListSearchTerm'};
  my @order_list	= [$order_field_a, $order_field_b];

  my %page_attribs;
  %page_attribs =
    (
     desiredpage  => $desired_page,
     startpage    => $startpage,
     inputsearch  => $alistsearchterm,
     rowsperpage  => $c_rows_per_page,
     order        => \@order_list,
     listname     => 'Privileges',
     namefn       => 'allowed',
     nameclass    => 'privileges',
     hashinsearch => $search_hash,
    );

  my $rs_privileges;
  $rs_privileges =  paginationx( $c, \%page_attribs, $table_privilege );

  my $this_redirect = 0;

  while (my $row_p = $rs_privileges->next() )
  {
    my $o_privilege	= Class::Privileges->new( $dbic, $row_p );
    my $category	= $o_privilege->category;

    my $privilegename = $o_privilege->privilege;
    my $privilegedesc = $o_privilege->description;

    #  $c->log->debug("$fn \$privilegename:$privilegename ");
    #  $c->log->debug("$fn \$privilegedesc:$privilegedesc ");

    my $privilege_new_value = 0;
    my $privilege_old_value = $o_role->check_privilege($privilegename);
    my ( $access_allowed, $value );
    if ($privilege_old_value)
    {
      $access_allowed = 'ALLOWED';
      $value          = 'CHECKED';
    } else
    {
      $access_allowed = 'DENIED';
      $value          = '';
    }

    push(
	 @list,
	 {
	  privilege       => $privilegename,
	  description     => $privilegedesc,
	  accessprivilege => $privilege_old_value,
	  accessallowed   => $access_allowed,
	  value           => $value,
	  category        => $category,
	 }
	);
  }				#While

  if ( $this_redirect > 0 )
  {
    my $link	= "/privileges/allowed/0/next/id=$role_input";
    $c->res->redirect( $c->uri_for( $link ) );
    $c->detach();
  }

  $c->stash->{privilegelist}  = \@list
    if (@list);
  #Drop Down Box
  my @priv_category_vals = getprivilegescategories( $c, $category_input );
  $c->stash->{categoryvals} = \@priv_category_vals;

}

=head3 getprivilegescategories()

This Fn returns the array Privileges Category. For the Drop Down Box

=cut

sub getprivilegescategories : Private
{
  my $c             = shift;
  my $category_prev = shift;

  my $dbic = $c->model('TDB')->schema;

  my @categoryvals  = ();
  my @categories    = 
    Class::PrivilegeCategory->getallprivilegecategorys($dbic);
  $c->log->debug("PvtFn GetPrivCategories");
  $c->log->debug("PvtFn GetPrivCategories \$category_prev : $category_prev");

  push(
       @categoryvals,
       {
	'categorycode' => 'ALL',
	'categoryname' => 'ALL',
       },
      );

  foreach my $o_category (@categories)
  {
    my $categoryselected;
    my $categorycode = $o_category->privilegecategory();
    my $categoryname = $o_category->description;

    $c->log->debug("PvtFn GetPrivCategories \$categorycode : $categorycode");

    if ( !( $category_prev eq 'ALL' ) && $category_prev eq $categorycode )
    {
      $categoryselected = "selected=\"selected\"";
      $c->log->debug("PvtFn Selected \$category_prev : $categorycode");
    }

    if ( !( $categorycode eq 'INTERNAL' ) )
    {
      push(
	   @categoryvals,
	   {
	    'categorycode' => $categorycode,
	    'categoryname' => $categoryname,
	    'selected'     => $categoryselected,
	   },
          );
    }
  }				#while

  return @categoryvals;
}

=head1 AUTHOR

tirveni yadav,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as AGPLv3 itself.

=cut

1;
