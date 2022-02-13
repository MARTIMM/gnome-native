use v6;
use Test;

use Gnome::N::N-GObject;
use Gnome::Gtk3::Window;
use Gnome::Gdk3::Visual;
use Gnome::N::X;


#-------------------------------------------------------------------------------
my Gnome::Gtk3::Window $w;
with $w .= new {
  .set-title('N-GObject coercion');
  .show-all;
}

#Gnome::N::debug(:on);

my N-GObject() $no = $w.get-visual-rk;
is $no.^name, 'N-GObject', 'TopLevelClassSupport N-GObject()';

$no = $w.get-visual-rk.N-GObject;
is $no.^name, 'N-GObject', 'TopLevelClassSupport N-GObject()';


$no = $w;
my Gnome::Gtk3::Window(N-GObject) $w2 = $no;
is $w2.get-title, 'N-GObject coercion', 'TopLevelClassSupport COERCE()';


is $no(Gnome::Gtk3::Window).get-title, 'N-GObject coercion', 'N-GObject CALL-ME(gnome type)';

is $no('Gnome::Gtk3::Window').get-title, 'N-GObject coercion', 'N-GObject CALL-ME(Str)';

is $no().get-title, 'N-GObject coercion', 'N-GObject CALL-ME()';
#TODO  - needed?: is $no.get-title, 'N-GObject coercion', 'N-GObject CALL-ME()';


my Gnome::Gdk3::Visual() $visual = $w.get-visual;
is $visual.^name, 'Gnome::Gdk3::Visual', 'assign from no';



#-------------------------------------------------------------------------------
done-testing;
