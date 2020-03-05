use v6;
use NativeCall;

#-------------------------------------------------------------------------------
# Native object placed here because it is used by several modules. When placed
# in one of those module it can create circular dependencies
#
=begin pod
=head2 class N-GVariant

N-GVariant is an opaque data structure and can only be accessed using the functions in this class. This native object is stored in this Raku class.

=end pod

#TT:1:N-GVariant:
class N-GVariant
  is repr('CPointer')
  is export
  { }
