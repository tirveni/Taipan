#!/usr/bin/perl -w
#
# Class/Privileges.pm
#
# 2016-10-22,Tirveni Yadav
#
use strict;

package Class::Privileges;


use Moose;
use namespace::autoclean;

#use Class::Utils qw/today add_days/;

#
# Parent classes.
use Class::PrivilegeCategory;


=pod
=head1 NAME

Class::Privileges - Utilities for handling privileges-related data

=head1 SYNOPSIS

    use Class::Privileges;
    $c = Class::Privileges->new( $dbic, $privilege );
    $row = $c->dbrecord();
    $context = $c->context();

=head1 ADMINISTRIVIA

=over

=item B<new( $dbic, $privilege )>

Accept a privilege (either as a Privilege ID or as a DBIx::Class::Row
object and create a fresh Class::Privileges object from it. A dbic
must be provided.

Return the Class::Privileges object, or undef if the Privileges
couldn't be found.

=cut

# Constructor
sub new
{
  my $class	=	shift;
  my $dbic	=	shift;
  my $argprivilege = shift;

  my $privilege = $argprivilege;

  unless( ref( $argprivilege) )
  {
    $privilege = $dbic->resultset( 'Privileges' )
      ->find( $argprivilege );
  }

  return( undef )
    unless $privilege;
  my $self = bless( {}, $class );

  $self->{privileges_dbrecord} = $privilege;

  return( $self );
}

=item B<dbrecord()>

Return the DBIx::Class::Row object for this privileges.

=cut
# Get the database object
sub dbrecord
{
  my
    $self = shift;
  return( $self->{privileges_dbrecord} );
}
sub privileges_dbrecord
{
  my
    $self = shift;
  return( $self->{privileges_dbrecord} );
}


=item B<keys()>

For internal use only.  Return an array of the names of the key fields
for this table in the database.

=cut
sub keys
{
  return ( ('privilege') );
}


=back

=head1 ACCESSORS

=over

=item B<category>

=item B<privilegecategory>

=back

=cut
# Get/set privilege category
sub category
{
  my
    $self = shift;
  my
    $category = shift;
  $self->privileges_dbrecord->set_column('category', $category)
    if defined($category);
  $self->update;
  return( $self->privileges_dbrecord->get_column('category') );
}


sub privilegecategory{my $self=shift; return($self->category(@_));}

=back

=head1 INFORMATIONAL METHODS

=over

=item B<get_privileges($dbic [, $role])>

Get list of privileges for the current user, or for the given $role.
$role may be a role ID or a Class::Role object.

Returns an array of Class::Privileges objects.

=cut
# Get privileges for current user or given role
sub get_privileges
{
  my $dbic = shift;
  my $role = shift;

  # If role specified, make into object if necessary
  $role = Class::Roles->new($dbic, $role)
    if $role && !ref($role);

  # Get privileges
  my $rs_accesses = $role->dbrecord->search_related('accesses', {});
  my  @privileges;

  while( my $row_access = $rs_accesses->next )
  {
    my $prx = $row_access->get_column('privilege');
    my $o_prv =  Class::Privileges->new($dbic,$prx );
    push( @privileges,$o_prv);
  }

  return( @privileges );

}

=item B<get_all_privileges($context)>

Get a list of all privileges defined in the system.

Returns a list of Class::Privileges objects.

=cut
# List all privileges
sub get_all_privileges
{
  my $self = shift;		# Ignore it
  my $dbic = shift;

  my $rs_privileges = $dbic->resultset('Privileges')->search(undef);

  my @privileges;

  while( my $row_prv = $rs_privileges->next )
  {
    my $o_prv =  Class::Privileges->new($dbic, $row_prv);
    push(@privileges,$o_prv);
  }

  return(@privileges);
}

=back

=head1 OPERATIONAL METHODS

=over

=item B<create( $dbic, \%attribs )>

Create a new record in the privileges table.

The %attribs are used to fill out the record.  Possible attributes are:

=over

=item $attribs->privilege

The ID of this privilege.  This element is REQUIRED.

=item $attribs->category

Privilege category.

=item $attribs->description

Description of this privilege.

=back

Returns the Class::Privileges object for the new record.

=cut
# Create a new privilege record.
sub create
{
  my $dbic	= shift;
  my $attribs	= shift;

  my $row_prv = $dbic->resultset('Privileges')->create($attribs);

  return( Class::Privileges->new($dbic, $row_prv) );
}



=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as AGPLv3  itself.

=cut


=back

=cut

1;
