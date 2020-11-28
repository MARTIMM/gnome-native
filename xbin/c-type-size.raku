use v6;

my Bool $run-ok;
my Hash $c-types = %();

try {
  my Proc $proc;

  # make C program to get the limits of integers, float and doubles
  $proc = run 'gcc', '-o', 'xbin/c-type-size', 'xbin/c-type-size.c';

  # run this C program to read the limits
  $proc = run 'xbin/c-type-size', :out;

  for $proc.out.lines -> $line {
    my ( $limit-name, $limit) = $$line.split(/ \s* ':' \s* /);
  #  note "$limit-name, $limit";
    next if $limit-name ~~ m/ MIN | SCHAR /;

    $limit-name ~~ s/SHRT/SHORT/;
    $limit-name .= lc;
    $limit-name = 'g' ~ $limit-name;

    $limit .= Int;

    given $limit-name {
  #    when 'CHAR_BIT' {
  #      note "$limit-name, $limit, int$limit.base(16)";
  #    }

      when / 'u' .*? '_max' $/ {
        $limit-name ~~ s/ '_max' //;
        $c-types{$limit-name} = 'uint' ~ $limit.base(16).chars * 4;
  #      note sprintf( "%11s uint%d",
  #        $limit-name, $limit.base(16).chars * 4
  #      );
      }

      when / '_max' $/ {
        $limit-name ~~ s/ '_max' //;
        $c-types{$limit-name} = 'int' ~ $limit.base(16).chars * 4;
  #      note sprintf( "%11s int%d",
  #        $limit-name, $limit.base(16).chars * 4
  #      );
      }
  #`{{
      when 'INT_MAX' {
        note "0x$limit.base(16)", 'int' ~ ($limit.base(16).chars * 4).Str;
      }

      when 'INT_MIN' {
        note "0x$limit.base(16)", 'int' ~ ($limit.base(16).chars * 4).Str;
      }

      when 'UINT_MAX' {
        note "0x$limit.base(16), ", 'int' ~ ($limit.base(16).chars * 4).Str;
      }

      when 'LONG_MAX' {
        note "0x$limit.base(16)", 'int' ~ ($limit.base(16).chars * 4).Str;
      }

      when 'LONG_MIN' {
        note "0x$limit.base(16)", 'int' ~ ($limit.base(16).chars * 4).Str;
      }

      when 'ULONG_MAX' {
        note "0x$limit.base(16), ", 'int' ~ ($limit.base(16).chars * 4).Str;
      }
  }}
    }
  }

  $proc.out.close;
#  note $proc.exitcode;
  $run-ok = !$proc.exitcode;

  CATCH {
    default {
      note "Failed to run C program, over to plan B, quesswork...";
      $run-ok = False;
    }
  }
}

# when program fails or did not compile we need some guesswork. Raku has the
# idea that int is in64 on 64 bit machines which is not true in my case...
unless $run-ok {
#  note "\nBits: $*KERNEL.bits(), ", int64.Range;

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
$c-types<void-ptr> = 'Pointer[void]';

# and some types which are defined already
$c-types<gboolean> = $c-types<gint>;
$c-types<gsize> = $c-types<gulong>;
$c-types<gssize> = $c-types<glong>;
$c-types<GType> = $c-types<gulong>;
$c-types<gtype> = $c-types<gulong>;
$c-types<GQuark> = $c-types<guint32>;
$c-types<gquark> = $c-types<guint32>;

#note $c-types.gist;

# generate the module text
my Str $module-text = Q:to/EOMOD_START/;

  #-------------------------------------------------------------------------------
  # This module is generated at installation time.
  # Please do not change any of the contents of this module.
  #-------------------------------------------------------------------------------

  use v6;
  unit package Gnome::N::GlibToRakuTypes;

  #-------------------------------------------------------------------------------
  EOMOD_START

for $c-types.keys.sort -> $gtype-name {
  my Str $rtype-name = $c-types{$gtype-name};
  $module-text ~= sprintf "constant \\%-15s is export = %s;\n",
        $gtype-name, $rtype-name;
}

note $module-text;
