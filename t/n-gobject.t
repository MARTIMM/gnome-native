use v6;
use NativeCall;
use Test;

use Gnome::N::N-GObject;

#-------------------------------------------------------------------------------
subtest 'native object', {
  my N-GObject $n .= new;
  isa-ok $n, N-GObject;
}

#-------------------------------------------------------------------------------
done-testing;
