#TL:1:Gnome::N:TopLevelClassSupport:
use v6.d;

#-------------------------------------------------------------------------------
=begin pod

=head1 Gnome::N::TopLevelClassSupport

Top most class providing internally used methods and subroutines.


=head1 Description

The B<Gnome::N::TopLevelClassSupport> is the class at the top of the food chain. Most, if not all, are inheriting from this class. Its purpose is to provide convenience methods, processing and storing native objects, etcetera.

=head1 Synopsis
=head2 Declaration

  unit class Gnome::N::TopLevelClassSupport;


=end pod

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

# type is Gnome::Gtk3::Builder. Cannot load module because of circular dep.
# value is set by GtkBuilder via _set-builder(). There might be more than one.
my Array $builders = [];

# When a builder is set with a name set to ___Test_Builder__ it means that
# the Gnome::T module is used and the builder is created there.
my Bool $test-mode;
my Int $widget-count = 0;

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
=head3 default, no options

Create an empty object

=end comment

=head3 :native-object

Create a Raku object using a native object from elsewhere. $native-object can be a N-GObject or a Raku object like C< Gnome::Gtk3::Button>.

  method new ( :$native-object! )

=head3 Example

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
      :native-object(native-cast( N-GObject, $rb-list.nth($i)))
    );

    # If radio button is selected (=active) ...
    if $rb.get-active {
      ...

      last;
    }
  }

=end pod

#TM:2:new(:native-object):*
submethod BUILD ( *%options ) {
#note 'TopLevelClassSupport o: ', %options.gist;

  # check if a native object must be imported
  if ? %options<native-object> {

    # check if Raku object was provided instead of native object
    my $no = %options<native-object>;
    if $no.^can('_get-native-object') {
      # reference counting done automatically if needed
      # by the same child class where import is requested.
      $no .= _get-native-object;
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

  # cairo does not use the type system
  $!class-name //= '-';
  $!class-name-of-sub //= '-';

  note "\nSearch for .$native-sub\() in $!class-name following ",
    self.^mro if $Gnome::N::x-debug;

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

    $g-object-cast = _check_instance_cast(
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
#TM:1:N-GObject:
=begin pod
=head2 N-GObject

Method to get the native object wrapped in the Raku objects.

Example where the native object is retrieved from a B<Gnome::Gtk3::Window> object.
=begin code
  my Gnome::Gtk3::Window $w;
  my N-GObject() $no = $w;
=end code

=begin code
  method N-GObject ( --> N-GObject )
=end code

=end pod

method N-GObject ( --> Any ) {
  note "Coercing to N-GObject from ", self.^name if $Gnome::N::x-debug;
  self.get-native-object()
}

#-------------------------------------------------------------------------------
#TM:1:COERCE:
=begin pod
=head2 COERCE

Method to wrap a native object into a Raku object

Example;
=begin code
  my N-GObject $no = …;
  my Gnome::Gtk3::Window() $w = $no;
=end code

=begin code
  method COERCE( $no --> Any )
=end code

=end pod
method COERCE( $no --> Any ) {
  note "Coercing from N-GObject to ", self.^name if $Gnome::N::x-debug;
  self._wrap-native-type( self.^name, $no)
}

#`{{
#-------------------------------------------------------------------------------
method CALL-ME( *@a, *%o ) {
  note 'args: ', @a.gist;
  note 'opts: ', %o.gist;
}
}}

#-------------------------------------------------------------------------------
#TM:1:get-class-gtype:
=begin pod
=head2 get-class-gtype

Get type code of this native object which is set when object was created.

  method get-class-gtype ( --> GType )

=end pod

method get-class-gtype ( --> GType ) {
  $!class-gtype
}

#-------------------------------------------------------------------------------
#TM:1:get-class-name:
=begin pod
=head2 get-class-name

Return native class name.

  method get-class-name ( --> Str )
=end pod

method get-class-name ( --> Str ) {
  $!class-name
}

#`{{
#-------------------------------------------------------------------------------
# no example case yet to use this method
method _set-native-object-no-reffing ( $native-object ) {

  if ? $native-object {
#TODO Args to subs are given using ._get-native-object-no-reffing(). Perhaps
# it should increment reference count, then it is possible here to clean it
# before setting a new object.
#self.clear-object; !!!! DON'T !!!!
    $!n-native-object = $native-object;
    $!is-valid = True;
  }
}
}}

#-------------------------------------------------------------------------------
#TM:1:native-object-ref:
=begin pod
=head2 native-object-ref

Absolute method needed to be defined in all child classes to do reference count administration.

  method native-object-ref ( $n-native-object ) { !!! }

=end pod

method native-object-ref ( $n-native-object ) { !!! }

