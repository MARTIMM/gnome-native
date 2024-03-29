use v6;
#use NativeCall;

#-------------------------------------------------------------------------------
unit module Gnome::N::NativeLib:auth<github:MARTIMM>:ver<0.2.1>;

#-------------------------------------------------------------------------------
sub atk-lib ( --> Str )            is export { 'libatk-1.0.so.0'; }
sub cairo-gobject-lib ( --> Str )  is export { 'libcairo-gobject.so.2'; }
sub cairo-lib ( --> Str )          is export { 'libcairo.so.2'; }
sub gdk-lib ( --> Str )            is export { 'libgdk-3.so.0'; }
sub gdk-pixbuf-lib ( --> Str )     is export { 'libgdk_pixbuf-2.0.so.0'; }
sub gio-lib ( --> Str )            is export { 'libgio-2.0.so.0'; }
sub glib-lib ( --> Str )           is export { 'libglib-2.0.so.0'; }
sub gobject-lib ( --> Str )        is export { 'libgobject-2.0.so.0'; }
sub gtk-lib ( --> Str )            is export { 'libgtk-3.so.0'; }
sub gtk4-lib ( --> Str )           is export { 'libgtk-4.so.1'; }
sub pango-lib ( --> Str )          is export { 'libpango-1.0.so.0'; }
sub pangocairo-lib ( --> Str )     is export { 'libpangocairo-1.0.so.0'; }
