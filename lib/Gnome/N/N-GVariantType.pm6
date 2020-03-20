use v6.d;

#-------------------------------------------------------------------------------
# Native object placed here because it is used by several modules. When placed
# in one of those modules it can create circular dependencies.
=begin pod
=head2 class N-GVariantType

A type in the GVariant type system. N-GVariantType is an opaque data structure. This native object is stored here to prevent circular dependencies and some other reasons.

=end pod

#TT:1:N-GVariantType:
class N-GVariantType
is repr('CPointer')
is export
{ }
