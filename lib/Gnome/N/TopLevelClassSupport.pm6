#TL:1:Gnome::N:TopLevelClassSupport:
use v6.d;

#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;

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
has UInt $!class-gtype;
has Str $!class-name;
has Str $!class-name-of-sub;


#`{{ !!!! DON'T DO THIS !!!!
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

  # check if a native object must be imported
  if ? %options<native-object> {

    # check if Raku object was provided instead of native object
    my $no = %options<native-object> // %options<widget>;
    if $no.^can('get-native-object') {
      # reference counting done automatically if needed
      # by the same child class where import is requested.
      $no .= get-native-object;
      note "native object extracted from raku object" if $Gnome::N::x-debug;
    }

    elsif $no.^name ~~ any(
      <Gnome::Glib::List::N-GList Gnome::Glib::SList::N-GSList>
    ) {
      note "native object is a list or slist" if $Gnome::N::x-debug;
      # no need to set '$no = N-GObject' because $!n-native-object is undefined
    }

    else {
      # reference counting done explicitly
      note "native object explicit referencing" if $Gnome::N::x-debug;
      $no = self.native-object-ref($no);
    }

    # The list classes may have an undefined structure and still be valid
    if ? $no or $no.^name ~~ any(
      <Gnome::Glib::List::N-GList Gnome::Glib::SList::N-GSList>
    ) {
      note "native object $no stored" if $Gnome::N::x-debug;
      $!n-native-object = $no;
      $!is-valid = True;
    }
  }
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
method FALLBACK ( $native-sub is copy, **@params is copy, *%named-params ) {

  state Hash $cache = %();

  note "\nSearch for .$native-sub\() in $!class-name following ", self.^mro
    if $Gnome::N::x-debug;

#  CATCH { test-catch-exception( $_, $native-sub); }
  CATCH { .note; die; }

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
  self.convert-to-natives( $s, @params);

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

#note "test-call: $s, $g-object-cast";
  test-call( $s, $g-object-cast, |@params, |%named-params)
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method set-class-info ( Str:D $!class-name ) {
  $!class-gtype = tlcs_type_from_name($!class-name)
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

  method get-class-gtype ( --> GType )
=end pod

method get-class-gtype ( --> GType ) {
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
multi method get-native-object ( Bool :$ref = True ) {    # --> N-Type

  # increase reference count by default
  $ref ?? self.native-object-ref($!n-native-object) !! $!n-native-object
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
    #self.clear-object; !!!! DON'T !!!!

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
    #self.clear-object; !!!! DON'T !!!!

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
    #self.clear-object; !!!! DON'T !!!!
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
    self.native-object-unref($!n-native-object) if $!n-native-object.defined;
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
method convert-to-natives ( Callable $s, @params ) {

  # get the parameter list of subroutine $s
  my Signature $s-sig = $s.signature;
#note "P: $s-sig.perl()";
  my Parameter @s-params = $s-sig.params;
#note "\@p: @params.perl()";
#note "P: @s-params.perl()";

  loop ( my Int $i = 0; $i < @params.elems; $i++ ) {
    my Str $s-param-type-name = @s-params[$i + 1].defined
                                ?? @s-params[$i + 1].type.^name
                                !! 'Unknown type';
    $*ERR.printf( "Substitution of parameter \[%d]: (%s), %s",
      $i, $s-param-type-name, @params[$i].^name
    ) if $Gnome::N::x-debug;

#`{{
    my Str $pname = @params[$i].^name;
    if $pname ~~
          m/^ Gnome '::' [
                 Gtk3 || Gdk3 || Glib || Gio || GObject || Pango || Cairo
              ] '::'
           /
       and $pname !~~ m/ '::' 'N-' / {
}}

    # check if this is a Gnome Rakue object. if so, get native object
    if @params[$i].can('get-native-object') {
      # no reference counting, object is used as an argument to the native
      # subs in this class tree
      @params[$i] = @params[$i].get-native-object(:!ref);
      $*ERR.printf( " --> %s\n", @params[$i].^name) if $Gnome::N::x-debug;
    }

    # check if enum. if so, get value, mostly an integer
    elsif @params[$i].can('enums') {
      @params[$i] = @params[$i].value;
      $*ERR.printf( " --> %s\n", @params[$i].^name) if $Gnome::N::x-debug;
    }

    # check if argument should be a real/double. if so, coerce input to Num
    elsif $s-param-type-name ~~ m/^ num / {
      @params[$i] .= Num;
      $*ERR.printf( " --> %s\n", @params[$i].^name) if $Gnome::N::x-debug;
    }
#`{{
    elsif @params[$i] ~~ Str {
      @params[$i] = explicitly-manage(@params[$i]);
      $*ERR.printf( " --> %s\n", @params[$i].^name) if $Gnome::N::x-debug;
    }
}}

    else {
      $*ERR.printf(": No conversion\n") if $Gnome::N::x-debug;
    }
  }
}

#-------------------------------------------------------------------------------
#--[ Internal use only ]--------------------------------------------------------
#-------------------------------------------------------------------------------
# Native to raku object wrap
# Useful to prevent circular dependencies and for late binding
method _wrap-native-type (
  Str:D $type where ?$type, N-GObject:D $no
  --> Any
) {
  # get class and wrap the native object in it
#note "type: $type";
  try require ::($type);
  if $Gnome::N::x-debug and ::($type) ~~ Failure {
    note "Failed to load $type!";
    ::($type).note;
  }

  require ::($type);
#note "sym: ", ::($type);
  ::($type).new(:native-object($no))
}

#-------------------------------------------------------------------------------
# Native to raku object wrap when type can be one of a few possible choices
# e.g. the GtkTreeView may return a GtkTreeModel which can be e.g. a
# GtkTreeStore or GtkListStore.
# That call would be like; ._wrap-native-type-from-no( $no, 'Gtk', 'Gtk3::')
method _wrap-native-type-from-no (
  N-GObject:D $no, Str:D $match = '', Str:D $replace = ''
  --> Any
) {
  my Str $native-name = tlcs_type_name_from_instance($no);
  return N-GObject unless ( ?$native-name and $native-name ne '<NULL-class>');

  if ?$match {
    $native-name ~~ s/$match/$replace/;
  }

  else {
    given $native-name {
      when /^ Gtk / { $native-name ~~ s/^ Gtk/Gtk3::/; }
      when /^ GdkX11 / { $native-name ~~ s/^ GdkX11/Gdk3::/; }
      when /^ GdkWayland / { $native-name ~~ s/^ GdkWayland/Gdk3::/; }
      when /^ Gdk / { $native-name ~~ s/^ Gdk/Gdk3::/; }
      when /^ Atk / { $native-name ~~ s/^ Atk/Atk::/; }

      # Checking other objects from GObject, Glib and Gio all start with 'G'
      # so it is difficult to map it to the proper raku object.
      #
      # However, wrapping like this is only used when there are multiple native
      # object types to return to the caller. This is mostly restricted to Gtk3
      # modules. The other reason to call this wrapper is to prevent circular
      # dependencies which sometimes happen in Gdk3 modules.
      #
      # The rest must cope with the $match and $replace variables or solve it
      # by using 'my Xyz $xyz .= new(:native-object($no))' or do the require
      # trick used below.

#      when /^ G / { $native-name ~~ s/^ /::/; }
#      when /^  / { $native-name ~~ s/^ /::/; }
    }
  }

  my Str $type = [~] 'Gnome', '::', $native-name;
  note "wrap $native-name in $type" if $Gnome::N::x-debug;

  # get class and wrap the native object in it
  require ::($type);
  my $class = ::($type);
  $class.new(:native-object($no))
}

#-------------------------------------------------------------------------------
method _get_no_type_info (  N-GObject:D $no, Str :$check --> List ) {
  ( my Str $no-type-name = tlcs_type_name_from_instance($no),
    ? $check
      ?? (? tlcs_type_check_instance_is_a( $no, tlcs_type_from_name($check))
           ?? "$no-type-name is a $check"
           !! "$no-type-name is not a $check"
         )
      !! 'no check of type',
  )
}

#-------------------------------------------------------------------------------
# Purpose to invalidate an object after some operation such as .destroy(). Only
# for internal use!
method _set_invalid ( ) {
  $!is-valid = False;
  $!n-native-object = Nil;
}

#-------------------------------------------------------------------------------
### test for substite FALLBACK without search
#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
#
# This method is like the Fallback method. However, it does not search for the
# native subroutine. The routine must be provided to this method. Its purpose
# is to call the method directly from the classes which will skip the search
# process and saves a lot of time. For example, the AboutDialog now has methods
# for almost all native subs. The benchmark run over all the subroutines shows
# about 8 times speed increase.
# See also '... gnome-gtk3/xt/Benchmarking/Modules/AboutDialog.raku'.
#
# Do not cast when the class is a leaf. Do not convert when no parameters or
# easy to coerse by Raku like Int, Enum and Str. When both False, make call
# directly.
method _f ( Str $sub-class? --> Any ) {

  # cast to other gtk object type if the found subroutine is from another
  # gtk object type than the native object stored at $!n-native-object.
  # This happens e.g. when a Gnome::Gtk::Button object uses gtk-widget-show()
  # which belongs to Gnome::Gtk::Widget.
  #
  # Call the method only from classes where all variables are defined!
  my Any $g-object-cast;
  if ?$sub-class and $!class-name ne $sub-class {
    $g-object-cast = tlcs_type_check_instance_cast(
      $!n-native-object, $!class-gtype
    );
  }

  else {
    $g-object-cast = $!n-native-object;
  }

#note "test-call: $s.gist(), $g-object-cast.gist()";
  $g-object-cast
}

#-------------------------------------------------------------------------------
#--[ some necessary native subroutines ]----------------------------------------
#-------------------------------------------------------------------------------
# These subs belong to Gnome::GObject::Type but is needed here. To avoid
# circular dependencies, the subs are redeclared here for this purpose
sub tlcs_type_from_name ( Str $name --> GType )
  is native(&gobject-lib)
  is symbol('g_type_from_name')
  { * }

sub tlcs_type_name ( GType $type --> Str )
  is native(&gobject-lib)
  is symbol('g_type_name')
  { * }

sub tlcs_type_check_instance_cast (
  N-GObject $instance, GType $iface_type --> N-GObject
) is native(&gobject-lib)
  is symbol('g_type_check_instance_cast')
  { * }

sub tlcs_type_name_from_instance ( N-GObject $instance --> Str )
  is native(&gobject-lib)
  is symbol('g_type_name_from_instance')
  { * }

sub tlcs_type_check_instance_is_a (
  N-GObject $instance, GType $iface_type --> gboolean
) is native(&gobject-lib)
  is symbol('g_type_check_instance_is_a')
  { * }
