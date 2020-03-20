use v6.d;

#-------------------------------------------------------------------------------
=begin pod
=head1 Types
=head2 class N-GVariantBuilder

A utility type for constructing container-type GVariant instances. This is an opaque structure and may only be accessed using the functions from the B<Gnome::Glib::VariantBuilder> class.

N-GVariantBuilder is not threadsafe in any way. Do not attempt to access it from more than one thread.

=end pod

#TT:1:N-GVariantBuilder:
class N-GVariantBuilder
  is repr('CPointer')
  is export
  { }
