use v6;
use NativeCall;

#-------------------------------------------------------------------------------
# Native object placed here because it is used by several modules. When placed
# in one of those module it can create circular dependencies
#
=begin pod
=head2 class N-GObject

Class at the top of many food chains
=end pod

#TT:1:N-GObject:
class N-GObject
  is repr('CPointer')
  is export
  { }
