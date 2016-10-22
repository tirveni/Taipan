#!/usr/bin/perl -w
#
# Class/Access.pm
#
# 2016-10-22,Tirveni Yadav

use strict;

package Class::Access;

use Moose;
use namespace::autoclean;

=pod

=head1 NAME

Class::Access - Utilities for handling access-related data

=head1 SYNOPSIS

    use Class::Access;
    $o_access	= Class::Access->new( $dbic, $role,$privilege );
    $row_access	= $o_access->dbrecord();

=head1 INHERITS

Class::Access does not inherit from any classes (usually called from
the context of role or privilege).

=cut

=head1 METHODS

=over

=item B<new( $dbic, $role, $privilege )>

=item B<new( $dbic, $access )>

Accept a access (either as a role, privilege combination or as a
DBIx::Class::Row object and create a fresh Class::Access object from
it. A dbic must be provided.

Return the Class::Access object, or undef if the desired
role/privilege combination couldn't be found.

=cut

# Constructor
sub new
{
  my $class	=	shift;
  my $dbic	=	shift;
  my $argaccess = shift;
  my $privilege = shift;

  my $role   = $argaccess;
  my $access = $argaccess;

  unless( ref($access) )
  {
     $access = $dbic->resultset( 'Access' )
       ->find({ role=>$role, privilege=>$privilege });
  }

  return( undef )
    unless $access;
  my $self = bless( {}, $class );

  $self->{access_dbrecord} = $access;

  return( $self );
}

=item B<dbrecord()>

Return the DBIx::Class::Row object for this Access.

=cut
# Get the database object
sub dbrecord
{
  my
    $self = shift;
  return( $self->{access_dbrecord} );
}
sub access_dbrecord
{
  my
    $self = shift;
  return( $self->{access_dbrecord} );
}


=item B<keys()>

For internal use only.  Return an array of the names of the key fields
for this table in the database.

=cut
sub keys
{
  return ( qw/role privilege/ );
}

=back

=head1 ACCESSORS

=over

=item B<role>

=item B<privilege>

=cut
# Get/set role
sub role
{
  my
    $self = shift;
  my
    $role = shift;
  $self->access_dbrecord->set_column('role', $role)
    if $role;
  return( $self->access_dbrecord->get_column('role') );
}

# Get/set privilege
sub privilege
{
  my
    $self = shift;
  my
    $privilege = shift;
  $self->access_dbrecord->set_column('privilege', $privilege)
    if $privilege;
  return( $self->access_dbrecord->get_column('privilege') );
}

=back

=head1 OPERATIONAL METHODS

=over

=item B<create($dbic, $role, $privilege)>

Create a new access for the given $role and $privilege.  $role and
$privilege may be Class:: objects, or the role and/or privilege ID.

Returns the Class::Access object for the newly-created record.

=cut
sub create
{
  my $self = shift;		# Ignore it.
  my $dbic = shift;
  my $role = shift;
  my $privilege = shift;

  # Flatten if required
  $role = $role->role
    if ref($role);
  $privilege = $privilege->privilege
    if ref($privilege);
  my
    $rolerec = $dbic->resultset('Access')
      ->create({ role=>$role, privilege=>$privilege });
  return( Class::Access->new($dbic, $rolerec) );
}

=item B<delete>

Delete this access from the database.

=cut
# Delete
sub delete
{
  my
    $self = shift;
  return( $self->access_dbrecord->delete );
}



=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as AGPLv3  itself.

=cut


=back

=end

=cut

1;
