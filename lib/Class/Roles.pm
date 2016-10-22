#!/usr/bin/perl -w
#
# Class/Roles.pm
#
# 2016-10-22,Tirveni Yadav
#

package Class::Roles;


use Moose;
use namespace::autoclean;

=pod

=head1 NAME

Class::Roles - Utilities for handling roles-related data

=head1 SYNOPSIS

    use Class::Roles;
    $c = Class::Roles->new( $dbic, $role );
    $row = $c->dbrecord();
    $context = $c->context();

=head1 METHODS

=over

=item B<new( $context, $role )>

Accept a role (either as a Role Code or as a DBIx::Class::Row
object and create a fresh Class::Roles object from it. A context
must be provided.

Return the Class::Roles object, or undef if the Role couldn't be
found.

=cut

# Constructor
sub new
{
  my $class	=	shift;
  my $dbic	=	shift;
  my $argrole = shift;

  my $role = $argrole;

  unless( ref($argrole) )
  {
     $role = $dbic->resultset( 'Role' )->find( $argrole );
  }

  return( undef )
    unless $role;

  my $self = bless( {}, $class );
#
# Fill in rest
  $self->{roles_dbrecord} = $role;
  return( $self );
}

=item B<dbrecord()>

Return the DBIx::Class::Row object for this role.

=cut
# Get the database object
sub dbrecord
{
  my
    $self = shift;
  return( $self->{roles_dbrecord} );
}
sub roles_dbrecord
{
  my
    $self = shift;
  return( $self->{roles_dbrecord} );
}


=item B<keys()>

For internal use only.  Return an array of the names of the key fields
for this table in the database.

=cut
sub keys
{
  return ( ('role') );
}

=head2 role

Returns: Role

=cut

sub role
{
  my $self = shift;

  my $field = 'role';
  my $value = $self->dbrecord->get_column($field);

  return $value;

}

=head2 description

Returns: Description


=cut

sub description
{
  my $self = shift;

  my $field = 'description';
  my $value = $self->dbrecord->get_column($field);

  return $value;

}


=back

=head1 INFORMATIONAL METHODS

=over

=item B<check_privilege($privilege)>

Return true if the current role (user) has access to the given
$privilege (typically a Catalyst action), false otherwise.

=cut
# Check user's privilege for given privilege (action).
sub check_privilege
{
  my $self = shift;
  my $privilege = shift;

  my $row_role = $self->dbrecord;
  my $dbic = $row_role->result_source->schema;

  my
    $access = $dbic->resultset('Access')
      ->find({role=>$self->role, privilege=>$privilege});
  return( $access ?1 :0 );
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
