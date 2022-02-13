use v6;
use NativeCall;

use Gnome::N::NativeLib;

#-------------------------------------------------------------------------------
# Native object placed here because it is used by several modules. When placed
# in one of those module it can create circular dependencies
#
=begin pod
=head2 class N-GObject

Class at the top of many food chains. This native object is stored here to prevent circular dependencies.

Previously I thought this would be an object from everything GObject in glib and child classes. Now, I will use it for everything opaque and call it a I<Native Gnome Object>. This object is always stored in the B<Gnome::N::TopLevelClassSupport>. It is created in a C<.BUILD()> submethod or imported using C<:native-object> or C<:build-id> named argument to a C<.new()> method. There are other objects which are not so opaque like B<N-GError> and B<N-GdkRGBA>. These objects are defined in their proper places. So, in short, every standalone class has its own native object (or even none like B<Gnome::Glib::Quark>), and every class inheriting from B<Gnome::N::TopLevelClassSupport>, directly or indirectly, has this opaque object B<N-GObject>.

=end pod

#TT:1:N-GObject:
unit class N-GObject is repr('CPointer') is export;

#-----------------------------------------------------------------------------
#tm:4:CALL-ME:
=begin pod
=head2 CALL-ME

Wrap this native object in a Raku object given by the C<$rk-type> or C<$rk-type-name> from the argument.

Example where the native object is a B<GtkWindow> type. The Raku type would then be B<Gnome::Gtk3::Window>.

  my Gnome::Gtk3::Window $w .= new;
  $w.set-title('N-GObject coercion');
  my N-GObject() $no = $w;

  # CALL-ME is used here. There are 3 ways to use it.
  say $no(Gnome::Gtk3::Window).get-title;     # N-GObject coercion
  say $no('Gnome::Gtk3::Window').get-title;   # N-GObject coercion
  say $no().get-title;                        # N-GObject coercion

=end pod

multi method CALL-ME( $rk-type ) {
  self._wrap-native-type( $rk-type.^name, self)
}

multi method CALL-ME( Str:D $rk-type-name ) {
  self._wrap-native-type( $rk-type-name, self)
}

multi method CALL-ME( ) {
  self._wrap-native-type-from-no(self)
}

#-----------------------------------------------------------------------------
#tm:4:_wrap-native-type:
# no doc, same routine as in TopLevelClassSupport
method _wrap-native-type ( Str:D $type where ?$type, Any $no --> Any ) {

  # get class and wrap the native object in it
  try require ::($type);
  if $Gnome::N::x-debug and ::($type) ~~ Failure {
    note "Failed to load $type!";
    ::($type).note;
  }

  else {
    if ?$no {
      ::($type).new(:native-object($no));
    }

    else {
      ::($type).new(:native-object(N-GObject));
    }
  }
}

#-----------------------------------------------------------------------------
#tm:4:_wrap-native-type-from-no:
# no doc, same routine as in TopLevelClassSupport
method _wrap-native-type-from-no (
  N-GObject $no, Str:D $match = '', Str:D $replace = '', *%options
  --> Any
) {
  my Str $type;

  # process :child-type first
  if %options<child-type>:exists {
    if %options<child-type> ~~ Str {
      $type = %options<child-type>;
    }

    else {
      return %options<child-type>.new(:native-object($no))
    }
  }

  else {
    $type = ?$no ?? _name_from_instance($no) !! '';
    return N-GObject unless ( ?$type and $type ne '<NULL-class>');

    if ?$match {
      $type ~~ s/$match/$replace/;
    }

    else {
      given $type {
        when /^ Gtk / { $type ~~ s/^ Gtk/Gtk3::/; }
        when /^ GdkX11 / { $type ~~ s/^ GdkX11/Gdk3::/; }
        when /^ GdkWayland / { $type ~~ s/^ GdkWayland/Gdk3::/; }
        when /^ Gdk / { $type ~~ s/^ Gdk/Gdk3::/; }
        when /^ Atk / { $type ~~ s/^ Atk/Atk::/; }

        # Checking other objects from GObject, Glib and Gio all start with 'G'
        # so it is difficult to map it to the proper raku object.
        #
        # However, wrapping like this is only used when there are multiple
        # native object types to return to the caller. This is mostly
        # restricted to Gtk3 modules. The other reason to call this wrapper is
        # to prevent circular dependencies which sometimes happen in Gdk3
        # modules.
        #
        # The rest must cope with the $match and $replace variables or solve it
        # by using 'my Xyz $xyz .= new(:native-object($no))' or do the require
        # trick used below.

  #      when /^ G / { $native-name ~~ s/^ /::/; }
  #      when /^  / { $native-name ~~ s/^ /::/; }
      }
    }

    $type = [~] 'Gnome', '::', $type;

    #  my Str $type = [~] 'Gnome', '::', $native-name;
    note "wrap $type" if $Gnome::N::x-debug;
  }

  # get class and wrap the native object in it
  require ::($type);
  ::($type).new(:native-object($no))
}

#-------------------------------------------------------------------------------
#--[ some necessary native subroutines ]----------------------------------------
#-------------------------------------------------------------------------------
sub _name_from_instance ( N-GObject $instance --> Str )
  is native(&gobject-lib)
  is symbol('g_type_name_from_instance')
  { * }





=finish
# TODO - needed?
#-----------------------------------------------------------------------------
method FALLBACK( $routine, *@a, *%o ) {
  note 'a & o: ', self.^name, ', ', $routine, ', ', @a.gist, ', ', %o.gist;
  self._wrap-native-type-from-no(self)."$routine"( |@a, |%o);
}

#-------------------------------------------------------------------------------
# TM:1:COERCE:
=begin pod
=head2 COERCE

Method to wrap a native object into a Raku object

Example;
=begin code
  my N-GObject $no = …;
  my Gnome::Gtk3::Window() $w = $no;
=end code

=begin code
  method COERCE( $no --> Any )
=end code

=end pod
method COERCE( $no --> Any ) {
note 'N-GObject COERCE: ', $no;
  note "Coercing from N-GObject to ", self.^name if $Gnome::N::x-debug;
  self._wrap-native-type( self.^name, $no)
}
