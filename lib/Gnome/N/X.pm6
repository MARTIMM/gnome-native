#TL:1:Gnome::N::X

use v6;

#-------------------------------------------------------------------------------
class X::Gnome is Exception {
  has $.message;

  #TM:1:new():
  submethod BUILD ( Str:D :$!message ) { }
}

#-------------------------------------------------------------------------------
class Gnome::N {

#-------------------------------------------------------------------------------
=begin pod
=head2 Gnome::N::debug

There are many situations when exceptions are retrown within code of a callback method, Raku is sometimes not able to display the error properly. In those cases you need another way to display errors and show extra messages leading up to it. For instance turn debugging on.

  sub Gnome::N::debug ( Bool :$on, Bool :$off )

=item :on; turn debugging on
=item :!on; turn debugging off
=item :off; turn debugging off
=item :!off; turn debugging on

When both arguments are used, :on has preverence over :off. When no arguments are provided, the debugging is turned off.

The state is saved in `$Gnome::N::x-debug` and can be accessed directly to get
its state.

=end pod

  #TS:1:x-debug:
  #TM:1:debug():
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

#-------------------------------------------------------------------------------
=begin pod
=head2 Gnome::N::deprecate

Set a deprecation message when the trait DEPRECATED on classes and methods is not sufficient enaugh. Like those, a message is generated when the X module ends, i.e. when your application exits (hopefully ;-).

  sub Gnome::N::deprecate (
    Str $old-method, Str $new-method,
    Str $since-version, Str $remove-version
  )

=item $old-method; Method as it was used.
=item $new-method; New method or way to use.
=item $since-version; When it was deprecated. Version is from package wherein the module/class and method is defined.
=item $remove-version; Version of package when the method will be removed.

=end pod

  #TM:1:deprecate():
  my $x-deprecated = %();
  our &Gnome::N::deprecate = sub (
    Str $old-method, Str $new-method,
    Str $deprecate-version, Str $remove-version
  ) {

    my Str $cf-file;
    my $cf-line;
    for ^10 -> $cfi {
      $cf-file = callframe($cfi).file;
      next if $cf-file ~~ m/ 'Gnome::' || '/Mu.' || '/moar' /;

      $cf-line = callframe($cfi).line();
      last;
    }

    # found this one before?
    if !$x-deprecated{$cf-file}{"$old-method $new-method"} {
      $cf-file ~~ s/ \( <-[)]>+ \) .* //;
      $cf-file ~~ s/$*HOME/~/;

      my %message-data = %(
        :$cf-file, :$cf-line, :$old-method, :$new-method,
        :$deprecate-version, :$remove-version
      );

      $x-deprecated{$cf-file}{"$old-method $new-method"} = %message-data;
    }

    else {
      my %message-data := $x-deprecated{$cf-file}{"$old-method $new-method"};
      %message-data{'cf-line'} ~= ", $cf-line"
        unless %message-data{'cf-line'} ~~ m/ <?wb> $cf-line <?wb> /;
    }
  }

  # if this object ends throw out the deprecation messages if any
  END {
    if ?$x-deprecated {
      note '=' x 80; #, '  Deprecations found at';
      for $x-deprecated.keys.sort -> $file {
        for $x-deprecated{$file}.keys.sort -> $m {
          my %message-data := $x-deprecated{$file}{$m};
          note Q:qq:to/EOTXT/;
            Method '%message-data{"old-method"}' is deprecated in favor of '%message-data{"new-method"}'
            Deprecated since version %message-data{"deprecate-version"} and will be removed at version %message-data{"remove-version"}
            Found in file %message-data{'cf-file'} at lines %message-data{'cf-line'}
          EOTXT

          note '-' x 80;
        }
      }

      # and when it ends more than once, clear it just in case
      $x-deprecated = %();
    }
  }
}

