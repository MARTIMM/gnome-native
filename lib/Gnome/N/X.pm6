use v6;


#-------------------------------------------------------------------------------
class X::Gnome is Exception {
  has $.message;

  submethod BUILD ( Str:D :$!message ) { }
}

#-------------------------------------------------------------------------------
=begin pod
=head2 debug

There are many situations when exceptions are retrown within code of a callback method, Perl6 is sometimes not able to display the error properly. In those cases you need another way to display errors and show extra messages leading up to it. For instance turn debugging on.

  sub Gnome::N::debug ( Bool :$on, Bool :$off )

=item :on; turn debugging on
=item :!on; turn debugging off
=item :off; turn debugging off
=item :!off; turn debugging on

When both arguments are used, :on has preverence over :off. When no arguments are provided, the debugging is turned off.

The state is saved in `$Gnome::N::x-debug` and can be accessed directly to get
its state.

=end pod

class Gnome::N {
  our $Gnome::N::x-debug = False;

  our &Gnome::N::debug = sub ( Bool :$on, Bool :$off ) {

    # when both are undefined only return debug state
    if !$on.defined and !$off.defined {
      $Gnome::N::x-debug = False;
    }

    # when only $off is defined, set debug to its opposite
    elsif !$on.defined and $off.defined {
      $Gnome::N::x-debug = !$off;
    }

    # all other cases $on is defined and has preverence above $off
    else {
      $Gnome::N::x-debug = $on;
    }
  }
}

#-------------------------------------------------------------------------------
sub test-catch-exception ( Exception $e, Str $native-sub ) is export {

  note "\nError type: ", $e.WHAT if $Gnome::N::x-debug;
  #note "Error message: ", $e.message if $Gnome::N::x-debug;
  note "Thrown Exception:\n", $e if $Gnome::N::x-debug;

  given $e {

#TODO X::Method::NotFound
#     No such method 'message' for invocant of type 'Any'
#TODO Argument
#     Calling gtk_button_get_label(N-GObject, Str) will never work with declared signature (N-GObject $widget --> Str)
#TODO Return
#     Type check failed for return value

    # X::AdHoc
    when .message ~~ m:s/Native call expected return type/ {
      note "Wrong return type of native sub '$native-sub\(...\)'"
        if $Gnome::N::x-debug;
      die X::Gnome.new(
        :message("Wrong return type of native sub '$native-sub\(...\)'")
      );
    }

    # X::AdHoc, X::TypeCheck::Argument or some messages
    when X::TypeCheck::Argument ||
         .message ~~ m:s/will never work with declared signature/ ||
         .message ~~ m:s/Type check failed in binding/ {
      note .message if $Gnome::N::x-debug;
      die X::Gnome.new(:message(.message));
    }

    default {
      note "Could not find native sub '$native-sub\(...\)'"
        if $Gnome::N::x-debug;
      die X::Gnome.new(
        :message("Could not find native sub '$native-sub\(...\)'")
      );
    }
  }
}

#-------------------------------------------------------------------------------
sub test-call-without-natobj (
  Callable:D $found-routine, |c --> Any
) is export {

  note "Found sub $found-routine.gist()\( ", c>>.perl.join(', '), ');'
    if $Gnome::N::x-debug;
  $found-routine(|c) // Any
}

#-------------------------------------------------------------------------------
sub test-call ( Callable:D $found-routine, $gobject, |c --> Any ) is export {

#TODO would like to simplify but e.g. gtk_builder_new_from_string() in
# Gnome::Gtk3::Builder does not need a N-GObject inserted on 1st argument
# so need another test

  my List $sig-params = $found-routine.signature.params;
  note "Signature parameters: ", $sig-params[*] if $Gnome::N::x-debug;

  if +$sig-params and
# vvv like to have this part only
    # test for native object in any of the Gnome packages
    $sig-params[0].type.^name ~~ m/^ ['Gnome::G' .*?]? 'N-G' / {

    note "Found a sub with following arguments: ",
         $gobject, ', ', c>>.perl.join(', ') if $Gnome::N::x-debug;
    $found-routine( $gobject, |c) // Any
# ^^^
  }

  else {
    note "Found a sub with following arguments: ", c>>.perl.join(', ')
      if $Gnome::N::x-debug;
    $found-routine(|c) // Any
  }
}
