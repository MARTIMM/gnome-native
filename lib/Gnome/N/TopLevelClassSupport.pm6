#TL:1:Gnome::N:TopLevelClassSupport:
use v6.d;

#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
#`{{
use Gnome::N::N-GError;
use Gnome::N::N-GList;
use Gnome::N::N-GObject;
use Gnome::N::N-GOptionContext;
use Gnome::N::N-GSList;
use Gnome::N::N-GVariant;
use Gnome::N::N-GVariantBuilder;
use Gnome::N::N-GVariantIter;
use Gnome::N::N-GVariantType;
}}

#-------------------------------------------------------------------------------
unit class Gnome::N::TopLevelClassSupport;
#`{{
subset N-Type is export where
  # Structures for Gnome::Glib
  N-GError | N-GList | N-GOptionContext | N-GSList |
  N-GVariant | N-GVariantBuilder | N-GVariantIter | N-GVariantType |

  # Structures for Gnome::Gobject
  N-GObject
;
}}

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


#`{{
#-------------------------------------------------------------------------------
# this new() method is defined to cleanup first in case of an assignement
# like '$c .= new(...);', the native object, if any must be cleared first.
multi method new ( |c ) {

  self.clear-object if self.defined;
  self.bless(|c);
}
}}

#-------------------------------------------------------------------------------
=begin pod
=head1 Methods
=head2 new

Please note that this class is mostly not instantiated directly but is used indirectly when child classes are instantiated.

=begin comment
=head3 multi method new ( )

Create an empty object

=end comment

=head3 multi method new ( :$native-object! )

Create a Raku object using a native object from elsewhere. $native-object can be a N-GObject or a Raku object like C< Gnome::Gtk3::Button>.

  # Some set of radio buttons grouped together
  my Gnome::Gtk3::RadioButton $rb1 .= new(:label('Download everything'));
  my Gnome::Gtk3::RadioButton $rb2 .= new(
    :group-from($rb1), :label('Download core only')
  );

  # Get all radio buttons in the group of button $rb2
  my Gnome::GObject::SList $rb-list .= new(:native-object($rb2.get-group));
  loop ( Int $i = 0; $i < $rb-list.g_slist_length; $i++ ) {
    # Get button from the list
    my Gnome::Gtk3::RadioButton $rb .= new(
      :native-object($rb-list.nth-data-gobject($i))
    );

    # If radio button is selected (=active) ...
    if $rb.get-active == 1 {
      ...

      last;
    }
  }

=end pod

#TM:2:new(:native-object):*
submethod BUILD ( *%options ) {

  # check GTK+ init except when GtkApplication / GApplication is used. They have
  # to inject this option in the .new() method of their class. Also the child
  # classes of those application modules should inject it.
  if not $gui-initialized #`{{and !%options<skip-init>}} {
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

#note "Opts: ", %options.keys;

  # this class is always the first to initialize, therefore when
  # 'my Xyz $xyz .= new(...);' is used, the original native object
  # must be cleaned up before we can continue.
  self.clear-object;

  # check if a native object must be imported
  if ? %options<native-object> or ? %options<widget> {

    Gnome::N::deprecate(
      '.new(:widget)', '.new(:native-object)', '0.17.0', '0.18.0'
    ) if ?%options<widget>;

    # check if there are other options, they cannot be combined
    if %options.elems > 1 {
      die X::Gnome.new(
        :message('with :native-object, no other named arguments allowed')
      );
    }

    # check if Raku object was provided instead of native object
    my $no = %options<native-object> // %options<widget>;
    if $no.^can('get-native-object') {
      $no .= get-native-object;
      note "native object extracted from raku object" if $Gnome::N::x-debug;
    }

    elsif $no ~~ NativeCall::Types::Pointer {
      $no = nativecast( N-GObject, $no);
      note "native pointer cast to N-GObject" if $Gnome::N::x-debug;
    }


#`{{TODO check on proper type of native object

... What about user class inheriting from gtk classes?
my Str $name = $no.^name;
$name ~~ s/ Gnome '::' //;
$name ~~ s/ [ Glib || GObject || Gio ] '::' /G/;
my Int $type = tlcs_type_from_name($name);

my Int $no-type = ...
if $no-type != $type {

}

}}

#    self.clear-object if ? $!n-native-object;

    # The list classes may have an undefined structure and still be valid
    if ? $no or $no.^name ~~ any(
      <Gnome::Glib::List::N-GList Gnome::Glib::SList::N-GSList>
    ) {
      note "native object $no stored" if $Gnome::N::x-debug;
      $!n-native-object = $no;
      $!is-valid = True;
    }
