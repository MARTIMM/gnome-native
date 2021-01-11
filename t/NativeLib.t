use v6;
use NativeCall;
use Test;

use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;

#-------------------------------------------------------------------------------
subtest 'lib names', {
  diag 'atk-lib:            ' ~ atk-lib();
  diag 'cairo-gobject-lib:  ' ~ cairo-gobject-lib();
  diag 'cairo-lib:          ' ~ cairo-lib();
  diag 'gdk-lib:            ' ~ gdk-lib();
  diag 'gdk-pixbuf-lib:     ' ~ gdk-pixbuf-lib();
  diag 'gio-lib:            ' ~ gio-lib();
  diag 'glib-lib:           ' ~ glib-lib();
  diag 'gobject-lib:        ' ~ gobject-lib();
  diag 'pango-lib:          ' ~ pango-lib();
  diag 'pangocairo-lib:     ' ~ pangocairo-lib();
}

#-------------------------------------------------------------------------------
subtest 'lib name tests', {
  like cairo-lib(), /:s cairo /, 'cairo';
  like gdk-lib(), /:s gdk /, 'gdk';
  like gdk-pixbuf-lib(), /:s 'gdk_pixbuf' /, 'gdk-pixbuf';
  like gio-lib(), /:s gio /, 'gio';
  like glib-lib(), /:s glib /, 'glib';
  like gobject-lib(), /:s gobject /, 'gobject';
  like gtk-lib(), /:s gtk /, 'gtk';
  like pango-lib(), /:s pango /, 'pango';
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
  my N-GValue $no = g_value_init( N-GValue.new, G_TYPE_STRING);
  g_value_set_string( $no, 'new value');
  is g_value_get_string($no), 'new value',
     '.g_value_init() / .g_value_set_string() / .g_value_get_string()';
}

#-------------------------------------------------------------------------------
done-testing;
