use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Taipan';
use Taipan::Controller::Config;

ok( request('/config')->is_success, 'Request should succeed' );
done_testing();
