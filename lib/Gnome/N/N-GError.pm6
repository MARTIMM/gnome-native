use v6.d;

=begin pod
=head2 class N-GError;

=item has uint32 $.domain; The set domain.
=item has int32 $.code; The set error code.
=item has Str $.message; The error message.

=end pod
#TT:1:N-GError:
class N-GError is repr('CStruct') is export {
  has uint32 $.domain;            # is GQuark
  has int32 $.code;
  has Str $.message;
}
