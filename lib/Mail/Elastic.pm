#!/usr/bin/perl -w
#
# Mail/Elastic
#
# Tirveni Yadav, tirveni@udyansh.org
# To send mail through Elastice API
#

package Mail::Elastic;

use strict;

use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use TryCatch;
use JSON qw/from_json/;

use Class::Rock;

my ($API_SERVER,$USERNAME,$API_KEY,$API_URI,$API_URL);
{
  $USERNAME	= $Class::Rock::elastic_api_username;
  $API_KEY	= $Class::Rock::elastic_api_key;

  ##These Are standard Stuff
  $API_SERVER	= 'api.elasticemail.com';
  #$API_URI	= '/mailer/send';
  $API_URI	= '/v2/email/send';	##New URL
  $API_URL	= 'https://'.$API_SERVER.$API_URI;
}


=head1 NAME

Mail::Elastic - Utility methods for sending e-mail through Elastice API

=head1 SYNOPSIS

	Mail::Elastic::send(Mail::Letter);

=head1 DESCRIPTION

Uses Credentials from Class::Rock

http://elasticemail.com/api-documentation/send


=head2 send($o_letter)

Arguments: $o_letter

More doc is here for ElasticEmail:
 http://elasticemail.com/api-documentation/send

Returns: ($o_http_response,$hashref_response,$is_success);

hash Response	  {error,success,data{messageid,transactionid}}


=cut

sub send
{
  my $o_letter = shift;

  my $fn = "Mail/Elastic/sendElasticEmail";
  if(!$o_letter)
  {
    return;
  }

  my $from	= $o_letter->from;
  my $to	= $o_letter->to;
  my $subject	= $o_letter->subject;
  my $body_html	= $o_letter->body;
  my $body_txt	= $o_letter->body;


  ##--1. Create Request
  my $ua = LWP::UserAgent->new;
  my $req = POST $API_URL,
    [
     username	=> $USERNAME,
     api_key	=> $API_KEY,
     subject	=> $subject,
     from	=> $from,
     to		=> $to,
     body_html	=> $body_html,
     body_text	=> $body_txt
    ];

  my ($o_http_response,$request,$is_success,$http_response_code,
      $str_response,$res_content);

  ## --2. Dispacth the Request,
  ##$o_http_response = $ua->request($req)->as_string;
  $o_http_response = $ua->request($req);
  ##print "$fn  Response: $o_http_response  \n";


  ## --3. Response Content
  if ($o_http_response)
  {
    $http_response_code = $o_http_response->code();
    #$str_response = $o_http_response->as_string();
    $res_content	 = $o_http_response->content();
  }

  ##---4. Response Data
  my ($h_rsx,$data_messageid,$res_success,
      $data_txnid,$res_error);
  if ($res_content)
  {
    $h_rsx		= from_json( $res_content);
    $data_messageid	= $h_rsx->{data}->{messageid};
    $data_txnid		= $h_rsx->{data}->{transactionid};
    $res_error		= $h_rsx->{error};
    $res_success		= $h_rsx->{success};
    #print "$fn Msg:$data_messageid,txnid:$data_txnid  \n";
    #print "$fn Success:$res_success  \n";
  }

  ##---5. Response Success: True/False
  if ($http_response_code == 200 && $res_success eq 'true')
  {
    $is_success = 1;
    #print "$fn  Success: $is_success,Code:$http_response_code  \n";
  } else
  {
    print "$fn $http_response_code $res_error \n";
  }

  return ($o_http_response,$h_rsx,$is_success);

}


=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as AGPLv3 itself.

=cut


1;

#Success Content From Elastice:
#{"success":true,"data":{"transactionid":"9d0cf1d6-123-4342-3434c-a334","messageid":"nfp3oF8CjrMhPHqQ7Rstqg2"}}
#
#Failure content from Elastice:{"success":false,"error":"Incorrect apikey"} 
#
#send('info@xyz.io','abc@def.com','Test: 2018-01-31','My HTML','My TXT');
#
#
# HTTP/1.1 200 OK
#Cache-Control: private
#Date: Sun, 20 Mar 2015 14:10:22 GMT
#Server: Microsoft-IIS/8.5
#Content-Length: 36
#Content-Type: text/html; charset=utf-8
#Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept
#Access-Control-Allow-Origin: *
#Client-Date: Sun, 20 Mar 2016 14:10:21 GMT
#Client-Peer: 46.105.88.234:80
#Client-Response-Num: 1
#X-AspNet-Version: 4.x.30319
#X-Powered-By: ASP.NET

#534f1347c-818a-4146-a5e2-2b6a83f3x0d5


