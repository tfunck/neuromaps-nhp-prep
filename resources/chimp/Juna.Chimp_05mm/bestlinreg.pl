#! /usr/bin/env perl
#
# Linear fitting using parameters optimised by Claude Lepage.
#
# The best way to run this script is to use -nmi with only the 
# target brain mask applied on the latter fitting stages in 
# reverse mode. The reverse registration itself will compute the 
# transformation from the target to the source, then invert 
# the transformation at the end. This is more stable numerically 
# when the mask is defined on the target (stereotaxic model with
# a known mask), because the lattice for the sampling points 
# will be frozen during registration, thus making the objective 
# function smooth and improving global convergence.
#
# This was greatly inspired by best1stepnlreg.pl by Steve Robbins.
#
# Claude Lepage - claude@bic.mni.mcgill.ca
# Andrew Janke - rotor@cmr.uq.edu.au
# Center for Magnetic Resonance
# The University of Queensland
# http://www.cmr.uq.edu.au/~rotor
#
# Copyright Alan C. Evans
# Professor of Neurology
# McGill University
#

use strict;
use warnings "all";
use Getopt::Tabular;
use File::Basename;
use File::Temp qw/ tempdir /;

my @conf = (

   { type        => "blur",       # -lsq6 (or -lsq7 scaling 
     blur_fwhm   => 16,           # for small head size)
     steps       => 8,
     iterations  => 400,
     tolerance   => 0.00001,
     simplex     => 24,           # no need for 32 with initial translation
     direction   => "forward" },

   { type        => "blur",       # -lsq7 scaling (start slowly)
     blur_fwhm   => 8,
     steps       => 8,
     iterations  => 400,
     tolerance   => 0.00001,
     simplex     => 16,
     direction   => "forward" },

   { type        => "blur",       # maximum -lsq9
     blur_fwhm   => 8,
     steps       => 4,
     iterations  => 400,
     tolerance   => 0.00001,
     simplex     => 16,
     direction   => "forward" },

   { type        => "blur",       # -lsqXX full options
     blur_fwhm   => 8,
     steps       => 4,
     iterations  => 500,
     tolerance   => 0.00001,
     simplex     => 12,             # was 16
     direction   => "forward" },

   { type        => "blur",
     blur_fwhm   => 4,
     steps       => 4,
     iterations  => 600,
     tolerance   => 0.000001,
     simplex     => 6,               # was 8
     direction   => "reverse" },

   { type        => "blur",
     blur_fwhm   => 2,
     steps       => 2,
     iterations  => 1000,
     tolerance   => 0.0000001,
     simplex     => 2,               # was 4
     direction   => "reverse" }
   );


my($Help, $Usage, $me);
my(@opt_table, %opt, $source, $target, $outxfm, $outfile, @args, $tmpdir);

$me = &basename($0);
%opt = (
   'verbose'   => 1,
   'debug'     => 0,
   'clobber'   => 0,
   'fake'      => 0,
   'init_xfm'  => undef,
   'source_mask' => undef,
   'target_mask' => undef,
   'scale'       => 1,
   'lsqtype'     => "-lsq9",
   'objective'   => "-xcorr"
   );

$Help = <<HELP;
| $me does hierachial linear fitting between two files.
|    you will have to edit the script itself to modify the
|    fitting levels themselves
| 
| Problems or comments should be sent to: claude\@bic.mni.mcgill.ca
HELP

$Usage = "Usage: $me [options] source.mnc target.mnc output.xfm [output.mnc]\n".
         "       $me -help to list options\n\n";

