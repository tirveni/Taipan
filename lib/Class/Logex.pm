#!/usr/bin/perl -w
#
# Class/Msg
#
# 2016-04-30
#
package Class::Logex;

use Moose;
use namespace::autoclean;

use TryCatch;

=pod

=head1 NAME

Class::Logex - Utilities for handling Exceptions.

=head1 SYNOPSIS

    use Class::Logex;
    $o_logex = Class::Logex->new( $dbic, $exceptionid );
    $logexid       = $o_logex->msgid;


=cut

use Class::Utils  qw(unxss unxss_an chomp_date valid_date trim );

my ($c_prefix_key_msg);
{
  $c_prefix_key_msg	=  $Class::Rock::red_prefix_has_message;

}


=head1 ADMINISTRIVIA

=over

=item B<new( $context,$exceptionid )>

=item B<new( $context, $row_exception )>

Accept a Exceptionid (or a DBIx::Class::Row object)
and create a fresh Class::Logex object from it. A db object must be
provided.


=cut

sub new
{
  my $class	= shift;
  my $dbic	= shift;
  my $arg_exceptionid   = shift;

  my $m = "C::Loge->new";

  my $row    = $arg_exceptionid;

  unless ( ref($arg_exceptionid) )
  {
    $arg_exceptionid = unxss($arg_exceptionid);
    if ($arg_exceptionid)
    {
      my $rs_logex = $dbic->resultset('Logexception');
      $row	   = $rs_logex->find($arg_exceptionid);
    }
  }

  return (undef)
    unless $row;

  my $self = bless( {}, $class );
  $self->{loge_dbrecord}             = $row;

  return $self;
}

=head2

=cut

sub dbrecord
{
  my
    $self = shift;
  return( $self->{loge_dbrecord} );
}


=head1 ACCESSORS

=head2 exceptionid

Returns: Exceptionid

=cut

sub exceptionid
{
  my $self  = shift;

  my $value;
  my $field = 'exceptionid';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}

=head2 userid

Returns: Userid

=cut

sub userid
{
  my $self  = shift;

  my $value;
  my $field = 'userid';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}

=head2 entity

Returns: Entity (table)

=cut

sub entity
{
  my $self  = shift;

  my $value;
  my $field = 'entity';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}


=head2 type

Returns: Type

=cut

sub type
{
  my $self  = shift;

  my $value;
  my $field = 'type';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}

=head2 reason

Returns: Reason

=cut

sub reason
{
  my $self  = shift;

  my $value;
  my $field = 'reason';
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


=head2 field1

Returns: Field1

=cut

sub field1
{
  my $self  = shift;

  my $value;
  my $field = 'field1';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}


=head2 value1

Returns: Value1

=cut

sub value1
{
  my $self  = shift;

  my $value;
  my $field = 'value1';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}

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


=head1 OPERATIONS

=head2 create

Create entry in Table LogException

=cut

sub create
{
  my $dbic	=	shift;
  my $h_vals	=	shift;

  my $fn = "C/Logex/create";
  my ($o_logex,$err_msg);

#  try  {
    my $rs_logex = $dbic->resultset('Logexception');
    #print "$fn RS LOGEX: $rs_logex \n";
    my $row_logex = $rs_logex->create($h_vals);
    #print "$fn Row LOGEX: $row_logex \n";

   $o_logex = Class::Logex->new($dbic,$row_logex);

#  }
#  catch($err_msg)
#  {
#    print "$fn   $err_msg \n";
#  }

  return ($o_logex,$err_msg);

}


=head2 err_user($dbic,$msgid,$in_v)

Store Exception for an User

=cut

sub err_user
{
  my $dbic	= shift;
  my $msgid	= shift;
  my $in_v	= shift;

  my $o_msg = Class::Msg->new($dbic,$msgid);
  my ($mx_type,$mx_name,$mx_message);

  if ($o_msg)
  {
    $mx_type	= $o_msg->type;
    $mx_name	= $o_msg->name;
    $mx_message	= $o_msg->message;
  }


  my $h_vals;
  $h_vals->{type}		= $mx_type;
  $h_vals->{reason}		= $mx_message;

  $h_vals->{field9}		= 'log';
  $h_vals->{value9}		= $in_v->{message};

  $h_vals->{field1}		= 'msgid';
  $h_vals->{value1}		= $msgid;

  ##Order Details
  $h_vals->{entity}		= 'user';
  $h_vals->{userid}		= $in_v->{userid};

  $h_vals->{field2}		= 'url';
  $h_vals->{value2}		= $in_v->{url};

  my ($o_logex,$err_msg) = Class::Logex::create($dbic,$h_vals);

  return ($o_logex,$err_msg);


}



=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as AGPLv3 itself.

=cut


1;
