use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Taipan';
use Taipan::Controller::Staff;

ok( request('/staff')->is_success, 'Request should succeed' );
done_testing();
