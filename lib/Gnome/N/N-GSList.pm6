use v6;
use NativeCall;

#-------------------------------------------------------------------------------
# Native object placed here because it is used by several modules. When placed
# in one of those module it can create circular dependencies
#
=begin pod
=head2 class N-GSList

Structure to create a single linked list. This native object is stored here to prevent circular dependencies.
=end pod

#TT:1:N-GSList:
class N-GSList is repr('CStruct') is export {
  has Pointer $.data;
  has N-GSList $.next;
}
