use v6;

#-------------------------------------------------------------------------------
unit module Gnome::N::NativeLib:auth<github:MARTIMM>:api<1>;

#-------------------------------------------------------------------------------
#Note; Libraries for Gsk4 and Gdk4 are in that of Gtk4.
#      Also Gtk3 and Gdk3 are added.
sub atk-lib ( --> Str )            is export { 'libatk-1.0.so.0'; }
sub cairo-gobject-lib ( --> Str )  is export { 'libcairo-gobject.so.2'; }
sub cairo-lib ( --> Str )          is export { 'libcairo.so.2'; }
sub gdk3-lib ( --> Str )           is export { 'libgdk-3.so.0'; }
sub gdk-lib ( --> Str )            is export { 'libgdk-3.so.0'; }
sub gdk-pixbuf-lib ( --> Str )     is export { 'libgdk_pixbuf-2.0.so.0'; }
sub gio-lib ( --> Str )            is export { 'libgio-2.0.so.0'; }
sub glib-lib ( --> Str )           is export { 'libglib-2.0.so.0'; }
sub gobject-lib ( --> Str )        is export { 'libgobject-2.0.so.0'; }
sub gtk-lib ( --> Str )            is export { 'libgtk-3.so.0'; }
sub gtk3-lib ( --> Str )           is export { 'libgtk-3.so.0'; }
sub gdk4-lib ( --> Str )           is export { 'libgtk-4.so.1'; }
sub gsk4-lib ( --> Str )           is export { 'libgtk-4.so.1'; }
sub gtk4-lib ( --> Str )           is export { 'libgtk-4.so.1'; }
sub pango-lib ( --> Str )          is export { 'libpango-1.0.so.0'; }
sub pangocairo-lib ( --> Str )     is export { 'libpangocairo-1.0.so.0'; }