#-------------------------------------------------------------------------------
#TM:1:native-object-unref:
=begin pod
=head2 native-object-unref

Absolute method needed to be defined in all child classes to do reference count administration.

  method native-object-unref ( $n-native-object ) { !!! }

=end pod

method native-object-unref ( $n-native-object ) { !!! }

#-------------------------------------------------------------------------------
#TM:1:is-valid
# doc of $!is-valid defined above
=begin pod
=head2 is-valid

Returns True if native object is valid. When C<False>, the native object is undefined and errors will occur when this instance is used.

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
    if @params[$i].can('_get-native-object') {
      # no reference counting, object is used as an argument to the native
      # subs in this class tree
      @params[$i] = @params[$i]._get-native-object(:!ref);
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
#TM:1:_get-native-object:
=begin pod
=head1 Internally used methods
=head2 _get-native-object

Get the native object with reference counting by default. When $ref is C<False>, reference counting is not done. When False, it is the same as calling C<_get-native-object-no-reffing()>.

  method _get-native-object ( Bool :$ref = True )

=end pod

multi method _get-native-object ( Bool :$ref = True ) {    # --> N-Type
  $ref ?? self.native-object-ref($!n-native-object) !! $!n-native-object
}

#TODO this sub will dissappear after a few releases now 0.19.0
multi method get-native-object ( Bool :$ref = True ) {    # --> N-Type
  $ref ?? self.native-object-ref($!n-native-object) !! $!n-native-object
}

#-------------------------------------------------------------------------------
#TM:1:_get-native-object-no-reffing:
=begin pod
=head2 _get-native-object-no-reffing

Get the native object without reference counting.

  method _get-native-object-no-reffing ( )

=end pod

method _get-native-object-no-reffing ( ) {
  $!n-native-object
}

#TODO this sub will dissappear after a few releases now 0.19.0
method get-native-object-no-reffing ( ) {
  $!n-native-object
}

#-------------------------------------------------------------------------------
#TM:1:_set-native-object:
=begin pod
=head2 _set-native-object

Set the native object. This happens mostly when a native object is created.

  method _set-native-object ( $native-object )

=end pod
method _set-native-object ( $native-object ) {

#TODO if previous no is defined, should it be unreffed?

  # only change when native object is defined
  if ? $native-object {

    # if there was a valid native object, we must clear it first before
    # overwriting the local native object
    #self.clear-object; !!!! DON'T !!!!

    # if higher level object then extract native object from it
    my Any $no = $native-object;

# assume that all arrives native so no conversion!
#    $no = $native-object._get-native-object
#      if $native-object.^can('_get-native-object');

    $!n-native-object = $no;
    $!is-valid = True;

    # If test mode is triggered by Gnome::T
    if ?$test-mode {
      # test if object is from Cairo. Skip if True.
      unless $no.raku.Str ~~ m:i/ cairo / {

        # only when buildable then the instance is based on Widget -> gui-able
        my Bool $is-a-GtkBuildable = _check_instance_is_a(
          $!n-native-object, _from_name('GtkBuildable')
        ).Bool;

        if $is-a-GtkBuildable {

          # just pick first builder. this should be correct if Gnome::T
          # is started as early as possible
          my $builder = $builders[0];

          # create an id for use in builder to find the object
          my Str $widget-path = [~] _name_from_instance($!n-native-object),
            '-', (++$widget-count).fmt('%04d');

          # add object to builder
          $builder.expose-object( $widget-path, $!n-native-object);

          note "set gobject build-id to: $widget-path" if $Gnome::N::x-debug;
        }
      }
    }
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

#TODO this sub will dissappear after a few releases now 0.19.0
method set-native-object ( $native-object ) {
  self._set-native-object($native-object)
}

#-------------------------------------------------------------------------------
=begin pod
=head2 _set-builder

Used by B<Gnome::Gtk3::Builder> to register itself. Its purpose is twofold

=item Used by B<Gnome::GObject::Object> to process option C<.new(:build-id)>.
=item Used to insert objects into a builder when test mode is turned on.

  method _set-builder ( Gnome::Gtk3::Builder$builder )

=end pod

#tm:4:_set-builder:
method _set-builder ( $builder ) {
  $builders.push($builder);
}

#-------------------------------------------------------------------------------
=begin pod
=head2 _get-builders

Used by B<Gnome::GObject::Object> to search for an object id.

  method _get-builders ( --> Array )

=end pod

#tm:4:_get-builders:
method _get-builders ( --> Array ) {
  $builders
}

#-------------------------------------------------------------------------------
=begin pod
=head2 _set-test-mode

Used to turn test mode on or off. This is done by B<Gnome::T>. When turned on, an event loop can not be started by calling C<Gnome::Gtk3::Main.new.main()> and can only be started by B<Gnome::T>.

  method _set-test-mode ( Bool $mode )

=end pod

#tm:4:_set-test-mode:
method _set-test-mode ( Bool $mode ) {
  $test-mode = $mode;
}

#-------------------------------------------------------------------------------
#tm:4:_set-test-mode:
=begin pod
=head2 _get-test-mode

Get current state.

  method _get-test-mode ( --> Bool )

=end pod

method _get-test-mode ( --> Bool ) {
  $test-mode
}

#-------------------------------------------------------------------------------
#tm:4:_wrap-native-type:
=begin pod
=head2 _wrap-native-type

Used by many classes to create a Raku instance with the native object wrapped in. Sometimes the native object C<$no> is returned from other methods as an undefined object. In that case, the Raku class is created as an invalid object in most cases. Exceptions are the two list classes from C<Gnome::Glib>.

  method _wrap-native-type (
    Str:D $type where ?$type, Any $no
    --> Any
  )

=end pod

method _wrap-native-type ( Str:D $type where ?$type, Any $no --> Any ) {

  # get class and wrap the native object in it
  try require ::($type);
  if $Gnome::N::x-debug and ::($type) ~~ Failure {
    note "Failed to load $type!";
    ::($type).note;
  }

  else {
    if ?$no {
      ::($type).new(:native-object($no));
    }

    else {
      ::($type).new(:native-object(N-GObject));
    }
  }
}

#-------------------------------------------------------------------------------
=begin pod
=head2 _wrap-native-type-from-no

As with C<_wrap-native-type()> this method is used by many classes to create a Raku instance with the native object wrapped in.

  method _wrap-native-type-from-no (
    N-GObject $no, Str:D $match = '', Str:D $replace = '', :child-type?
    --> Any
  ) {

=end pod

# Native to raku object wrap when type can be one of a few possible choices
# e.g. the GtkTreeView may return a GtkTreeModel which can be e.g. a
# GtkTreeStore or GtkListStore.
# That call would be like; ._wrap-native-type-from-no( $no, 'Gtk', 'Gtk3::')
#
# :child-type is used when a class inherits from a gtk widget. This routine can
# not guess what type as a child can be so it must be given. The value can be a
# string which is handled like the rest. Otherwise it is a type and is called
# directly with ,(new:native-object()).

# <NULL-class> ...

#tm:4:_wrap-native-type-from-no:
method _wrap-native-type-from-no (
  N-GObject $no, Str:D $match = '', Str:D $replace = '', *%options
  --> Any
) {
  my Str $type;

  # process :child-type first
  if %options<child-type>:exists {
    if %options<child-type> ~~ Str {
      $type = %options<child-type>;
    }

    else {
      return %options<child-type>.new(:native-object($no))
    }
  }

  else {
    $type = ?$no ?? _name_from_instance($no) !! '';
    return N-GObject unless ( ?$type and $type ne '<NULL-class>');

    if ?$match {
      $type ~~ s/$match/$replace/;
    }

    else {
      given $type {
        when /^ Gtk / { $type ~~ s/^ Gtk/Gtk3::/; }
        when /^ GdkX11 / { $type ~~ s/^ GdkX11/Gdk3::/; }
        when /^ GdkWayland / { $type ~~ s/^ GdkWayland/Gdk3::/; }
        when /^ Gdk / { $type ~~ s/^ Gdk/Gdk3::/; }
        when /^ Atk / { $type ~~ s/^ Atk/Atk::/; }

        # Checking other objects from GObject, Glib and Gio all start with 'G'
        # so it is difficult to map it to the proper raku object.
        #
        # However, wrapping like this is only used when there are multiple
        # native object types to return to the caller. This is mostly
        # restricted to Gtk3 modules. The other reason to call this wrapper is
        # to prevent circular dependencies which sometimes happen in Gdk3
        # modules.
        #
        # The rest must cope with the $match and $replace variables or solve it
        # by using 'my Xyz $xyz .= new(:native-object($no))' or do the require
        # trick used below.

  #      when /^ G / { $native-name ~~ s/^ /::/; }
  #      when /^  / { $native-name ~~ s/^ /::/; }
      }
    }

    $type = [~] 'Gnome', '::', $type;

    #  my Str $type = [~] 'Gnome', '::', $native-name;
    note "wrap $type" if $Gnome::N::x-debug;
  }

#  self._wrap-native-type( $type, $no);

##`{{
  # get class and wrap the native object in it
  require ::($type);
  #my $class = ::($type);
  #$class.new(:native-object($no))
  ::($type).new(:native-object($no))
#}}

}

#-------------------------------------------------------------------------------
method _get_no_type_info (  N-GObject:D $no, Str :$check --> List ) {
  ( my Str $no-type-name = _name_from_instance($no),
    ? $check
      ?? (? _check_instance_is_a( $no, _from_name($check))
           ?? "$no-type-name is a $check"
           !! "$no-type-name is not a $check"
         )
      !! 'no check of type',
  )
}

#-------------------------------------------------------------------------------
#TODO this sub will dissappear after a few releases now 0.19.0
method set-class-info ( Str:D $!class-name ) {
  $!class-gtype = _from_name($!class-name)
}

#-------------------------------------------------------------------------------
#TM:1:_set-class-info:
=begin pod
=head3 _set-class-info

Get and store the GType of the provided class name

  method _set-class-info ( Str:D $!class-name )

  _set-class-info ( Str:D $!class-name )

=end pod

method _set-class-info ( Str:D $!class-name ) {
  $!class-gtype = _from_name($!class-name)
}

#-------------------------------------------------------------------------------
#TODO this sub will dissappear after a few releases now 0.19.0
method set-class-name-of-sub ( Str:D $!class-name-of-sub ) { }

#-------------------------------------------------------------------------------
#TM:1:_set-class-name-of-sub:
=begin pod
=head3 _set-class-name-of-sub

Set the name of the class of a subroutine. This method will disappear if all native subs have there method counterpart and that the FALLBACK system is not needed anymore.

  _set-class-name-of-sub ( Str:D $!class-name-of-sub )

=end pod

method _set-class-name-of-sub ( Str:D $!class-name-of-sub ) { }

#-------------------------------------------------------------------------------
#TODO this sub will dissappear after a few releases now 0.19.0
method get-class-name-of-sub ( --> Str ) { $!class-name-of-sub }

#-------------------------------------------------------------------------------
#TM:1:_get-class-name-of-sub:
=begin pod
=head3 _get-class-name-of-sub

Return the classname of the subroutine. As C<_set-class-name-of-sub()>, this method will disappear too.

  _get-class-name-of-sub ( --> Str )

=end pod

method _get-class-name-of-sub ( --> Str ) { $!class-name-of-sub }

#-------------------------------------------------------------------------------
#TM:1:_set_invalid:
=begin pod
=head3 _set_invalid

Purpose to invalidate an object after some operation such as .destroy().

  _set_invalid ( )

=end pod

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

#TM:1:_f:
=begin pod
=head3 _f

This method is called from classes which are not leaf classes and may need to cast the native object into another type before calling the method at hand.

  method _f ( Str $sub-class? --> Any )

=end pod

method _f ( Str $sub-class? --> Any ) {

  # cast to other gtk object type if the found subroutine is from another
  # gtk object type than the native object stored at $!n-native-object.
  # This happens e.g. when a Gnome::Gtk::Button object uses gtk-widget-show()
  # which belongs to Gnome::Gtk::Widget.
  #
  # Call the method only from classes where all variables are defined!
  my Any $g-object-cast;
  if ?$sub-class and $!class-name ne $sub-class {
    $g-object-cast = _check_instance_cast(
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
sub _from_name ( Str $name --> GType )
  is native(&gobject-lib)
  is symbol('g_type_from_name')
  { * }

sub _name ( GType $type --> Str )
  is native(&gobject-lib)
  is symbol('g_type_name')
  { * }

sub _check_instance_cast (
  N-GObject $instance, GType $iface_type --> N-GObject
) is native(&gobject-lib)
  is symbol('g_type_check_instance_cast')
  { * }

sub _name_from_instance ( N-GObject $instance --> Str )
  is native(&gobject-lib)
  is symbol('g_type_name_from_instance')
  { * }

sub _check_instance_is_a (
  N-GObject $instance, GType $iface_type --> gboolean
) is native(&gobject-lib)
  is symbol('g_type_check_instance_is_a')
  { * }

sub _path_to_string ( N-GObject $path --> Str )
  is native(&gtk-lib)
  is symbol('gtk_widget_path_to_string')
  { * }

# These subs belong to Gnome::Gtk3::Widget but is needed here. To avoid
# circular dependencies, the subs are redeclared here for this purpose
sub _get_path (
  N-GObject $widget --> N-GObject
) is native(&gtk-lib)
  is symbol('gtk_widget_get_path')
  { * }

# These subs belong to Gnome::Gtk3::WidgetPath but is needed here. To avoid
# circular dependencies, the subs are redeclared here for this purpose
sub _iter_get_name ( N-GObject $path, int32 $pos --> Str )
  is native(&gtk-lib)
  is symbol('gtk_widget_path_iter_get_name')
  { * }
