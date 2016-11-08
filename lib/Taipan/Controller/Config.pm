package Taipan::Controller::Config;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use Class::Utils	qw(makeparm unxss trim);
use Class::General	qw(paginationx);

my ($c_rows_per_page);
{
  $c_rows_per_page = 10;
}


=head1 NAME

Taipan::Controller::Config - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 config/ index

=cut

sub index :Path :Args(3)
{
  my $self	  = shift;
  my $c		  = shift;
  my $dtable	  = shift;
  my $tableuniq	  = shift;
  my $cfield      = shift;

  my $fn = "Config/index";
  $c->stash->{page} = {'title' => 'List Privilege',};
  $c->stash->{template} = 'src/configs/edit.tt';

  my $dbic = $c->model('TDB')->schema;
  my $o_tval = Class::Tvals->new($dbic,$dtable,$tableuniq,$cfield);

  if (!$o_tval)
  {
    $c->res->redirect( $c->uri_for('/') );
    $c->detach();
  }

  my ($cvalue,$valid,$value2,$value3,$value4,$value5,$value6,$priority);
  ##-- Form Input
  {
    my $aparams	= $c->req->params;

    $cvalue	= $aparams->{cvalue};

    $value2	= $aparams->{value2};
    $value3	= $aparams->{value3};
    $value4	= $aparams->{value4};
    $value5	= $aparams->{value5};
    $value6	= $aparams->{value6};
    $priority	= int($aparams->{priority});

    ##Either True/False
    $valid		= 0;
    my $in_valid	= $aparams->{valid};
    $valid		= 1 if($in_valid);
  }

  ##-- Update
  if ($cvalue)
  {


  }


  ##-- Display
  my $h_vals;
  {

    ##Already in URL
    $h_vals->{dtable}	= $dtable;
    $h_vals->{tableuniq}	= $tableuniq;
    $h_vals->{cfield}	= $cfield;


    $h_vals->{cvalue}	= $o_tval->cvalue;
    $h_vals->{ctype}	= $o_tval->ctype;

    $h_vals->{priority}	= $o_tval->priority;
    $h_vals->{valid}	= $o_tval->valid;


    $h_vals->{field2}	= $o_tval->field2;
    $h_vals->{field3}	= $o_tval->field3;
    $h_vals->{field4}	= $o_tval->field4;
    $h_vals->{field5}	= $o_tval->field5;
    $h_vals->{field6}	= $o_tval->field6;

    $h_vals->{value2}	= $o_tval->value2;
    $h_vals->{value3}	= $o_tval->value3;
    $h_vals->{value4}	= $o_tval->value4;
    $h_vals->{value5}	= $o_tval->value5;
    $h_vals->{value6}	= $o_tval->value6;

    $c->stash->{tval} = $h_vals;
  }

}

=head2 config/list

=cut

sub list :Path('/config/list') :ChainedArgs(0)
{
  my $self		= shift;
  my $c			= shift;
  my $startpage		= shift;
  my $desired_page      = shift;

  my $dbic = $c->model('TDB')->schema;

  my $configlistsearchterm = $c->session->{'Configsearchterm'};
  $c->log->error("Page $desired_page");
  $c->stash->{page} = {'title' => 'List Configurations',};

  my $total;

  if ( !defined($configlistsearchterm) ) # All privileges
  {
    $configlistsearchterm = [
				undef,
				{
				 order_by => [qw(tableuniq cfield)],
				 rows     => $c_rows_per_page,
				}
			       ];

    $c->session->{Configlistsearchterm} = $configlistsearchterm;
  }

  my $rs_typevalues;

  #Table Privilege
  {
    my $table_tvals =   $dbic->resultset('Typevalue')->search({});

    ##-- Ordering
    my @order_list = [qw(tableuniq cfield)];


    my %page_attribs;
    %page_attribs = (
		     desiredpage  => $desired_page,
		     startpage    => $startpage,
		     inputsearch  => $configlistsearchterm,
		     rowsperpage  => $c_rows_per_page,
		     order	  => \@order_list,
		     listname     => 'Configurations',
		     namefn       => 'list',
		     nameclass    => 'config',
		    );

    ##
    $rs_typevalues =  paginationx( $c, \%page_attribs, $table_tvals );
  }

  my @list = ();

  while ( my $row_tv = $rs_typevalues->next() )
  {
    my $dtable		= trim($row_tv->dtable);
    my $cfield		= trim($row_tv->cfield);
    my $tableuniq	= trim($row_tv->tableuniq);

    my $cvalue		= $row_tv->cvalue;
    my $ctype		= $row_tv->ctype;
    my $description	= $row_tv->description || 'N/A';

    my $internal	= $row_tv->internal;
    my $valid		= $row_tv->valid;

    push(
	 @list,
	 {
	  dtable	=> $dtable,
	  tableuniq	=> $tableuniq,
	  cfield	=> $cfield,
	  cvalue	=> $cvalue,
	  description	=> $description,
	  internal	=> $internal,
	  valid		=> $valid,
	 }
	);
  }

  $c->stash->{clist} = \@list;

  $c->stash->{template} = 'src/configs/list.tt';
}



=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