@opt_table = (
   ["-verbose", "boolean", 0, \$opt{verbose},
      "be verbose" ],
   ["-debug", "boolean", 0, \$opt{debug},
      "save final objective function at end of each cycle (slow)" ],
   ["-clobber", "boolean", 0, \$opt{clobber},
      "clobber existing check files" ],
   ["-fake", "boolean", 0, \$opt{fake},
      "do a dry run, (echo cmds only)" ],
   ["-init_xfm", "string", 1, \$opt{init_xfm},
      "initial transformation from source to target [default identity]" ],
   ["-source_mask", "string", 1, \$opt{source_mask},
      "source mask to use during fitting (on last stage only)" ],
   ["-target_mask", "string", 1, \$opt{target_mask},
      "target mask to use during fitting (on last stage only)" ],
   ["-scale", "string", 1, \$opt{scale},
      "scaling factor relative to human brain size (eg. 0.4 for macaque)" ],
   ["-lsq6", "const", "-lsq6", \$opt{lsqtype},
      "use 6-parameter transformation" ],
   ["-lsq7", "const", "-lsq7", \$opt{lsqtype},
      "use 7-parameter transformation" ],
   ["-lsq9", "const", "-lsq9", \$opt{lsqtype},
      "use 9-parameter transformation [default]" ],
   ["-lsq12", "const", "-lsq12", \$opt{lsqtype},
      "use 12-parameter transformation" ],
   ["-mi", "const", "-mi", \$opt{objective},
      "use mutual information as objective function [default -xcorr]" ],
   ["-nmi", "const", "-nmi", \$opt{objective},
      "use normalized mutual information as objective function [default -xcorr]" ]
   );

