use v6;
use NativeCall;
use Test;

use Gnome::N::NativeLib;
use Gnome::N::N-GObject;

#diag (map -> $k, $v { "  $k: $v" }, $*VM.config.kv).join("\n");

#`{{
#-------------------------------------------------------------------------------
sub gtk_button_new_with_label ( Str $label --> N-GObject )
  is native(&gtk-lib) is export { * }

sub gtk_button_get_label ( N-GObject $button --> Str )
  is native(&gtk-lib) is export { * }
}}

#-------------------------------------------------------------------------------
subtest 'lib name tests', {
  like gobject-lib(), /:s gobject /, [~] 'gobject    ', gobject-lib();
  like glib-lib(), /:s glib /, [~] 'glib       ', glib-lib();
  like gdk-lib(), /:s gdk /, [~] 'gdk        ', gdk-lib();
  like gdk-pixbuf-lib(), /:s 'gdk_pixbuf' /,
       [~] 'gdk-pixbuf ', gdk-pixbuf-lib();
  like gtk-lib(), /:s gtk /, [~] 'gtk        ', gtk-lib();

  like gio-lib(), /:s gio /, [~] 'gio        ', gio-lib();
  like pango-lib(), /:s pango /, [~] 'pango      ', pango-lib();
}

#`{{
#-------------------------------------------------------------------------------
subtest 'lib access tests', {

  my N-GObject $o = gtk_button_new_with_label("abc");
  ok $o.defined, 'gtk_button_new_with_label';
  is gtk_button_get_label($o), 'abc', 'gtk_button_get_label';
}
}}

#-------------------------------------------------------------------------------
done-testing;
