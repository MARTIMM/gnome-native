use v6;
use NativeCall;
use Test;

use Gnome::N::NativeLib;

#-------------------------------------------------------------------------------
subtest 'lib tests', {
  like gobject-lib(), /:s ^ libgobject .*? <[\.\d]>+ \. so $/,
       [~] 'gobject ', gobject-lib(), ' returned';
  like glib-lib(), /:s ^ libglib .*? <[\.\d]>+ \. so $/,
       [~] 'glib ', glib-lib(), ' returned';
  like gdk-lib(), /:s ^ libgdk .*? <[\.\d]>+ \. so $/,
       [~] 'gdk ', gdk-lib(), ' returned';
  like gtk-lib(), /:s ^ libgtk .*? <[\.\d]>+ \. so $/,
       [~] 'gtk ', gtk-lib(), ' returned';
}

#-------------------------------------------------------------------------------
done-testing;
