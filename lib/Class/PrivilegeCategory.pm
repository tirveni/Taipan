#!/usr/bin/perl -w
#
# 2016-10-22,Tirveni Yadav
#

package Class::PrivilegeCategory;


use Moose;
use namespace::autoclean;


=pod
=head1 NAME

Class::PrivilegeCategory - Utilities for handling
privilegecategory-related data

=head1 SYNOPSIS

    use Class::PrivilegeCategory;
    $c = Class::PrivilegeCategory->new( $dbic, $typeid );
    $row = $c->dbrecord();
    $context = $c->context();

=head1 INHERITS

Class::PrivilegeCategory does not inherit from any classes.

=cut


=head1 ADMINISTRIVIA

=over

=item B<new( $context, $typeid )>

Accept a Exception Type (either as a Category ID or as a
DBIx::Class::Row object and create a fresh Class::PrivilegeCategory
object from it. A context must be provided.

Return the Class::PrivilegeCategory object, or undef if the Category
ID couldn't be found.

=cut

# Constructor
sub new
{
  my $class	=	shift;
  my $dbic	=	shift;
  my $argcatid	=	shift;
  my
    $catid = $argcatid;
  unless( ref($argcatid) )
  {
     $catid = $dbic->resultset( 'Privilegecategory' )
       ->find( $argcatid );
  }

  return( undef )
    unless $catid;

  my $self = bless( {}, $class );
#
# Fill in rest
  $self->{privilegecategory_dbrecord} = $catid;
  return( $self );
}

=item B<dbrecord()>

Return the DBIx::Class::Row object for this PrivilegeCategory.

=cut
# Get the database object
sub dbrecord
{
  my
    $self = shift;
  return( $self->{privilegecategory_dbrecord} );
}
sub privilegecategory_dbrecord
{
  my
    $self = shift;
  return( $self->{privilegecategory_dbrecord} );
}

=item B<context()>

Get the Catalyst context for this PrivilegeCategory.

=cut
# Get the Catalyst context
sub context
{
  my
    $self = shift;
  return( $self->{context} );
}

=item B<keys()>

For internal use only.  Return an array of the names of the key fields
for this table in the database.

=cut
sub keys
{
  return ( ('privilegecategory') );
}

=back

=head1 METHODS

=over

=item B<getallprivilegecategorys( $dbic )>

Returns all Exception types as an array of Class::PrivilegeCategory objects.

=cut
# Get all exception types
sub getallprivilegecategorys
{
  my
    $self = shift;		# ignore
  my
    $dbic = shift;
  my
    @privilegecategorys;
  my
    $pcs = $dbic->resultset('PrivilegeCategory')->search(undef);

  while( my $row_pc = $pcs->next )
  {
    push(@privilegecategorys, Class::PrivilegeCategory->new($dbic, $row_pc));
  }

  return( @privilegecategorys );
}



=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as AGPLv3  itself.

=cut


1;


