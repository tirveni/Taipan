#!/usr/bin/perl -w
#
# Mail/Letter.pm
#
# Methods for sending e-mail through SMTP/Elastice-API account
#
# SMTP Mail are now HTML compliant.
#
# Tirveni Yadav, tirveni@udyansh.org
#
package Mail::Letter;

use strict;

use Moose;
use namespace::autoclean;

use TryCatch;

use Class::Rock;
use Mail::SMTP qw(send_email);
use Mail::Elastic;


=head1 NAME

Mail::Letter - Utility methods for sending e-mail and SMS.

=head1 SYNOPSIS

    use Mail::Letter;

    $o_letter = Mail::Letter->new({to,subject,from,body[,cc,bcc]});

    $o_letter->send_smtp;
    $o_letter->send_elastic;

=head1 DESCRIPTION

Mail::Letter implements an OO interface for sending e-mail.

Example:

    my $h_mx;
    $h_mx->{to}		= 'ato@example.in';
    $h_mx->{from}	= 'afrom@volans.in';
    $h_mx->{subject}	= 'Lion King subject';
    $h_mx->{body}	= 'Lion Pride';

    my $o_letter	= Mail::Letter->new($h_mx);

    $o_letter->send_elastic or     $o_letter->send_smtp


=head2 new

Store the default SMTP and SMS servers for this installation.

=cut

has to		=>	(is => 'ro',	required => 1);
has subject	=>	(is => 'ro',	required => 1);
has body	=>	(is => 'ro',	required => 1);
has from	=>	(is => 'ro',	required => 1);
has cc		=>	(is => 'ro',	);
has bcc		=>	(is => 'ro',	);

=head2 send_smtp

Send the prepared e-mail .  Return true on success or undef on error.

Uses HTML Mail.

=cut

sub send_smtp
{
  my $self = shift;

  my $m = "Mail/Letter/send_smtp";
  print "$m ::Start $self \n";
  my $is_success;

  try {
    print "$m Sending: Begin  \n";
    $is_success = Mail::SMTP::send_email($self) if($self);
    print "$m Sending: Done  \n";
  }
    catch ($error)
    {
      print "$m Error: $error \n";
    };

  return $is_success;

}

=head2 send_elastic

Send the prepared e-mail or SMS.  Return true on success or undef on
error.

=cut

sub send_elastic
{
  my $self	= shift;

  my $fn = "Mail/Letter/send_elastic";

  my ($o_http_response,$http_code,$is_success,$error);

  try {

    ($o_http_response,$http_code,$is_success) = 
      Mail::Elastic::send($self) if($self);
  }
    catch($error)
    {
      print "$fn Error: $error \n";
    };

  #print "$fn $response  \n";

  return ($o_http_response,$http_code,$is_success);

}


=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as AGPLv3 itself.

=cut


1;
