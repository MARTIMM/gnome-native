# This file is copied from the Gtk::Simple package. The reason to copy the file
# is to remove dependency on that package because only this file is used

use v6;
use NativeCall;

unit module Gnome::N::NativeLib;

# There is more defined than is needed for the Gnome packages so most of them
# are inhibited until they are needed.

# used for Gnome::At
sub atk-lib is export {
  state $lib = $*VM.platform-library-name('atk-1.0'.IO).Str;
  $lib
}

sub cairo-gobject-lib {
  state $lib = $*VM.platform-library-name('cairo-gobject-2'.IO).Str;
  $lib
}

sub cairo-lib is export {
  state $lib = $*VM.platform-library-name('cairo-2'.IO).Str;
  $lib
}

#`{{
sub ffi-lib {
  state $lib = $*VM.platform-library-name('ffi-7'.IO).Str;
  $lib
}

sub fontconfig-lib {
  state $lib = $*VM.platform-library-name('fontconfig-1'.IO).Str;
  $lib
}

sub freetype-lib {
  state $lib = $*VM.platform-library-name('freetype-6'.IO).Str;
  $lib
}
}}

sub gdk-lib is export {
  state $lib = $*VM.platform-library-name('gdk-3'.IO).Str;
  $lib
}

sub gdk-pixbuf-lib is export {
  state $lib = $*VM.platform-library-name('gdk_pixbuf-2.0'.IO).Str;
  $lib
}

sub glib-lib is export {
  state $lib = $*VM.platform-library-name('glib-2.0'.IO).Str;
  $lib
}

sub gobject-lib is export {
  state $lib = $*VM.platform-library-name('gobject-2.0'.IO).Str;
  $lib
}

sub gio-lib is export {
  state $lib = $*VM.platform-library-name('gio-2.0'.IO).Str;
  $lib
}

#`{{
sub gmodule-lib {
  state $lib = $*VM.platform-library-name('gmodule-2.0'.IO).Str;
  $lib
}
}}

sub gtk-lib is export {
  state $lib = $*VM.platform-library-name('gtk-3'.IO).Str;
  $lib
}

#`{{
sub iconv-lib {
  state $lib = $*VM.platform-library-name('iconv-2'.IO).Str;
  $lib
}

sub intl-lib {
  state $lib = $*VM.platform-library-name('intl-8'.IO).Str;
  $lib
}

sub lzma-lib {
  state $lib = $*VM.platform-library-name('lzma-5'.IO).Str;
  $lib
}
}}

sub pango-lib is export {
  state $lib = $*VM.platform-library-name('pango-1.0'.IO).Str;
  $lib
}

sub pangocairo-lib {
  state $lib = $*VM.platform-library-name('pangocairo-1.0'.IO).Str;
  $lib
}

#`{{
sub pangoft2-lib {
  state $lib = $*VM.platform-library-name('pangoft2-1.0'.IO).Str;
  $lib
}

sub pangowin32-lib {
  state $lib = $*VM.platform-library-name('pangowin32-1.0'.IO).Str;
  $lib
}

sub pixman-lib {
  state $lib = $*VM.platform-library-name('pixman-1'.IO).Str;
  $lib
}

sub png-lib {
  state $lib = $*VM.platform-library-name('libpng16-16'.IO).Str;
  $lib
}

sub xml-lib {
  state $lib = $*VM.platform-library-name('xml2-2'.IO).Str;
  $lib
}

sub zlib-lib {
  state $lib = $*VM.platform-library-name('zlib1'.IO).Str;
  $lib
}
}}



=finish


sub atk-lib {
    state $lib;
    unless $lib {
        $lib = find-bundled('libatk-1.0-0.dll');
    }
    $lib
}

sub cairo-gobject-lib {
    state $lib;
    unless $lib {
        try load-cairo-lib;
        try load-glib-lib;
        try load-gobject-lib;
        $lib = find-bundled('libcairo-gobject-2.dll');
    }
    $lib
}

sub cairo-lib is export {
    state $lib;
    unless $lib {
        if $*VM.config<dll> ~~ /dll/ {
#          try load-fontconfig-lib;
#          try load-freetype-lib;
#          try load-pixman-lib;
#          try load-png-lib;
#          try load-zlib-lib;
#          $lib = find-bundled('libcairo-2.dll');
          $lib = $*VM.platform-library-name('cairo-2'.IO).Str;
        } else {
          $lib = $*VM.platform-library-name('cairo'.IO).Str;
        }
    }
    $lib
}

