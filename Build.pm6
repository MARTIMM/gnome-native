use v6;

#------------------------------------------------------------------------------
unit class Build;

has Str $!dist-path;

#-------------------------------------------------------------------------------
method build ( Str $!dist-path --> Int ) {

  self!map-installed-libraries;
  self!build-types-conversion-module;

  # return success
  1
}

#-------------------------------------------------------------------------------
method !map-installed-libraries ( ) {

  # Native lib calls are like 'is native(&gtk-lib)'. Library names on linux
  # and windows, all start with 'lib' (see also https://www.tecmint.com/understanding-shared-libraries-in-linux/ and https://tldp.org/HOWTO/Program-Library-HOWTO/shared-libraries.html).
  #
  my %libs-to-map = %(
    :gtk(3), :gdk(3), :glib(2), :gobject(2), :cairo(2), :gdk_pixbuf(2),
    :gio(2), :pango(1), :atk(1), :cairo-gobject(2), :pangocairo(1),
  );
#note %libs-to-map.perl;

  # generate head
  my Str $map = Q:q:to/EOMAP/;
    use v6;
    #use NativeCall;

    #-------------------------------------------------------------------------------
    unit module Gnome::N::NativeLib:auth<github:MARTIMM>:ver<0.2.1>;

    #-------------------------------------------------------------------------------
    EOMAP


  if $*DISTRO.is-win {
    # pick names found for mingw installation on AppVeyor
    $map ~= Q:q:to/EOMAP/;
      sub atk-lib ( --> Str )           is export { 'libatk-1.0-0.dll'; }
      sub cairo-gobject-lib ( --> Str ) is export { 'libcairo-gobject-2.dll'; }
      sub cairo-lib ( --> Str )         is export { 'libcairo-2.dll'; }
      sub gdk-lib ( --> Str )           is export { 'libgdk-3-0.dll'; }
      sub gdk-pixbuf-lib ( --> Str )    is export { 'libgdk_pixbuf-2.0-0.dll'; }
      sub gio-lib ( --> Str )           is export { 'libgio-2.0-0.dll'; }
      sub glib-lib ( --> Str )          is export { 'libglib-2.0-0.dll'; }
      sub gobject-lib ( --> Str )       is export { 'libgobject-2.0-0.dll'; }
      sub gtk-lib ( --> Str )           is export { 'libgtk-3-0.dll'; }
      sub pango-lib ( --> Str )         is export { 'libpango-1.0-0.dll'; }
      sub pangocairo-lib ( --> Str )    is export { 'libpangocairo-1.0-0.dll'; }
      EOMAP
  }

  else {
    my Str $ldconfig-path;
    my @bin-dirs = </bin /sbin /usr/sbin /usr/bin /opt/bin /usr/local/bin>;
    for @bin-dirs -> $bd {
      if "$bd/ldconfig".IO.e and "$bd/ldconfig".IO.x {
        $ldconfig-path = "$bd/ldconfig";
        last;
      }
    }

    my Proc $p = run $ldconfig-path, '-vN', :out, :err;

    for $p.out.lines.sort.unique -> $l {

      # get the line where a lib name if bound to the lib file
      if $l ~~ / '->' / {

        # get libname
        $l ~~ /^ \s+ $<libname> = (<-[\s]>+) \s+ '->' /;
        my Str $libname = $/<libname>.Str;

        # check for each needed library
        for %libs-to-map.kv -> $libtag is copy, $minver is rw {
          # it is possible that 32 and 64 bit libs are installed. this
          # will show this line twice and therefore generate the sub twice
          # see issue #22.
          # if $minver is set to -1000 then we have processed it before
          next if $minver == -1000;

          # if the lib is in this line
          if $libname ~~ m/^ lib $libtag <|w>
                             $<mv1> = (<[-\.\d]>+) so
                             $<mv2> = (<[-\.\d]>+)?
                          / {

            # get versions but make 2nd empty in abscense of one
            my Str $mv1 = $/<mv1>.Str;
            my Str $mv2 = ($/<mv2> // '').Str;

            if $mv1 ~~ m/ '-' $minver/ or $mv2 ~~ m/ '.' $minver/ {
note "$libtag";
              $libtag ~~ s/gdk_pixbuf/gdk-pixbuf/;
              $map ~= "sub " ~ "$libtag\-lib ( --> Str )".fmt('%-30s') ~
                      " is export \{ '$libname'; }\n";
#note "  sub " ~ "$libtag\-lib ( --> Str )".fmt('%-30s') ~ " is export \{ '$libname'; }\n";

              $minver = -1000;
              next;
            }

          }
        }
      }
    }

    $p.err.close;
    $p.out.close;
  }

  # write to module
  'lib/Gnome/N/NativeLib.pm6'.IO.spurt($map);
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

        when /^ 'gtime_t' / {
          # limit is in bytes
          $limit-name = 'time_t';
          $c-types{$limit-name} = 'int' ~ $limit * 8;
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

    # time can be negative, see https://c-for-dummies.com/blog/?p=3435
    $c-types<time_t> = $*KERNEL.bits() == 64 ?? 'int64' !! 'int32';
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

    unit package Gnome::N::GlibToRakuTypes:auth<github:MARTIMM>:ver<0.3.0>;

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
