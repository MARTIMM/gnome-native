use v6;
use NativeCall;

use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::X;
Gnome::N::debug(:on);

#-------------------------------------------------------------------------------
sub gtk_button_new_with_label ( Str $label --> N-GObject )
  is native(&gtk-lib) is export { * }

sub gtk_button_get_label ( N-GObject $button --> Str )
  is native(&gtk-lib) is export { * }

#-------------------------------------------------------------------------------
my Callable $s;

my N-GObject $o = call-native-sub( 'gtk_button_new_with_label', Any);
#my N-GObject $o = &gtk_button_new_with_label("abc");
note "D: ", $o.defined, ', ', $o.perl;
note "L: ", &gtk_button_get_label($o);


sub call-native-sub ( Str $name, N-GObject, $o, |c --> Any ) {

  CATCH { test-catch-exception( $_, $name); }

  $s = {try &::($name);}
  note "S: ", $s.perl, ', ', $s.signature;

  test-call( $s, Any, |c)
}