# Check arguments
&Getopt::Tabular::SetHelp($Help, $Usage);
&GetOptions (\@opt_table, \@ARGV) || exit 1;
die $Usage if(! ($#ARGV == 2 || $#ARGV == 3));
$source = shift(@ARGV);
$target = shift(@ARGV);
$outxfm = shift(@ARGV);
$outfile = (defined($ARGV[0])) ? shift(@ARGV) : undef;

# check for files
die "$me: Couldn't find input file: $source\n\n" if (!-e $source);
die "$me: Couldn't find input file: $target\n\n" if (!-e $target);
if(-e $outxfm && !$opt{clobber}){
   die "$me: $outxfm exists, -clobber to overwrite\n\n";
   }
if(defined($outfile) && -e $outfile && !$opt{clobber}){
   die "$me: $outfile exists, -clobber to overwrite\n\n";
}

# make tmpdir
$tmpdir = &tempdir( "$me-XXXXXXXX", TMPDIR => 1, CLEANUP => 1 );

# set up filename base
my($i, $s_base, $t_base, $tmp_xfm, $tmp_source, $tmp_target, $prev_xfm);
$s_base = &basename($source);
$s_base =~ s/\.mnc(.gz)?$//;
$s_base = "S${s_base}";
$t_base = &basename($target);
$t_base =~ s/\.mnc(.gz)?$//;
$t_base = "T${t_base}";

# Make sure that the masks are resampled exactly like the source and the target.

if( defined($opt{source_mask}) ) {
  &do_cmd( 'resample_labels', '-quiet', '-clobber', '-trilinear', '-nobinary',
           '-resample', "-like $source", $opt{source_mask},
           "${tmpdir}/${s_base}_mask.mnc" );
  $opt{source_mask} = "${tmpdir}/${s_base}_mask.mnc";
}
if( defined($opt{target_mask}) ) {
  &do_cmd( 'resample_labels', '-quiet', '-clobber', '-trilinear', '-nobinary',
           '-resample', "-like $target", $opt{target_mask},
           "${tmpdir}/${t_base}_mask.mnc" );
  $opt{target_mask} = "${tmpdir}/${t_base}_mask.mnc";
}

# Mask the source and target once before blurring if both masks exist.
# These masked images are only used in the early stages to get the registration
# started. On the final stages, only the model's mask is used on the unmasked
# image.

my $source_masked = $source;
my $target_masked = $target;

# Definition of the initial transformation. 
#   case 1: initial transformation supplied by the user
#   case 2: centering of the image first based on the (masked) 
#           center of mass, followed by scaling if there is a
#           mask for both source and target. Somehow, I think 
#           that minctracc should be able to do this on its own.

if( defined $opt{init_xfm} && -e $opt{init_xfm} ) {
  $prev_xfm = $opt{init_xfm};
} else {
  my $command = "mincstats -quiet $source ";
  if( defined( $opt{source_mask} ) ) {
    $command .= "-mask $opt{source_mask} -mask_floor 0.5";
  }
  # Note: The disadvantage of using -com below is the limited number
  # of decimal places. This breaks the symmetry in the transformation
  # if the volumes are symmetric.

  my ($sxc,$syc,$szc) = split( ' ', `$command -com -world_only` );
  my $svol = `$command -volume`; chomp( $svol );

  $command = "mincstats -quiet $target ";
  if( defined( $opt{target_mask} ) ) {
    $command .= "-mask $opt{target_mask} -mask_floor 0.5";
  }
  my ($txc,$tyc,$tzc) = split( ' ', `$command -com -world_only` );
  my $tvol = `$command -volume`; chomp( $tvol );

  # The scale is applied only if both masks exists.
  my $scale = 1.0;
  if( defined( $opt{source_mask} ) && defined( $opt{target_mask} ) ) {
    $scale = ( $tvol / $svol ) ** ( 1.0 / 3.0 );
    print "3D scale is $scale\n";
  }

  my $dx = $txc - $sxc;
  my $dy = $tyc - $syc;
  my $dz = $tzc - $szc;
  my $trans_xfm = "${tmpdir}/${s_base}_trans.xfm";
  my $scale_xfm = "${tmpdir}/${s_base}_scale.xfm";

  `param2xfm -clobber -translation $dx $dy $dz $trans_xfm`;
  `param2xfm -clobber -scales $scale $scale $scale $scale_xfm`;

  $prev_xfm = "${tmpdir}/${s_base}_init.xfm";
  `xfmconcat -clobber $trans_xfm $scale_xfm $prev_xfm`;
  unlink( $trans_xfm );
  unlink( $scale_xfm );
}

# a fitting we shall go...
for ($i=0; $i<=$#conf; $i++){

  $conf[$i]{blur_fwhm} *= $opt{scale};
  $conf[$i]{steps} *= $opt{scale};
  $conf[$i]{simplex} *= $opt{scale};

   # remove blurred image at previous iteration, if no longer needed.
   if( $i > 0 ) {
     if( $conf[$i]{blur_fwhm} != $conf[$i-1]{blur_fwhm} ) {
       unlink( "$tmp_source\_blur.mnc" ) if( -e "$tmp_source\_blur.mnc" );
       unlink( "$tmp_target\_blur.mnc" ) if( -e "$tmp_target\_blur.mnc" );
       unlink( "$tmp_source\_dxyz.mnc" ) if( -e "$tmp_source\_dxyz.mnc" );
       unlink( "$tmp_target\_dxyz.mnc" ) if( -e "$tmp_target\_dxyz.mnc" );
     }
   }
   
   # set up intermediate files
   $tmp_xfm = "$tmpdir/$s_base\_$i.xfm";
   $tmp_source = "$tmpdir/$s_base\_$conf[$i]{blur_fwhm}";
   $tmp_target = "$tmpdir/$t_base\_$conf[$i]{blur_fwhm}";
   
   print STDOUT "-+-------------------------[$i]-------------------------\n".
                " | steps:          $conf[$i]{steps}\n".
                " | blur_fwhm:      $conf[$i]{blur_fwhm}\n".
                " | simplex:        $conf[$i]{simplex}\n".
                " | iterations:     $conf[$i]{iterations}\n".
                " | tolerance:      $conf[$i]{tolerance}\n".
                " | source:         $tmp_source\_$conf[$i]{type}.mnc\n".
                " | target:         $tmp_target\_$conf[$i]{type}.mnc\n".
                " | xfm:            $tmp_xfm\n".
                "-+-----------------------------------------------------\n".
                "\n";
   
   # blur the source and target images
 
   my @gradient = ();
   push @gradient, '-gradient' if( $conf[$i]{type} eq "dxyz" );

   # in reverse mode, always use the full image; otherwise, use whatever has
   # been prescribed earlier.

   my $source_input = ( $conf[$i]{direction} eq "reverse" ) ? $source : $source_masked;
   my $target_input = ( $conf[$i]{direction} eq "reverse" ) ? $target : $target_masked;

   if(!-e "$tmp_source\_$conf[$i]{type}.mnc") {
     if( $conf[$i]{blur_fwhm} > 0 ) {
       &do_cmd( 'mincblur', '-quiet', '-clobber', '-no_apodize', '-fwhm', 
                $conf[$i]{blur_fwhm}, @gradient, $source_input, $tmp_source );
     }
   }
   if(!-e "$tmp_target\_$conf[$i]{type}.mnc") {
     if( $conf[$i]{blur_fwhm} > 0 ) {
       &do_cmd( 'mincblur', '-quiet', '-clobber', '-no_apodize', '-fwhm', 
                $conf[$i]{blur_fwhm}, @gradient, $target_input, $tmp_target );
     }
   }

   my $lattice = ( $conf[$i]{direction} eq "forward" ) ? 
                 "-model_lattice" : "-source_lattice";

   # Determine optimal number of parameters without an initial transformation.
   # First cycle: lsq6 (no mask), lsq7 (with both masks)
   # Second cycle: maximum lsq7
   # Third cycle: maximum lsq9
   # Other cycles: as specified by the user
   # In all cases, don't use more parameters than requested by the user.
   # In the case when an initial transformation is supplied, use the number
   # of parameters requested by the user.

   my $lsq = $opt{lsqtype};
   if( !( defined $opt{init_xfm} && -e $opt{init_xfm} ) ) {
     if( $i == 0 ) {
       $lsq = "-lsq6";
       if( defined($opt{source_mask}) and defined($opt{target_mask}) and
           -e $opt{source_mask} and -e $opt{target_mask} ) {
         $lsq = "-lsq7" unless( $opt{lsqtype} eq "-lsq6" );
       }
     } else {
       if( $i == 1 ) {
         $lsq = "-lsq7" unless( $opt{lsqtype} eq "-lsq6" );
       } else {
         if( $i == 2 ) {
           $lsq = "-lsq9" if( $opt{lsqtype} eq "-lsq12" );
         }
       }
     }
   }

   # set up registration
   @args = ('minctracc', '-clobber', $opt{objective}, $lsq,
            '-step', $conf[$i]{steps}, $conf[$i]{steps}, $conf[$i]{steps},
            '-simplex', $conf[$i]{simplex}, $lattice,
            '-tol', $conf[$i]{tolerance} );
            ### '-linear_iterations', $conf[$i]{iterations} );

   # allow for greater head rotation about x-axis. 
   # Note: this is very brain-specific. Could be dangerous in general.
   push( @args, '-w_rotations', 0.05, 0.0174533, 0.0174533 );
   if( $conf[$i]{direction} eq "reverse" ) {
     push( @args, '-w_scales', 0.01, 0.01, 0.01 );
   }

   # Apply the current transformation at this step.
   if( defined $prev_xfm ) {
     if( $conf[$i]{direction} eq "reverse" ) {
       &do_cmd( 'xfminvert', '-clobber', $prev_xfm, "${tmpdir}/${s_base}_inv.xfm" );
       $prev_xfm = "${tmpdir}/${s_base}_inv.xfm";
     }
     push(@args, '-transformation', $prev_xfm );
   } else {
     # Initial transformation will be computed from the from Principal axis 
     # transformation (PAT). This case should never happen.
     push(@args, '-est_translations' );
   }

   if( $opt{debug} ) {
     push(@args, '-debug', '-verbose', 5 );
   }

   # Up to CIVET-2.1.0, the target mask was used on last cycle only. 
   # Now, we appply masking differently.
   # The target mask causes oscillations in the objective functions on 
   # latter stages with small steps since voxels along the border of 
   # the mask can be on/off. With large steps, the sampling points are
   # mostly the same since the small displacements in the sampling
   # points are contained within the width of the steps. With small
   # steps, the small displacements become larger relative to the
   # step size and the set of sampling points inside the mask start
   # to vary from trial to trial, iteration to iteration. This results 
   # in the objective function not being smooth. With oscillations in 
   # the objective function, we observe slower convergence, or no 
   # convergence at all. 
   # After investigation, it was discovered that using the source mask
   # yields a smooth objective function with great convergence properties.
   # This is because the number of sampling points on the lattice remains
   # the same during optimization. Great! Since the source mask is not 
   # always known, or reliable, we perform the registration in reverse 
   # order, from target to source, then invert the final transformation. 
   # The source will be the model with a well-defined mask and the target 
   # will be the subject, without a mask. The registration is performed
   # in reverse mode only on the latter stages. On the early stages, it
   # is performed in the forward direction, without an explicit mask.
   # No mask early on is better to sample the full field of view and
   # increase "attraction". At end, the final transformation is inverted
   # to represent the direction source to target. CL.

   # The mask on the model is applied only in "reverse" mode and on 
   # the last cycle. Beware of the flipped definition of the masks 
   # and input volumes in "reverse" mode.

   my @file_options = ();
   if( $conf[$i]{direction} eq "forward" ) {
     if( defined( $opt{target_mask} ) && ( $i == $#conf ) ) {
       push(@file_options, '-model_mask', $opt{target_mask});
     }
     if( $conf[$i]{blur_fwhm} > 0 ) {
       push(@file_options, "$tmp_source\_$conf[$i]{type}.mnc", 
                           "$tmp_target\_$conf[$i]{type}.mnc" );
     } else {
       push( @file_options, $source_input );
     }
   } else {
     if( defined( $opt{target_mask} ) ) {
       push(@file_options, '-source_mask', $opt{target_mask});
     }
     if( $conf[$i]{blur_fwhm} > 0 ) {
       push(@file_options, "$tmp_target\_$conf[$i]{type}.mnc", 
                           "$tmp_source\_$conf[$i]{type}.mnc" );
     } else {
       push( @file_options, $target_input );
     }
   }
   push @args, @file_options;
   push @args, $tmp_xfm;
   
   &do_cmd(@args);

   # Save debug information for objective function at the end of this cycle.

   if( $opt{debug} ) {
     my $costfile = $outxfm;
     $costfile =~ s/\.xfm/_objective${i}.dat/;

     &do_cmd( 'minctracc', '-clobber', $opt{objective}, $opt{lsqtype},
              '-step', $conf[$i]{steps}, $conf[$i]{steps}, $conf[$i]{steps},
              '-simplex', $conf[$i]{simplex}, $lattice, 
              '-transformation', $tmp_xfm, '-num_steps', 50, @file_options,
              '-matlab', $costfile );

     $costfile = $outfile;
     $costfile =~ s/\.mnc/_rsl${i}.mnc/;

     if( $conf[$i]{direction} eq "forward" ) {
       &do_cmd( 'mincresample', '-quiet', '-clobber', '-like', $target,
                '-transformation', $tmp_xfm, $source, $costfile );
     } else {
       &do_cmd( 'mincresample', '-quiet', '-clobber', '-like', $target,
                '-transformation', $tmp_xfm, '-invert', $source, $costfile );
     }
   }

   if( $conf[$i]{direction} eq "reverse" ) {
     &do_cmd( 'xfminvert', '-clobber', $tmp_xfm, $tmp_xfm );
   }

   # remove previous xfm to keep tmpdir usage to a minimum.
   # (not really necessary for a linear xfm - file is small.)
   if($i > 0) {
     unlink( $prev_xfm );
   }
   
   $prev_xfm = $tmp_xfm;
}

&do_cmd( 'cp', '-f', $prev_xfm, $outxfm );  ## don't use mv for Linux group ID issue
unlink( $prev_xfm );

# resample if required
if(defined($outfile)){
   print STDOUT "-+- creating $outfile using $outxfm\n".
   &do_cmd( 'mincresample', '-quiet', '-clobber', '-like', $target,
            '-transformation', $outxfm, $source, $outfile );
}


sub do_cmd { 
   print STDOUT "@_\n" if $opt{verbose};
   if(!$opt{fake}){
      system(@_) == 0 or die;
   }
}

