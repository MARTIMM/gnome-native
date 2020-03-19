use v6;
use NativeCall;

#-------------------------------------------------------------------------------
# Native object placed here because it is used by several modules. When placed
# in one of those module it can create circular dependencies
#
=begin pod
=head2 class N-GList

Structure to create a doubly linked list. This native object is stored here to prevent circular dependencies.
=end pod

#TT:1:N-GList:
class N-GList is repr('CStruct') is export {
  has Pointer $.data;
  has N-GList $.next;
  has N-GList $.prev;
}