#note "\ntl \$no = ", $no.perl;
#note "tl :native-object = ", $!n-native-object.perl;
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
  # a Gtk3::SomeThing or other *::SomeThing object.
  self.convert-to-natives(@params);

  # cast to other gtk object type if the found subroutine is from another
  # gtk object type than the native object stored at $!n-native-object.
  # This happens e.g. when a Gnome::Gtk::Button object uses gtk-widget-show()
  # which belongs to Gnome::Gtk::Widget.
  my Any $g-object-cast;

  #TODO Not all classes have $!gtk-class-* defined so we need to test it
  if $!n-native-object ~~ N-GObject and
     ? $!class-gtype and ?$!class-name and ?$!class-name-of-sub and
     $!class-name ne $!class-name-of-sub {

    note "Cast $!class-name to $!class-name-of-sub" if $Gnome::N::x-debug;

    $g-object-cast = tlcs_type_check_instance_cast(
      $!n-native-object, $!class-gtype
    );
  }

  else {
    $g-object-cast = $!n-native-object; #type-cast($!n-native-object);
  }

  test-call( $s, $g-object-cast, |@params, |%named-params)
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
method get-native-object ( ) {    # --> N-Type

  # increase reference count when object is copied
#  my Any $no = self.native-object-ref($!n-native-object);
#  $no # // $!n-native-object

  self.native-object-ref($!n-native-object)
}

#-------------------------------------------------------------------------------
# no reference counting, e.g. when object is used for subs in this class tree
method get-native-object-no-reffing ( ) {

  $!n-native-object
}

#-------------------------------------------------------------------------------
method set-native-object ( $native-object ) {

  # only change when native object is defined
  if ? $native-object {

    # if there was a valid native object, we must clear it first before
    # overwriting the local native object
    self.clear-object;

    # if higher level object then extract native object from it
    my Any $no = $native-object;
    #$no = nativecast( Pointer, $native-object.get-native-object)
    $no = $native-object.get-native-object
      if $native-object.^can('get-native-object');

    $!n-native-object = $no;
    $!is-valid = True;
  }

  # The list classes may have an undefined structure and still be valid
  elsif $native-object.^name ~~ any(
    <Gnome::Glib::List::N-GList Gnome::Glib::SList::N-GSList>
  ) {
    # if there was a valid native object, we must clear it first before
    # overwriting the local native object
    self.clear-object;

    $!n-native-object = $native-object;
    $!is-valid = True;
  }

  else {
    $!is-valid = False;
  }
}

#-------------------------------------------------------------------------------
# no example case yet to use this method
method set-native-object-no-reffing ( $native-object ) {

  if ? $native-object {
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
#TM:1:is-valid
# doc of $!is-valid defined above
=begin pod
=head2 is-valid

Returns True if native error object is valid, otherwise C<False>.

  method is-valid ( --> Bool )

=end pod

#-------------------------------------------------------------------------------
#TM:1:clear-object
=begin pod
=head2 clear-object

Clear the error and return data to memory pool. The error object is not valid after this call and C<is-valid()> will return C<False>.

  method clear-object ()

=end pod

method clear-object ( ) {
  if $!is-valid {
    self.native-object-unref($!n-native-object);
    $!is-valid = False;
    $!n-native-object = Nil;
  }
}

#`{{
#-------------------------------------------------------------------------------
method clear-object-no-reffing ( ) {
  if $!is-valid {
    $!is-valid = False;
    $!n-native-object = Nil;
  }
}
}}

#-------------------------------------------------------------------------------
# The array @params is modified in place when a higher class object must be
# converted to a native object held in that object.
method convert-to-natives ( @params ) {

  loop ( my Int $i = 0; $i < @params.elems; $i++ ) {
    $*ERR.printf( "Substitution of parameter \[%d]: %s", $i, @params[$i].^name)
      if $Gnome::N::x-debug;

#`{{
    my Str $pname = @params[$i].^name;
    if $pname ~~
          m/^ Gnome '::' [
                 Gtk3 || Gdk3 || Glib || Gio || GObject || Pango || Cairo
              ] '::'
           /
       and $pname !~~ m/ '::' 'N-' / {
}}
    if @params[$i].can('get-native-object-no-reffing') {
      # no reference counting, object is used as an argument to the native
      # subs in this class tree
      @params[$i] = @params[$i].get-native-object-no-reffing;
      $*ERR.printf( " --> %s\n", @params[$i].^name) if $Gnome::N::x-debug;
    }

    else {
      $*ERR.printf(": No conversion\n") if $Gnome::N::x-debug;
    }
  }
}

#-------------------------------------------------------------------------------
# some necessary native subroutines

# These subs belong to Gnome::GObject::Type but is needed here. To avoid
# circular dependencies, the subs are redeclared here for this purpose
sub tlcs_type_from_name ( Str $name --> uint64 )
  is native(&gobject-lib)
  is symbol('g_type_from_name')
  { * }

sub tlcs_type_name ( uint64 $type --> Str )
  is native(&gobject-lib)
  is symbol('g_type_name')
  { * }

sub tlcs_type_check_instance_cast (
  N-GObject $instance, uint64 $iface_type --> N-GObject
) is native(&gobject-lib)
  is symbol('g_type_check_instance_cast')
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
