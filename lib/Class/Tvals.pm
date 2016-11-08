#!/usr/bin/perl -w
#
# Class/Msg
#
# 2016-04-30
#
package Class::Tvals;

use Moose;
use namespace::autoclean;

use TryCatch;

=pod

=head1 NAME

Class::Tvals - Utilities for handling Config Values

=head1 SYNOPSIS

    use Class::Tvals;
    $o_tvals = Class::Tvals->new( $dbic, $dtable,$tableuniq,cfield );
    $logexid       = $o_tvals->msgid;


=cut

use Class::Utils  qw(unxss unxss_an chomp_date valid_date trim );

my ($c_prefix_key_msg);
{
  $c_prefix_key_msg	=  $Class::Rock::red_prefix_has_message;

}


=head1 ADMINISTRIVIA

=over

=item B<new( $dbic,$dtable,$tableuniq,cfield )>

=item B<new( $dbic, $row_tval )>

Accept a Dtable,Tableuniq,CField (or a DBIx::Class::Row object)
and create a fresh Class::Tvals object from it. A db object must be
provided.


=cut

sub new
{
  my $class	=	shift;
  my $dbic	=	shift;
  my $dtable    =	shift;
  my $tuniq     =	shift;
  my $cfield    =       shift;

  my $m = "C/Tvals->new";

  my $row    = $dtable;

  unless ( ref($dtable) )
  {
    $dtable = unxss($dtable);
    if ($dtable)
    {
      my $rs_tvals = $dbic->resultset('Typevalue');
      $row	   = $rs_tvals->find
	(
	 {
	  dtable	=> $dtable,
	  tableuniq	=> $tuniq,
	  cfield	=> $cfield,
	 }
	);
    }
  }

  return (undef)
    unless $row;

  my $self = bless( {}, $class );
  $self->{tvals_dbrecord}             = $row;

  return $self;
}

=head2

=cut

sub dbrecord
{
  my
    $self = shift;
  return( $self->{tvals_dbrecord} );
}


=head1 ACCESSORS

=head2 dtable

Returns: Dtable

=cut

sub dtable
{
  my $self  = shift;

  my $value;
  my $field = 'dtable';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}

=head2 cfield

Returns: Cfield

=cut

sub cfield
{
  my $self  = shift;

  my $value;
  my $field = 'cfield';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}

=head2 cvalue

Returns: Cvalue (table)

=cut

sub cvalue
{
  my $self  = shift;

  my $value;
  my $field = 'cvalue';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}


=head2 ctype

Returns: Type

=cut

sub ctype
{
  my $self  = shift;

  my $value;
  my $field = 'ctype';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}

=head2 description

Returns: Description

=cut

sub description
{
  my $self  = shift;

  my $value;
  my $field = 'description';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}

=head2 valid

Returns: Field1

=cut

sub valid
{
  my $self  = shift;

  my $value;
  my $field = 'valid';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}

=head2 internal

Returns: Field1

=cut

sub internal
{
  my $self  = shift;

  my $value;
  my $field = 'internal';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}

=head2 priority

Returns: Field1

=cut

sub priority
{
  my $self  = shift;

  my $value;
  my $field = 'priority';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}



=head2 created_at

Returns: Created_at

=cut

sub created_at
{
  my $self  = shift;

  my $value;
  my $field = 'created_at';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}

=head2 update_userid

Returns: Field1

=cut

sub update_userid
{
  my $self  = shift;

  my $value;
  my $field = 'update_userid';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}

=head1 OPTIONAL Field/Values

fieldX/valueX Pair

=head2 field2

Returns: Field2

=cut

sub field2
{
  my $self  = shift;

  my $value;
  my $field = 'field2';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}

=head2 value2

Returns: Value2

=cut

sub value2
{
  my $self  = shift;

  my $value;
  my $field = 'value2';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}


=head2 field3

Returns: Field3

=cut

sub field3
{
  my $self  = shift;

  my $value;
  my $field = 'field3';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}

=head2 value3

Returns: Value3

=cut

sub value3
{
  my $self  = shift;

  my $value;
  my $field = 'value3';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}


=head2 field4

Returns: Field4

=cut

sub field4
{
  my $self  = shift;

  my $value;
  my $field = 'field4';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}


=head2 value4

Returns: Value4

=cut

sub value4
{
  my $self  = shift;

  my $value;
  my $field = 'value4';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}



=head2 field5

Returns: Field5

=cut

sub field5
{
  my $self  = shift;

  my $value;
  my $field = 'field5';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}


=head2 value5

Returns: Value5

=cut

sub value5
{
  my $self  = shift;

  my $value;
  my $field = 'value5';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}



=head2 field6

Returns: Field6

=cut

sub field6
{
  my $self  = shift;

  my $value;
  my $field = 'field6';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}


=head2 value6

Returns: Value6

=cut

sub value6
{
  my $self  = shift;

  my $value;
  my $field = 'value6';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}


=head1 OPERATIONS

=head2 create

Create entry in Table LogException

=cut

sub create
{
  my $dbic	=	shift;
  my $h_vals	=	shift;

  my $fn = "C/Logex/create";
  my ($o_tvals,$err_msg);

  try
  {
    my $rs_tvl	= $dbic->resultset('Typevalues');
    my $row_tvl = $rs_tvl->create($h_vals);
    $o_tvals	= Class::Tvals->new($dbic,$row_tvl);
  }
  catch($err_msg)
  {
    print "$fn   $err_msg \n";
  }

  return ($o_tvals,$err_msg);

}




=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as AGPLv3 itself.

=cut


1;