#-------------------------------------------------------------------------------
sub test-catch-exception ( Exception $e, Str $native-sub ) is export {

  note "\nError type: ", $e.WHAT; # if $Gnome::N::x-debug;
  #note "Error message: ", $e.message if $Gnome::N::x-debug;
  note "Thrown Exception:\n", $e; # if $Gnome::N::x-debug;

  given $e {

#TODO X::Method::NotFound
#     No such method 'message' for invocant of type 'Any'
#TODO Argument
#     Calling gtk_button_get_label(N-GObject, Str) will never work with declared signature (N-GObject $widget --> Str)
#TODO Return
#     Type check failed for return value

    # X::AdHoc
    when .message ~~ m:s/Native call expected return type/ {
      note "Wrong return type of native sub '$native-sub\(...\)'"; # if $Gnome::N::x-debug;
      die X::Gnome.new(
        :message("Wrong return type of native sub '$native-sub\(...\)'")
      );
    }

    # X::AdHoc, X::TypeCheck::Argument or some messages
    when X::TypeCheck::Argument ||
         .message ~~ m:s/will never work with declared signature/ ||
         .message ~~ m:s/Type check failed in binding/ {
      note .message; # if $Gnome::N::x-debug;
      die X::Gnome.new(:message(.message));
    }

    default {
      note "Could not find native sub '$native-sub\(...\)'"; #if $Gnome::N::x-debug;
      die X::Gnome.new(
        :message("Could not find native sub '$native-sub\(...\)'")
      );
    }
  }
}

#-------------------------------------------------------------------------------
sub test-call-without-natobj ( Callable:D $found-routine, |c ) is export {

  note "\nCalling sub $found-routine.gist()\(\n  ",
    c>>.perl.join(",\n  "), "\n);" if $Gnome::N::x-debug;
  $found-routine(|c)
}

#-------------------------------------------------------------------------------
sub test-call ( Callable:D $found-routine, $gobject, |c ) is export {

#TODO would like to simplify but e.g. gtk_builder_new_from_string() in
# Gnome::Gtk3::Builder does not need a N-GObject inserted on 1st argument
# so need another test

  my List $sig-params = $found-routine.signature.params;
#  note "\nSignature parameters: ", $sig-params[*] if $Gnome::N::x-debug;

  my $result;
  if +$sig-params and
# vvv like to have this part only
    # test for native object in any of the Gnome packages
    $sig-params[0].type.^name ~~ m/^ ['Gnome::G' .*?]? 'N-G' / {

    note "\nCalling sub $found-routine.gist()\(\n  ",
         ( $gobject, |c)>>.perl.join(",\n  "), "\n);" if $Gnome::N::x-debug;

    $result = $found-routine( $gobject, |c)
# ^^^
  }

  else {
    note "Calling sub $found-routine.gist()\(\n  ",
      c>>.perl.join(",\n  "), "\n);" if $Gnome::N::x-debug;

    $result = $found-routine(|c)
  }

#note "test-call R: {$result//'-'}";
  $result
}

#`{{
#-------------------------------------------------------------------------------
# Called from FALLBACK methods in toplevel classes. The array @params is
# modified in place when a higher class object is converted to a native object
# User convenience substitutions to get a native object instead of
# a GtkSomeThing or other *SomeThing object.
sub convert-to-natives ( @params ) is export {

  loop ( my Int $i = 0; $i < @params.elems; $i++ ) {
    $*ERR.printf( "Substitution of parameter \[%d]: %s", $i, @params[$i].^name)
      if $Gnome::N::x-debug;

#`{{
    if @params[$i].^name ~~
          m/^ 'Gnome::' [
                 Gtk3 || Gdk3 || Glib || Gio || GObject || Pango
               ] '::' / {

      @params[$i] = @params[$i].get-native-object;
      $*ERR.printf( " --> %s\n", @params[$i].^name) if $Gnome::N::x-debug;
    }
}}

#    if @params[$i].can('get-native-object-no-reffing') {
    if @params[$i].can('get-native-object') {
      # no reference counting, object is used as an argument to the native
      # subs in this class tree
#      @params[$i] = @params[$i].get-native-object-no-reffing;
      @params[$i] = @params[$i].get-native-object;
      $*ERR.printf( " --> %s\n", @params[$i].^name) if $Gnome::N::x-debug;
    }

    elsif @params[$i].can('enums') {
      @params[$i] = @params[$i].value;
      $*ERR.printf( " --> %s\n", @params[$i].^name) if $Gnome::N::x-debug;
    }

    else {
      $*ERR.printf(": No conversion\n") if $Gnome::N::x-debug;
    }
  }
}
}}
