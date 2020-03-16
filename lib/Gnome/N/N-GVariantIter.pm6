use v6.d;

=begin pod
=head2 class N-GVariantIter;

A type in the GVariant type system. N-GVariantIter is an opaque data structure. This native object is stored here to prevent circular dependencies and some other reasons.

=end pod
#TT:1::N-GVariantIter
class N-GVariantIter
  is repr('CPointer')
  is export
  { }
