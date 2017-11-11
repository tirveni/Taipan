#!/usr/bin/perl -w
#
# Copyright Tirveni Yadav, 2015-07-30.
# License: AGPLv3
#


package Class::Languagetype;

use Moose;
use namespace::autoclean;
use Class::Utils qw(unxss);


has 'dbic' => (
  is => 'rw',
  required => 1,
  isa => 'DBIx::Class::Schema',
);

=pod

=head1 NAME

Class::Languagetype - Utilities for handling language-related data

=head1 SYNOPSIS

    use Class::Languagetype;
    $c	= Class::Languagetype->new( $dbic, $language );
    $row	= $c->language();
    $code	= $c->languagecode();
    $name	= $c->languagename();

=head1 METHODS

=over

=item B<new( $context, $language_code )>

Accept a language (either as a Languagetype Code or as a DBIx::Class::Row
object and create a fresh Class::Languagetype object from it. A context
must be provided.

Return the Class::Languagetype object, or undef if the Languagetype couldn't be
found.

=cut

# Constructor
sub new
{
  my $class		= shift;
  my $dbic		= shift;
  my $arg_language_code	= shift;

  my $m = "C::Languagetype->new";

  my $row    = $arg_language_code;

  unless ( ref($arg_language_code) )
  {
    $arg_language_code = unxss($arg_language_code);
    if ($arg_language_code)
    {
      my $rs_language = $dbic->resultset('Languagetype');
      $row	  = $rs_language->find($arg_language_code);
    }
  }

  return (undef)
    unless $row;

  my $self			= bless( {}, $class );
  $self->{languagetype_dbrecord}	= $row;

  return $self;
}

=item B<dbrecord()>

Return the DBIx::Class::Row object for this language.

=cut
# Get the database object
sub dbrecord
{
  my
    $self = shift;
  return( $self->{languagetype_dbrecord} );
}

=back

=head1 ACCESSORS

=over

=item B<language_code()>

Get/set the language code.  Alias for the database field.

=cut
sub language_code
{
  my
    $self = shift;
  my $language_code = shift;

  $language_code = unxss($language_code);
  $self->language_dbrecord->code( $language_code )
    if defined( $language_code );

  return( $self->language_dbrecord->code );
}

=back

1;

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
AGPLv3. Copyright tirveni@udyansh.org

=cut
