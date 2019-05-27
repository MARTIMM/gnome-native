use v6;
use Test;

use Gnome::N::X;

#-------------------------------------------------------------------------------
subtest 'X exception', {
  throws-like(
    { die X::Gnome.new(:message('die pour rien')) },
    X::Gnome, 'Test exception',
    :message('die pour rien')
  );

  is $X::Gnome::x-debug, False, 'debug flag is false by default';
  X::Gnome.debug(:on);
  is $X::Gnome::x-debug, True, 'debug flag is true';
  X::Gnome.debug(:!on);
  is $X::Gnome::x-debug, False, 'debug flag is false again';
}

#-------------------------------------------------------------------------------
subtest 'test catch', {
  throws-like(
    { my X::Gnome $x .= new(:message('die pour rien'));
      test-catch-exception( $x, 'some-native-sub-name');
    },
    X::Gnome,
    :message("Could not find native sub 'some-native-sub-name(...)'")
  );
}

#-------------------------------------------------------------------------------
done-testing;
