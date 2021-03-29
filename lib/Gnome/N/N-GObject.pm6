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
class N-GObject
  is repr('CPointer')
  is export
  { }
