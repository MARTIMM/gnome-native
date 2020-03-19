use v6;
use NativeCall;

#-------------------------------------------------------------------------------
# Native object placed here because it is used by several modules. When placed
# in one of those module it can create circular dependencies
#
=begin pod
=head2 class N-GOptionContext

An option context. This native object is stored here to prevent circular dependencies.
=end pod

#TT:1:N-GOptionContext:
class N-GOptionContext
  is repr('CPointer')
  is export
  { }
