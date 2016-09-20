use strict;
use warnings;

use Taipan;

my $app = Taipan->apply_default_middlewares(Taipan->psgi_app);
$app;