#`{{
sub gdk-pixbuf-lib {
    state $lib;
    unless $lib {
        try load-gio-lib;
        try load-glib-lib;
        try load-gmodule-lib;
        try load-gobject-lib;
        try load-intl-lib;
        try load-png-lib;
        $lib = find-bundled('libgdk_pixbuf-2.0-0.dll');
    }
    $lib
}
}}
#`{{
sub gio-lib {
    state $lib;
    unless $lib {
        try load-glib-lib;
        try load-gmodule-lib;
        try load-gobject-lib;
        try load-intl-lib;
        try load-zlib-lib;
        $lib = find-bundled('libgio-2.0-0.dll');
    }
    $lib
}
}}

sub gmodule-lib {
    state $lib;
    unless $lib {
        $lib = find-bundled('libgmodule-2.0-0.dll');
    }
    $lib
}
sub intl-lib {
    state $lib;
    unless $lib {
        $lib = find-bundled('libintl-8.dll');
    }
    $lib
}
#`{{
sub pango-lib {
    state $lib;
    unless $lib {
        $lib = find-bundled('libpango-1.0-0.dll');
    }
    $lib
}
}}
sub pangocairo-lib {
    state $lib;
    unless $lib {
        try load-pango-lib;
        try load-pangoft2-lib;
        try load-pangowin32-lib;
        try load-cairo-lib;
        try load-fontconfig-lib;
        try load-freetype-lib;
        try load-glib-lib;
        try load-gobject-lib;
        $lib = find-bundled('libpangocairo-1.0-0.dll');
    }
    $lib
}
sub pangowin32-lib {
    state $lib;
    unless $lib {
        $lib = find-bundled('libpangowin32-1.0-0.dll');
    }
    $lib
}
sub fontconfig-lib {
    state $lib;
    unless $lib {
        try load-freetype-lib;
        try load-xml-lib;
        $lib = find-bundled('libfontconfig-1.dll');
    }
    $lib
}
sub freetype-lib {
    state $lib;
    unless $lib {
        try load-zlib-lib;
        $lib = find-bundled('libfreetype-6.dll');
    }
    $lib
}
sub pixman-lib {
    state $lib;
    unless $lib {
        $lib = find-bundled('libpixman-1-0.dll');
    }
    $lib
}
sub png-lib {
    state $lib;
    unless $lib {
        $lib = find-bundled('libpng15-15.dll');
    }
    $lib
}
sub zlib-lib {
    state $lib;
    unless $lib {
        $lib = find-bundled('zlib1.dll');
    }
    $lib
}
sub xml-lib {
    state $lib;
    unless $lib {
        try load-iconv-lib;
        try load-lzma-lib;
        $lib = find-bundled('libxml2-2.dll');
    }
    $lib
}
sub iconv-lib {
    state $lib;
    unless $lib {
        $lib = find-bundled('libiconv-2.dll');
    }
    $lib
}
sub lzma-lib {
    state $lib;
    unless $lib {
        $lib = find-bundled('liblzma-5.dll');
    }
    $lib
}
sub ffi-lib {
    state $lib;
    unless $lib {
        $lib = find-bundled('libffi-6.dll');
    }
    $lib
}
sub pangoft2-lib {
    state $lib;
    unless $lib {
        $lib = find-bundled('libpangoft2-1.0-0.dll');
    }
    $lib
}

sub gtk-lib is export {
    state $lib;
    unless $lib {
        if $*VM.config<dll> ~~ /dll/ {
            try load-gdk-lib;
            try load-atk-lib;
            try load-cairo-gobject-lib;
            try load-cairo-lib;
            try load-gdk-pixbuf-lib;
            try load-gio-lib;
            try load-glib-lib;
            try load-gmodule-lib;
            try load-gobject-lib;
            try load-intl-lib;
            try load-pango-lib;
            try load-pangocairo-lib;
            try load-pangowin32-lib;
            $lib = find-bundled('libgtk-3-0.dll');
        } else {
            $lib = $*VM.platform-library-name('gtk-3'.IO).Str;
        }
    }
    $lib
}

sub gdk-lib is export {
    state $lib;
    unless $lib {
        if $*VM.config<dll> ~~ /dll/ {
            try load-cairo-gobject-lib;
            try load-cairo-lib;
            try load-gdk-pixbuf-lib;
            try load-gio-lib;
            try load-glib-lib;
            try load-gobject-lib;
            try load-intl-lib;
            try load-pango-lib;
            try load-pangocairo-lib;
            $lib = find-bundled('libgdk-3-0.dll');
        } else {
            $lib = $*VM.platform-library-name('gdk-3'.IO).Str;
        }
    }
    $lib
}

