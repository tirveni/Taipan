#!/usr/bin/perl -w
#
# Mail/SMTP
# Tirveni Yadav, tirveni@udyansh.org
#
# To Send mails through SMTP
#

package Mail::SMTP;

use strict;

use TryCatch;

use Email::MIME::CreateHTML;	##-- Better for HTML
use Email::Sender::Simple	qw(try_to_sendmail sendmail);
use Email::Sender::Transport::SMTP;

use Class::Rock;


##-- SMTP Variable
my ($smtp_server,$smtp_port,$smtp_username,$smtp_password,
    $key_prefix_job_mail);
{
  ##Edit SMTP Settings
  $smtp_server		= $Class::Rock::smtp_server;
  $smtp_port		= $Class::Rock::smtp_port;
  $smtp_username	= $Class::Rock::smtp_username;
  $smtp_password	= $Class::Rock::smtp_password;
};


=head1 NAME

Mail::SMTP - Utility methods for sending e-mail through SMTP

=head1 SYNOPSIS

	send_email(Mail::Letter);

=head1 DESCRIPTION

Uses Email::Sender infrastructure

=head2 send_email($o_letter)

usage: Mail::SMTP::send($o_letter)

Used for Sending Mail through SMTP service

=cut

sub send_email
{
  my $o_letter		= shift;

  my $m = "M/smtp/send";
  my ($o_transport,$o_mail_html,$x_err);

  print "$m $smtp_server/$smtp_port/$smtp_username/$smtp_password \n";

  if (defined($o_letter))
  {
    $o_transport = Email::Sender::Transport::SMTP->new
      ({
	host		=> $smtp_server,
	port		=> $smtp_port,
	sasl_username	=> $smtp_username,
	sasl_password	=> $smtp_password,
       });

    print "$m Creating EMail/Mime \n";
      $o_mail_html = Email::MIME->create_html
	(
	 header => [
		    From => $o_letter->from,
		    To =>   $o_letter->to,
		    Subject => $o_letter->subject,
		   ],
	 body => $o_letter->body,
	);
    print "$m Creating EMail/Mime: $o_mail_html \n";

  }

  my $is_success ;
  print "$m  EM: $o_mail_html / T: $o_transport \n";
  if ($o_mail_html && $o_transport)
  {
    print "$m  Sending Mail \n";
    $is_success = try_to_sendmail($o_mail_html,{transport=>$o_transport});
    print "$m  Success: $is_success  \n";
  }


  my $last_error;

  if ( !defined($is_success) )
  {
    return undef;
  }
  elsif( $@ )
  {
    $last_error = $@;
    return( undef );
  }
  else
  {
    $last_error = '';
    return( 1 );
  }


}


=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as AGPLv3 itself.

=cut



1;
