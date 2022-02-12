use v6;
use NativeCall;

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
class N-GObject is repr('CPointer') is export {

  #-----------------------------------------------------------------------------
  #tm:4:CALL-ME:
  =begin pod
  =head2 CALL-ME

  Wrap this native object in a Raku object given by the C<$rk-type> or C<$rk-type-name> from the argument.
  =end pod

  multi method CALL-ME( $rk-type ) {
    self._wrap-native-type( $rk-type.^name, self)
  }

  multi method CALL-ME( Str:D $rk-type-name ) {
    self._wrap-native-type( $rk-type-name, self)
  }

  #-----------------------------------------------------------------------------
#`{{
  #tm:4:_wrap-native-type:
  =begin pod
  =head2 _wrap-native-type

  Used by many classes to create a Raku instance with the native object wrapped in. Sometimes the native object C<$no> is returned from other methods as an undefined object. In that case, the Raku class is created as an invalid object in most cases. Exceptions are the two list classes from C<Gnome::Glib>.

    method _wrap-native-type (
      Str:D $type where ?$type, Any $no
      --> Any
    )

  =end pod
}}
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
}
