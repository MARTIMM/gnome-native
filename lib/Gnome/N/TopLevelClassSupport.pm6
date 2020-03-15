#TL:1:Gnome::N:TopLevelClassSupport:
use v6.d;

#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;

#-------------------------------------------------------------------------------
unit class Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
# this native object is used by the toplevel class and its descendent classes.
# the native type is always the same as set by all classes inheriting from
# this toplevel class.
has $!n-native-object;

# this readable variable is checked to see if $!n-native-object is valid.
has Bool $.is-valid = False;

# keep track of native class types and names
has Int $!class-gtype;
has Str $!class-name;
has Str $!class-name-of-sub;

# check on native library initialization. must be global to all of the
# TopLevelClassSupport classes. the
my Bool $gui-initialized = False;

#-------------------------------------------------------------------------------
# this new() method is defined to cleanup first in case of an assignement
# like '$c .= new(...);', the native object, if any must be cleared first.
multi method new ( |c ) {

#note "\nNew tl: ", self.defined, ', ', c.perl;

  self.clear-object if self.defined;
  self.bless(|c);
}

#-------------------------------------------------------------------------------
submethod BUILD ( *%options ) {

#note "Build top: ", %options.perl;

  # check GTK+ init except when GtkApplication / GApplication is used. They have
  # to inject this option in the .new() method of their class. Also the child
  # classes of those application modules should inject it.
  if not $gui-initialized and !%options<skip-init> {
    # must setup gtk otherwise Raku will crash
    my $argc = CArray[int32].new;
    $argc[0] = 1 + @*ARGS.elems;

    my $arg_arr = CArray[Str].new;
    my Int $arg-count = 0;
    $arg_arr[$arg-count++] = $*PROGRAM.Str;
    for @*ARGS -> $arg {
      $arg_arr[$arg-count++] = $arg;
    }

    my $argv = CArray[CArray[Str]].new;
    $argv[0] = $arg_arr;

    # call gtk_init_check
    tlcs_init_check( $argc, $argv);
    $gui-initialized = True;
  }

  # check if a native object must be imported
  if ? %options<native-object> {

    # check if Raku object was provided instead of native object
    my $no = %options<native-object>;
    $no .= get-native-object if $no.^can('get-native-object');

    # when native object is defined, check if object is of the same type
    # as type of the new native object. This prevents storing a N-GError
    # on a N-GObject.
    if ? $!n-native-object and $no.^name eq $!n-native-object.^name or
       ! $!n-native-object {

      $!n-native-object = $no;
      $!is-valid = True;
    }

#note 'opts left: ', (%options.perl, %options.keys, %options.elems).join(', ');
    if %options.elems > 1 {
      die X::Gnome.new(
        :message('with :native-object, no other named arguments allowed')
      );
    }
  }
}

