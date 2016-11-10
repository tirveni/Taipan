#!/usr/bin/perl -w
#
# Class/Pagestatic.pm

#
#created on 2011-01-13
#Tirveni Yadav
#

package Class::Pagestatic;


use Moose;
use namespace::autoclean;

use TryCatch;

our $VERSION = "1.00";

=head1 Pagestatic

Content of a Static Page.


=head2 new($dbic,$pageid)

Create Pagestatic Object

=cut

sub new
{

  my $class	= shift;
  my $dbic	= shift;
  my $arg_pageid   = shift;

  my $m = "C::Loge->new";

  my $row    = $arg_pageid;

  unless ( ref($arg_pageid) )
  {
    $arg_pageid = unxss($arg_pageid);
    if ($arg_pageid)
    {
      my $rs_logex = $dbic->resultset('Pagestatic');
      $row	   = $rs_logex->find($arg_pageid);
    }
  }

  return (undef)
    unless $row;

  my $self		= bless( {}, $class );
  $self->{ps_dbrecord}	= $row;

  return $self;

}

#END method new

=head2 dbrecord

Return the DBIx::Class::Row object for this Artcile. Get the database object.

=cut

sub dbrecord
{
  my $self = shift;

  return ( $self->{ps_dbrecord} );

}

#End method create

=head2 pageid

get articleid of the Pagestatic

=cut

sub pageid
{
  my $self = shift;

  #Return the name of the Buser
  my $r_articleid = $self->dbrecord->get_column('pageid');

  return $r_articleid;

}

=head2 content

get articleid of the Pagestatic

=cut

sub content
{
  my $self = shift;

  #Return the name of the Buser
  my $r_content = $self->dbrecord->get_column('content');

  return $r_content;

}


=head2 content_lang($dbic [,$in_language])

Get content of the Page

=cut

sub content_lang
{
  my $self    = shift;
  my $dbic = shift;
  my $in_language = shift;

  my $pageid = $self->pageid;
  my $v_content;

  my $row = $dbic->resultset('Pagestaticlang')->find
    (
     {
      pageid		=> $pageid,
      languagetype	=> $in_language,
     }
    ) if($in_language && $pageid);

  if ($row)
  {
    $v_content = $row->get_column('content');
  }
  else
  {
    $v_content = $self->content;
  }

  return $v_content;

}

=head2 tags($dbic)

Get Tags of PageStatic

Returns: Hash{meta-desc-staticpage(text),meta-staticpage(array)}

{meta-desc-staticpage=>description,meta-staticpage=>\[description]}

=cut

sub tags
{
  my $self	= shift;
  my $dbic	= shift;

  my $h_vals;
  my $row_page	= $self->dbrecord;

  my $m = "C/pagestatic->tags";
  my $meta_str_1 = 'meta-desc-staticpage';

  ##Meta desc
  my @order = ('priority desc');
  my $tags_desc_rs;

  ##--- 1A Get the RS Tags
  ##--- Search Tags of Pages Type: Desc
  {
    $tags_desc_rs = $row_page->search_related
      ('tagsofpages',
       {
	tagtype  => $meta_str_1,
       },
       {
	order_by => [@order],
       }
      );
  }

  ##--- 1B Get the Meta Description
  if (defined($tags_desc_rs))
  {
    $tags_desc_rs = $tags_desc_rs->first;
    my $meta_desc_str;
    if ($tags_desc_rs)
    {
      $meta_desc_str		= $tags_desc_rs->details;
    }
    $h_vals->{$meta_str_1}	= $meta_desc_str;
  }


  my $meta_str_2 = 'meta-staticpage';
  my $tags_meta_rs;

  ##--- 2A Meta: Other Metas
  ##--- Search Tags of Pages Type: Other than Desc
  {

    ##Meta (Only)
    my $tags_meta_rs = $row_page->search_related
      ('tagsofpages',
       {
	tagtype  => $meta_str_2,
       }
      );
  }

  ##--- 2B
  {
    my @list;
    while ( my $tag = $tags_meta_rs->next )
    {

      my $content = $tag->details;
      push(@list,$content);
    }

    $h_vals->{$meta_str_2} = \@list;

  }

  return $h_vals;

}


=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as AGPLv3 itself.

=cut

1;
