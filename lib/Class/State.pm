#!/usr/bin/perl -w
#
# Class/State.pm
#
#
#
package Class::State;


use Moose;
use namespace::autoclean;

=head1 NAME

Class::State - Utilities for handling state-related data

=head1 SYNOPSIS

    use Class::State;
    $c = Class::State->new( $context, $country_code,$state_code );
    $row	= $c->dbrecord();
    $context	= $c->context();
    $state	= $c->statecode()
    $name	= $c->statename( [$statename] )

=cut

use Class::Country;
use Class::Utils qw(unxss unxss_an);



=head1 ADMINISTRIVIA

=over

=item B<new( $context, $countrycode, $statecode )>

=item B<new( $context, $staterec )>

Accept a country code and a state code (or a DBIx::Class::Row object)
and create a fresh Class::State object from it. A context must be
provided.

Return the Class::State object, or undef if the State couldn't be
found.

=cut

# Constructor
sub new
{
  my $class		= shift;
  my $dbic		= shift;
  my $arg_countrycode	= shift;
  my $arg_statecode	= shift;

  my $m = "C::State->new";

  my $row    = $arg_countrycode;

  unless ( ref($arg_countrycode) )
  {
    $arg_countrycode = unxss($arg_countrycode);
    if ($arg_countrycode)
    {
      my $rs_state = $dbic->resultset('State');
      $row = $rs_state->find
	(
	 {
	  state_country	=> $arg_countrycode, 
	  statecode	=> $arg_statecode,
	 }
	);
    }
  }

  return (undef)
    unless $row;

  my $self = bless( {}, $class );
  $self->{state_dbrecord}	= $row;

  return $self;

}

=item B<dbrecord()>

Return the DBIx::Class::Row object for this state.

=cut
# Get the database object
sub dbrecord
{
  my
    $self = shift;
  return( $self->{state_dbrecord} );
}
sub state_dbrecord
{
  my
    $self = shift;
  return( $self->{state_dbrecord} );
}


=head2 state_country

Returns: Countrycode

=cut

sub state_country
{
  my $self  = shift;

  my $value;
  my $field = 'state_country';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}


=item B<countrycode([$countrycode])>

Get the country code for this state.

=cut

sub countrycode
{
  my  $self = shift;
  my  $country = shift;

  my $value = $self->state_country;

  return $value;

}


=head2 statecode

Returns: Countrycode

=cut

sub statecode
{
  my $self  = shift;

  my $value;
  my $field = 'statecode';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}


=head2 statename

Returns: Countrycode

=cut

sub statename
{
  my $self  = shift;

  my $value;
  my $field = 'statename';
  my $dbrecord  = $self->dbrecord;

  $value = $dbrecord->get_column($field);
  return $value;

}

=head2 name

statename of the STate

=cut

sub name
{
  my $self	=	shift;

  my $name = $self->statename;

  return $name;

}

=head1 Write Ops

Create and Update City Record

=head2 create($dbic,{statename,statecode,countrycode,userid,userid}[,Class::Country])

Returns: ($row_state,$o_state,$errors)

=cut

sub create
{
  my $dbic	= shift;
  my $in_vals	= shift;
  my $o_country = shift;

  my $fn = "C/state/create";
  my ($row_state,$o_state,$errors);

  my ($statecode,$name,$state_country,$userid);
  {
    $statecode		= $in_vals->{statecode}||$in_vals->{new_state_name};
    $name		= $in_vals->{statename}||$in_vals->{new_state_code};
    $state_country	= $in_vals->{countrycode}||$in_vals->{country}
      || $in_vals->{country_code};
    $userid		= $in_vals->{userid};
  }
  ##

  ##--  $citycode has 20 chars
  if ($statecode)
  {
    my $x_statecode = unxss_an($statecode);
    $statecode = substr($x_statecode,0,2);
  }
  else
  {
    my $x_statecode = unxss_an($name);
    $statecode = substr($x_statecode,0,2);
  }

  ##-- Object state,Country
  {
    $o_country	= Class::Country->new($dbic,$state_country)
      if(!$o_country);

    $o_state	= Class::State->new($dbic,$state_country,$statecode);

  }

  my $in_h;
  $in_h->{userid}	= $userid;
  $in_h->{statecode}	= $statecode;
  $in_h->{state_country} = $state_country;
  $in_h->{statename}	= $name;

  ##-- Verified
  $in_h->{verified}	= 'f';

  my $t_state = $dbic->resultset('State');
  print "$fn $statecode,$name,$state_country,$o_state \n";

  if ($userid && $name && !$o_state && $o_country)
  {
    print "$fn State Exists \n";
    $row_state = $t_state->create($in_h);
    $o_state	= Class::State->new($dbic,$state_country,$statecode)
      if(defined( $row_state ));
  }
  else
  {
    print "$fn Missing Stuff \n";
    print "$fn $statecode,$name,$state_country,$userid,$o_state \n";
  }

  ##--
  if (!$row_state)
  {
    print "$fn State: Not Created.\n";
  }


  return ($row_state,$o_state,$errors);

}


=end

=cut

1;