#-------------------------------------------------------------------------------
submethod DESTROY ( ) {

  self.native-object-unref($!n-native-object) if $!is-valid;
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
#
# Fallback method to find the native subs which then can be called as if they
# were methods. Each class must provide their own '_fallback()' method which,
# when nothing found, must call the parents _fallback with 'callsame()'.
# The subs in some class all start with some prefix which can be left out too
# provided that the _fallback functions must also test with an added prefix.
# So e.g. a sub 'gtk_label_get_text' defined in class GtlLabel can be called
# like '$label.gtk_label_get_text()' or '$label.get_text()'. As an extra
# feature dashes can be used instead of underscores, so '$label.get-text()'
# works too.
method FALLBACK ( $native-sub is copy, *@params is copy, *%named-params ) {

  state Hash $cache = %();

  note "\nSearch for .$native-sub\() in $!class-name following ", self.^mro
    if $Gnome::N::x-debug;

  CATCH { test-catch-exception( $_, $native-sub); }

  # convert all dashes to underscores if there are any.
  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-').defined;

  my Callable $s;

  # call the _fallback functions of this class's children starting
  # at the bottom
  if $cache{$!class-name}{$native-sub}:exists {

    note "Use cached sub address of .$native-sub\() in $!class-name"
      if $Gnome::N::x-debug;

    $s = $cache{$!class-name}{$native-sub};
  }

  else {
    $s = self._fallback($native-sub);

    if $s.defined {
      note "Found $native-sub in $!class-name-of-sub for $!class-name"
        if $Gnome::N::x-debug;
      $cache{$!class-name}{$native-sub} = $s;
    }

    else {
      die X::Gnome.new(:message("Native sub '$native-sub' not found"));
    }
  }

  # user convenience substitutions to get a native object instead of
  # a GtkSomeThing or other *SomeThing object.
  convert-to-natives(@params);

  # cast to other gtk object type if the found subroutine is from another
  # gtk object type than the native object stored at $!n-native-object.
  # This happens e.g. when a Gnome::Gtk::Button object uses gtk-widget-show()
  # which belongs to Gnome::Gtk::Widget.
  my $g-object-cast;

  #TODO Not all classes have $!gtk-class-* defined so we need to test it
  if ?$!class-gtype and ?$!class-name and ?$!class-name-of-sub and
     $!class-name ne $!class-name-of-sub {

    note "Cast $!class-name to $!class-name-of-sub"
      if $Gnome::N::x-debug;

    $g-object-cast = Gnome::GObject::Type.new().check-instance-cast(
      $!n-native-object, $!class-gtype
    );
  }


  test-call( $s, $g-object-cast // $!n-native-object, |@params, |%named-params)
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method set-class-info ( Str:D $!class-name ) {
  $!class-gtype = tlcs_type_from_name($!class-name);
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method set-class-name-of-sub ( Str:D $!class-name-of-sub ) { }

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method get-class-name-of-sub ( --> Str ) { $!class-name-of-sub }

#-------------------------------------------------------------------------------
=begin pod
=head2 get-class-gtype

Return class's type code after registration. this is like calling Gnome::GObject::Type.new().g_type_from_name(GTK+ class type name).

  method get-class-gtype ( --> Int )
=end pod

method get-class-gtype ( --> Int ) {
  $!class-gtype
}

#-------------------------------------------------------------------------------
=begin pod
=head2 get-class-name

Return native class name.

  method get-class-name ( --> Str )
=end pod

method get-class-name ( --> Str ) {
  $!class-name
}

#-------------------------------------------------------------------------------
method get-native-object ( ) {

#note "get-native-object: ", $!n-native-object // '-';

  # increase reference count when object is copied
  self.native-object-ref($!n-native-object) if ? $!n-native-object;

  $!n-native-object.clone
}

#-------------------------------------------------------------------------------
method set-native-object ( $native-object ) {

#note "set-native-object: ", $native-object // '-',
#     ', ', $!n-native-object // '-';

  # only change when native object is defined
  if ? $native-object {

    # if higher level object then extract native object from it
    my $no = $native-object;
    $no .= get-native-object if $no.^can('get-native-object');

    # if there was a valid native object, we must clear it first before
    # overwriting the local native object
    self.clear-object if $!is-valid;

    $!n-native-object = $native-object;
    $!is-valid = True;
  }

  else {
    $!is-valid = False;
  }
}

#-------------------------------------------------------------------------------
method get-native-object-no-reffing ( ) {

#note "get-native-object-no-reffing: ", $!n-native-object // '-';

  $!n-native-object
}

#-------------------------------------------------------------------------------
method set-native-object-no-reffing ( $native-object ) {

#note "set-native-object-no-reffing: ",
#     $native-object // '-', ', ', $!n-native-object // '-';

  if $native-object.defined {
    self.clear-object;
    $!n-native-object = $native-object;
    $!is-valid = True;
  }
}

#-------------------------------------------------------------------------------
method native-object-ref ( $n-native-object ) { !!! }

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) { !!! }

#-------------------------------------------------------------------------------
#method native-clear-object ( $n-native-object ) { !!! }

#-------------------------------------------------------------------------------
method clear-object ( ) {
  if $!is-valid {
#    self.native-clear-object($!n-native-object);
    self.native-object-unref($!n-native-object);
    $!is-valid = False;
    $!n-native-object = Nil;
  }
}

#-------------------------------------------------------------------------------
method clear-object-no-reffing ( ) {
  if $!is-valid {
    $!is-valid = False;
    $!n-native-object = Nil;
  }
}


#-------------------------------------------------------------------------------
# some necessary native subroutines

# this sub belongs to Gnome::GObject::Type but is needed here. To avoid
# circular dependencies, the sub is redeclared here for this purpose
sub tlcs_type_from_name ( Str $name --> uint64 )
  is native(&gobject-lib)
  is symbol('g_type_from_name')
  { * }

sub tlcs_type_name ( uint64 $type --> Str )
  is native(&gobject-lib)
  is symbol('g_type_name')
  { * }

#-------------------------------------------------------------------------------
# this sub belongs to Gnome::Gtk3::Main but is needed here. To avoid
# circular dependencies, the sub is redeclared here for this purpose
sub tlcs_init_check (
  CArray[int32] $argc, CArray[CArray[Str]] $argv
  --> int32
) is native(&gtk-lib)
  is symbol('gtk_init_check')
  { * }
