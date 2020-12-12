use v6;
use NativeCall;
use Test;

use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;

#diag (map -> $k, $v { "  $k: $v" }, $*VM.config.kv).join("\n");

#-------------------------------------------------------------------------------
subtest 'lib name tests', {
  like gobject-lib(), /:s gobject /, [~] 'gobject    ', gobject-lib();
  like glib-lib(),    /:s glib /,    [~] 'glib       ', glib-lib();
  like gdk-lib(),     /:s gdk /,     [~] 'gdk        ', gdk-lib();
  like gdk-pixbuf-lib(), /:s 'gdk_pixbuf' /,
                                     [~] 'gdk-pixbuf ', gdk-pixbuf-lib();
  like gtk-lib(),     /:s gtk /,     [~] 'gtk        ', gtk-lib();
  like gio-lib(),     /:s gio /,     [~] 'gio        ', gio-lib();
  like pango-lib(),   /:s pango /,   [~] 'pango      ', pango-lib();
}

#-------------------------------------------------------------------------------
constant G_TYPE_FUNDAMENTAL_SHIFT = 2;
constant G_TYPE_STRING is export = 16 +< G_TYPE_FUNDAMENTAL_SHIFT;

class N-GValue is repr('CStruct') is export {
  has GType $.g-type;

  # Data is a union. We do not use it but GTK does, so here it is
  # only set to a type with 64 bits for the longest field in the union.
  has gint64 $!g-data;

  # As if it was G_VALUE_INIT macro
  submethod TWEAK {
    $!g-type = 0;
  }
}

sub g_value_init ( N-GValue $value, GType $g_type --> N-GValue )
  is native(&gobject-lib)
  { * }

sub g_value_set_string ( N-GValue $value, gchar-ptr $v_string )
  is native(&gobject-lib)
  { * }

sub g_value_get_string ( N-GValue $value --> gchar-ptr )
  is native(&gobject-lib)
  { * }



subtest "lib 'gobject-lib' ~~ gobject-lib() access tests", {
  diag [~] "OS: ", $*VM.osname;
  diag [~] "config: ", $*VM.config<dll>;
  diag [~] "is-win: ", $*DISTRO.is-win;
  diag [~] "arch: ", $*KERNEL.arch;
  diag [~] "archname: ", $*KERNEL.archname;

  my N-GValue $no = g_value_init( N-GValue.new, G_TYPE_STRING);
  g_value_set_string( $no, 'new value');
  is g_value_get_string($no), 'new value',
     '.g_value_init() / .g_value_set_string() / .g_value_get_string()';
}

#-------------------------------------------------------------------------------
done-testing;
