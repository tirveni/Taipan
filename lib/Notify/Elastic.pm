#!/usr/bin/perl -w
#
# Mail/Elastic
#

package Notify::Elastic;

use strict;

use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use TryCatch;

use Mail::Rock;

my ($API_SERVER,$USERNAME,$API_KEY,$API_URI,$API_URL);
{
  $USERNAME	= $Mail::Rock::elastic_api_username;
  $API_KEY	= $Mail::Rock::elastic_api_key;

  ##These Are standard Stuff
  $API_SERVER	= 'api.elasticemail.com';
  $API_URI	= '/mailer/send';
  $API_URL	= 'https://'.$API_SERVER.$API_URI;
}

##
## http://elasticemail.com/api-documentation/send
##

=head2 sendElasticEmail($from,$to,$subject [,$html_body [,$body_text]])

Arguments: $from,$to,$subject [,$html_body [,$body_text]])

More doc is here for ElasticEmail:
 http://elasticemail.com/api-documentation/send

Usage: sendElasticEmail
('from@test.com','to@target.com','My subject','My HTML','My TXT');

=cut

sub sendElasticEmail
{
	my $from	= shift;
	my $to		= shift;
	my $subject	= shift;
	my $body_html	= shift;
	my $body_txt	= shift;

	my $fn = "Mail/Elastic/sendElasticEmail";

	my $ua = LWP::UserAgent->new;
	my $req = POST $API_URL,
	  [
	   username	=> $USERNAME,
	   api_key	=> $API_KEY,
	   subject	=> $subject,
	   from		=> $from,
	   to		=> $to,
	   body_html	=> $body_html,
	   body_text	=> $body_txt
	  ];

	my ($response,$request);

	##--- Dispacth the REquest,
	$response = $ua->request($req)->as_string;
	print "$fn  Response: $response  \n";

	return $response;

}

1;


#sendElasticEmail  ('info@xyz.io','abc@bbb.com','Test:
# 2016-06-31','My HTML','My TXT');


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

#5eef167c-8d8a-4146-a5e2-2b6a83f8c0d5


