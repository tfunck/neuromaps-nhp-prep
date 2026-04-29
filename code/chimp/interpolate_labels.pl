#!/usr/bin/env perl

use warnings "all";
use strict;
use File::Temp qw/ tempdir /;


my $labels = shift;            # defined on target_sphere
my $source_sphere = shift;
my $target_sphere = shift;
my $smap = shift;
my $output = shift;

my $tmpdir = &tempdir( "interpolate_labels-XXXXXX", TMPDIR => 1, CLEANUP => 1 );

# this gets rid of nagging leading spaces in the first column
my $labels_tmp = "${tmpdir}/labels_tmp.txt";
`vertstats_math -old -const 1 -mult $labels $labels_tmp`;

my @ret = `sort -u -n $labels_tmp`;
my $first = $ret[0];
chomp( $first );

my $offset = $first == 0 ? 1 : 0;

my $count = "${tmpdir}/labels_count.txt";
my $total = "${tmpdir}/labels_total.txt";
unlink( $count ) if( -e $count );
unlink( $total ) if( -e $total );

foreach my $ii ( @ret ) {
  chomp( $ii );
  print "Processing label $ii...\n";

  my $file = "${tmpdir}/label_${ii}.txt";
  my $low = $ii - 0.5;
  my $hi = $ii + 0.5;
  `vertstats_math -old -seg -const2 $low $hi $labels_tmp $file`;
  `surface-resample $source_sphere $target_sphere $file $smap $file`;
  `vertstats_math -old -seg -const2 0.5 1.5 $file $file`;
  if( -e $count ) {
    `vertstats_math -old -add $count $file $count`;
  } else {
    `cp $file $count`;
  }

  my $val = $ii + $offset;
  `vertstats_math -old -mult -const $val $file $file`;
  if( -e $total ) {
    `vertstats_math -old -add $total $file $total`;
  } else {
    `cp $file $total`;
  }
  unlink( $file );
}

`clean_surface_labels $source_sphere $total $total`;  # removes isolated undefined labels (0)

`vertstats_math -old -seg -const2 0.5 1.5 $count $count`;  # keep count=1 (unique labels)
`vertstats_math -old -mult $count $total $output`;
unlink( $total );
unlink( $count );

# Finally, replace any remaining label=0 by nearest neighbour value.
# Danger: if the nearest vertex happens to be zero, this will cause
#         a -1 in the final output in offset=1.
`surface-resample -nearest $source_sphere $target_sphere $labels_tmp $smap ${tmpdir}/nearest.txt`;
if( $offset == 1 ) {
  `vertstats_math -old -const 1 -add ${tmpdir}/nearest.txt ${tmpdir}/nearest.txt`;
}
`vertstats_math -old -seg -const2 -0.5 0.5 $output ${tmpdir}/zero.txt`;
`vertstats_math -old -mult ${tmpdir}/zero.txt ${tmpdir}/nearest.txt ${tmpdir}/nearest.txt`;
`vertstats_math -old -add ${tmpdir}/nearest.txt $output $output`;
if( $offset == 1 ) {
  `vertstats_math -old -const -1 -add $output $output`;   # right here, yes
}

unlink( $labels_tmp );
unlink( "${tmpdir}/zero.txt" );
unlink( "${tmpdir}/nearest.txt" );