sub gdk-pixbuf-lib is export {
    state $lib;
    unless $lib {
        if $*VM.config<dll> ~~ /dll/ {
            try load-gio-lib;
            try load-glib-lib;
            try load-gmodule-lib;
            try load-gobject-lib;
            try load-intl-lib;
            try load-png-lib;
            $lib = find-bundled('libgdk_pixbuf-2.0-0.dll');
        } else {
          $lib = $*VM.platform-library-name('gdk_pixbuf-2.0'.IO).Str;
        }
    }
    $lib
}

sub glib-lib is export {
    state $lib;
    unless $lib {
        if $*VM.config<dll> ~~ /dll/ {
            try load-intl-lib;
            $lib = find-bundled('libglib-2.0-0.dll');
        } else {
            $lib = $*VM.platform-library-name('glib-2.0'.IO).Str;
        }
    }
    $lib
}

sub gobject-lib is export {
    state $lib;
    unless $lib {
        if $*VM.config<dll> ~~ /dll/ {
            try load-glib-lib;
            try load-ffi-lib;
            $lib = find-bundled('libgobject-2.0-0.dll');
        } else {
            $lib = $*VM.platform-library-name('gobject-2.0'.IO).Str;
        }
    }
    $lib
}


sub glib-lib is export {
    state $lib;
    unless $lib {
        if $*VM.config<dll> ~~ /dll/ {
            $lib = $*VM.platform-library-name('glib-2.0'.IO).Str;
        } else {
            $lib = $*VM.platform-library-name('glib-2.0'.IO).Str;
        }
    }
    $lib
}

sub gtk-lib is export {
    state $lib;
    unless $lib {
        if $*VM.config<dll> ~~ /dll/ {
            $lib = $*VM.platform-library-name('gtk-3'.IO).Str;
        } else {
            $lib = $*VM.platform-library-name('gtk-3'.IO).Str;
        }
    }
    $lib
}

sub pango-lib is export {
  state $lib;
  unless $lib {
    if $*VM.config<dll> ~~ /dll/ {
      $lib = find-bundled('libpango-1.0-0.dll');
    } else {
      $lib = $*VM.platform-library-name('pango-1.0'.IO).Str;
    }
  }
  $lib
}

sub gdk-lib is export {
    state $lib;
    unless $lib {
        if $*VM.config<dll> ~~ /dll/ {
            $lib = $*VM.platform-library-name('gdk-3'.IO).Str;
        } else {
            $lib = $*VM.platform-library-name('gdk-3'.IO).Str;
        }
    }
    $lib
}

sub gdk-pixbuf-lib is export {
    state $lib;
    unless $lib {
        if $*VM.config<dll> ~~ /dll/ {
            $lib = $*VM.platform-library-name('gdk_pixbuf-2'.IO).Str;
        } else {
          $lib = $*VM.platform-library-name('gdk_pixbuf-2.0'.IO).Str;
        }
    }
    $lib
}


sub find-bundled($lib is copy) {
#`{{
    # if we can't find one, assume there's a system install
    my $base = "blib/lib/GTK/$lib";

    if my $file = %?RESOURCES{$base} {
            $file.IO.copy($*SPEC.tmpdir ~ '\\' ~ $lib);
            $lib = $*SPEC.tmpdir ~ '\\' ~ $lib;
    }
}}
    $lib;
}

sub load-gdk-lib is native(&gdk-lib) { ... }
sub load-atk-lib is native(&atk-lib) { ... }
sub load-cairo-gobject-lib is native(&cairo-gobject-lib) { ... }
sub load-cairo-lib is native(&cairo-lib) { ... }
sub load-gdk-pixbuf-lib is native(&gdk-pixbuf-lib) { ... }
sub load-gio-lib is native(&gio-lib) { ... }
sub load-glib-lib is native(&glib-lib) { ... }
sub load-gmodule-lib is native(&gmodule-lib) { ... }
sub load-gobject-lib is native(&gobject-lib) { ... }
sub load-intl-lib is native(&intl-lib) { ... }
sub load-pango-lib is native(&pango-lib) { ... }
sub load-pangocairo-lib is native(&pangocairo-lib) { ... }
sub load-pangowin32-lib is native(&pangowin32-lib) { ... }
sub load-fontconfig-lib is native(&fontconfig-lib) { ... }
sub load-freetype-lib is native(&freetype-lib) { ... }
sub load-pixman-lib is native(&pixman-lib) { ... }
sub load-png-lib is native(&png-lib) { ... }
sub load-zlib-lib is native(&zlib-lib) { ... }
sub load-xml-lib is native(&xml-lib) { ... }
sub load-iconv-lib is native(&iconv-lib) { ... }
sub load-lzma-lib is native(&lzma-lib) { ... }
sub load-ffi-lib is native(&ffi-lib) { ... }
sub load-pangoft2-lib is native(&pangoft2-lib) { ... }
