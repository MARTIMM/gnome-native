use v6;

use Gnome::N::N-GObject;
use Gnome::Gtk3::Window;
use Gnome::N::X;


#-------------------------------------------------------------------------------
my Gnome::Gtk3::Window $w;
with $w .= new {
  .set-title('test window - N-GObject coercion');
  .show-all;
}

Gnome::N::debug(:on);

my N-GObject() $no = $w.get-visual-rk;
note "Raku Window: $w.get-visual-rk.gist()";
note "Native Window: $no.gist()";



$no = $w.get-visual-rk.N-GObject;
note "Raku Window: $w.get-visual-rk.gist()";
note "Native Window: $no.gist()";



$no = $w;
note "Raku Window: $w.gist()";
note "Native Window: $no.gist()";



my Gnome::Gtk3::Window() $w2 = $no;
note "Raku Window: $w2.^name(), $w2.gist(), $w2.get-title()";
