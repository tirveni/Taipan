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


use Class::Utils qw(today now trim unxss valid_date push_errors print_errors);


our $VERSION = "1.01";

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

  my $m = "C/pagestatic->new";

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

=head1 ACCESSORS

=head2 pageid

get Pageid of the Pagestatic

=cut

sub pageid
{
  my $self = shift;

  #Return the PageID
  my $r_articleid = $self->dbrecord->get_column('pageid');

  return $r_articleid;

}

=head2 pagename

get pagename of the Pagestatic

=cut

sub pagename
{
  my $self = shift;

  #Return the pagename
  my $r_articleid = $self->dbrecord->get_column('pagename');

  return $r_articleid;

}

=head1 CONTENT

Content of the Page

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

=head2 content_edit($content,$userid)

Returns: updated_row

=cut

sub content_edit
{
  my $self	= shift;
  my $input	= shift;
  my $userid	= shift;

  my $row_ps = $self->dbrecord;

  my $h_edit;
  $h_edit->{content} = $input;
  $h_edit->{update_userid} = $userid;

  my $updated_row;
  if (defined($row_ps) && $input && $userid)
  {
    $updated_row = $row_ps->update($h_edit);
  }

  return $updated_row;
}

=head1 tags

Manges Tags

TagsOfPage: meta-desc, meta-keywords

=head atag(tag_type,priority)

Returns: $row_tag

=cut

sub atag
{
  my $self = shift;
  my $tag_type	= shift;
  my $priority	= shift;

  ##
  my $row_page	 = $self->dbrecord;
  my ($errors);

  $priority = int($priority);
  my ($h_edit,$row_tag,$ready_up);

  ##-- 1. Desc Type
  if (defined($row_page))
  {
    $row_tag = $row_page->find_related
      ('tagsofpages',
       {
	tagtype  => $tag_type,
	priority => $priority,
       },
      );
  }

  return $row_tag;

}

=head2 tags($dbic)

Get Tags of PageStatic

Returns: Hash{meta-desc(text),meta-keywords(array)}

{meta-desc=>description,meta-keywords=>\[description]}

Priority Descending.

=cut

sub tags
{
  my $self	= shift;
  my $dbic	= shift;

  my $h_vals;
  my $row_page	= $self->dbrecord;

  my $m = "C/pagestatic->tags";
  my $meta_str_1 = 'meta-desc';
  my $meta_str_2 = 'meta-keywords';

  ##Meta desc
  my @order = ('priority desc');
  my $rs_tags_desc;

  ##--- 1A Get the RS Tags
  ##--- Search Tags of Pages Type: Desc
  {
    $rs_tags_desc = $row_page->search_related
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
  if (defined($rs_tags_desc))
  {
    my $row_tag = $rs_tags_desc->first;
    my $meta_desc_str;
    if (defined($row_tag))
    {
      $meta_desc_str		= $row_tag->details;
    }
    $h_vals->{$meta_str_1}	= $meta_desc_str;
  }



  my $rs_tags_meta;

  ##--- 2A Meta: Other Metas
  ##--- Search Tags of Pages Type: Other than Desc
  {

    ##Meta (Only)
    $rs_tags_meta = $row_page->search_related
      ('tagsofpages',
       {
	tagtype  => $meta_str_2,
       }
      );
  }

  ##--- 2B: Put the data in the List, then array
  if (defined($rs_tags_meta))
  {
    my @list;
    while ( my $tag = $rs_tags_meta->next )
    {

      my $content = $tag->details;
      push(@list,$content);
    }

    $h_vals->{$meta_str_2} = \@list;

  }

  return $h_vals;

}

=head2 tag_edit($type,$priority,h_edit)

h_edit: {priority,details,userid}

Return: ($errors,$updated_row)

Used for Editing or Creating

=cut

sub tag_edit
{
  my $self	= shift;
  my $tag_type	= shift;
  my $in_vals	= shift;
  my $priority	= shift;

  my $m = "C/pagestatic->tag_edit";

  ##only these types are edited.
  my $meta_str_1 = 'meta-desc';
  my $meta_str_2 = 'meta-keywords';

  ##Check TagType  my $

  ##
  my $row_page	 = $self->dbrecord;
  my ($errors,$updated_row);

  $priority = int($priority) || 1;
  $tag_type = trim($tag_type);
  my ($h_edit,$row_tag,$ready_up);
  print "$m Input Tag: $tag_type \n";

  ##-- 1. Desc Type
  if (defined($row_page) && ($tag_type eq $meta_str_1))
  {
    $row_tag = $self->atag($meta_str_1,1);

    $h_edit->{details}		= $in_vals->{details};
    $h_edit->{update_userid}	= $in_vals->{userid};
    $h_edit->{priority}		= 1;
    $ready_up = 1;
    print "$m Found:$meta_str_1,$priority,$row_tag \n";


  }##IF Tag Type One
  else
  {
    $row_tag = $self->atag($meta_str_2,$priority);
    print "$m Found:$meta_str_2,$priority,$row_tag \n";

    $h_edit->{details}		= $in_vals->{details};
    $h_edit->{update_userid}	= $in_vals->{userid};
    $h_edit->{priority}		= $priority;
    $ready_up = 1;
  }##Else Tag Type

  my $err_msg;
  try  {

    if ($row_tag && $ready_up > 0)
    {
      $updated_row = $row_tag->update($h_edit);
      print "$m Update \n";

    }
    elsif ($ready_up > 0)
    {
      $h_edit->{tagtype} = $tag_type;
      $updated_row = $row_page->create_related('tagsofpages',$h_edit);
      print "$m Create \n";
    }

  }
    catch($err_msg)
    {
      push(@$errors,$err_msg);
      print "$m $err_msg \n";
    }  ;


  return ($errors,$updated_row);
}


=head2 types_tags($dbic [,in_type])

returns: \@list

{type,description}

=cut

sub types_tags
{
  my $dbic	= shift;
  my $in_type	= shift;

  $in_type = trim($in_type) if($in_type);

  my $rs_tt = $dbic->resultset('Tagtype');

  my @list;

  while (my $row = $rs_tt->next())
  {
    my $type		= $row->tagtype;
    my $description	= $row->description;

    push(@list,
	 {
	  type		=> $type,
	  description	=> $description,
	 },
	);

  }

  return \@list;

}


=head1 AUTHOR

Tirveni Yadav,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as AGPLv3 itself.

=cut

1;
