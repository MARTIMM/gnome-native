use v6;

#------------------------------------------------------------------------------
unit class Build;

has Str $!dist-path;

#-------------------------------------------------------------------------------
method build ( Str $!dist-path --> Int ) {

  self!download-install-software;
  self!build-types-conversion-module;

  # return success
  1
}

#-------------------------------------------------------------------------------
method !download-install-software ( ) {

}

#-------------------------------------------------------------------------------
method !build-types-conversion-module ( ) {

  my Bool $run-ok;
  my Hash $c-types = %();

  try {
    my Proc $proc;

    # make C program to get the limits of integers, float and doubles
    $proc = run 'gcc', '-o', 'xbin/c-type-size', 'xbin/c-type-size.c';

    # run C program to read the limits
    $proc = run 'xbin/c-type-size', :out;
    for $proc.out.lines -> $line {
      my ( $limit-name, $limit) = $$line.split(/ \s* ':' \s* /);
      next if $limit-name ~~ m/ MIN | SCHAR /;

      $limit-name ~~ s/SHRT/SHORT/;
      $limit-name .= lc;
      $limit-name = 'g' ~ $limit-name;

      $limit .= Int;

      given $limit-name {
        when / 'u' .*? '_max' $/ {
          $limit-name ~~ s/ '_max' //;
          $c-types{$limit-name} = 'uint' ~ $limit.base(16).chars * 4;
        }

        when / '_max' $/ {
          $limit-name ~~ s/ '_max' //;
          $c-types{$limit-name} = 'int' ~ $limit.base(16).chars * 4;
        }
      }
    }

    $proc.out.close;
    $run-ok = !$proc.exitcode;
  }

  # when program fails or did not compile we need some guesswork. Raku has the
  # idea that int is int64 on 64 bit machines which is not true in my case...
  unless $run-ok {
    $c-types<gchar> = 'int8';
    $c-types<gint> = 'int32';
    $c-types<glong> = $*KERNEL.bits() == 64 ?? 'int64' !! 'int32';
    $c-types<gshort> = 'int16';
    $c-types<guchar> = 'uint8';
    $c-types<guint> = 'uint32';
    $c-types<gulong> = $*KERNEL.bits() == 64 ?? 'uint64' !! 'int32';
    $c-types<gushort> = 'uint16';
  }

  # add other types which are fixed
  $c-types<gint8> = 'int8';
  $c-types<gint16> = 'int16';
  $c-types<gint32> = 'int32';
  $c-types<gint64> = 'int64';
  $c-types<guint8> = 'uint8';
  $c-types<guint16> = 'uint16';
  $c-types<guint32> = 'uint32';
  $c-types<guint64> = 'uint64';

  $c-types<gfloat> = 'num32';
  $c-types<gdouble> = 'num64';

  $c-types<gchar-ptr> = 'Str';
  $c-types<gpointer> = 'Pointer';
  $c-types<void-ptr> = 'Pointer[void]';

  # and some types which are defined already
  $c-types<gboolean> = $c-types<gint>;
  $c-types<gsize> = $c-types<gulong>;
  $c-types<gssize> = $c-types<glong>;
  $c-types<GType> = $c-types<gulong>;
  $c-types<GQuark> = $c-types<guint32>;
  $c-types<GEnum> = $c-types<gint>;
  $c-types<GFlag> = $c-types<guint>;
#  $c-types<gtype> = $c-types<gulong>;
#  $c-types<gquark> = $c-types<guint32>;

  $c-types<int-ptr> = "CArray[$c-types<gint>]";
  $c-types<gint-ptr> = "CArray[$c-types<gint>]";
  $c-types<char-pptr> = "CArray[$c-types<gchar-ptr>]";
  $c-types<gchar-pptr> = "CArray[$c-types<gchar-ptr>]";
  $c-types<char-ppptr> = "CArray[CArray[$c-types<gchar-ptr>]]";
  $c-types<gchar-ppptr> = "CArray[CArray[$c-types<gchar-ptr>]]";


  # generate the module text
  my Str $module-text = Q:to/EOMOD_START/;

    #-------------------------------------------------------------------------------
    # This module is generated at installation time.
    # Please do not change any of the contents of this module.
    #-------------------------------------------------------------------------------

    use v6;
    use NativeCall;

    unit package Gnome::N::GlibToRakuTypes;

    #-------------------------------------------------------------------------------
    EOMOD_START

  for $c-types.keys.sort -> $gtype-name {
    my Str $rtype-name = $c-types{$gtype-name};
    $module-text ~= sprintf "constant \\%-15s is export = %s;\n",
          $gtype-name, $rtype-name;
  }

  # write to module
  'lib/Gnome/N/GlibToRakuTypes.pm6'.IO.spurt($module-text);
}
