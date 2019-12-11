use v6;
use NativeCall;
use Test;

use Gnome::N::NativeLib;

#-------------------------------------------------------------------------------
subtest 'lib tests', {
  like gobject-lib(), /:s ^ libgobject /,
       [~] 'gobject ', gobject-lib(), ' returned';
  like glib-lib(), /:s ^ libglib /, [~] 'glib ', glib-lib(), ' returned';
  like gdk-lib(), /:s ^ libgdk /, [~] 'gdk ', gdk-lib(), ' returned';
  like gtk-lib(), /:s ^ libgtk /, [~] 'gtk ', gtk-lib(), ' returned';
}

#-------------------------------------------------------------------------------
done-testing;
