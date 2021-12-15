use v6.d;
use Test;

#-------------------------------------------------------------------------------
#`{{
Purpose of tests
  - Use of top level support class outside the GTK machinery
  - Test the subs and methods of that class
  - Referencing / de-referencing of objects
  - Inheriting a class into a user class


Administration of BUILD options on each branch
  Gnome::N::TopLevelClassSupport          At the top
    :native-object
  Gnome::GObject::Object                  Top of most gtk/glib classes
    :build-id
  ...                                     Any in between classes
    ...
  Label                                   Bottom
    :text
  ReversedLabel                           User class inheriting from Label
    :rtext

A user of ReversedLabel can only use the options from the TopLevelClassSupport, Object, Label and ReversedLabel. From the first two, the native object must represent the Label/ReversedLabel classes. However, you can give a Label to a Widget but not the other way around, a Widget planted into a Label.
The user cannot use options from the classes in between because those will create other object types than intended. Maybe some check of self.^name is still needed.
}}
#-------------------------------------------------------------------------------
use NativeCall;

use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::TopLevelClassSupport;

#use Gnome::N::X;
#Gnome::N::debug(:on);

#-----------------------------------------------------------------------------
# native subs
sub gtk_label_new ( Str $str --> N-GObject )
  is native(&gtk-lib)
  { * }

sub gtk_label_set_text ( N-GObject $label, Str $str )
  is native(&gtk-lib)
  { * }

sub gtk_label_get_text ( N-GObject $label --> Str )
  is native(&gtk-lib)
  { * }

#-------------------------------------------------------------------------------
# make a toplevel class. Label is a GTK class example
class Label is Gnome::N::TopLevelClassSupport {

  has Bool $.check-ref-call is rw;

  #-----------------------------------------------------------------------------
  # first the BUILD from TopLevelClassSupport where %options<native-object>
  # is tested.
  submethod BUILD ( *%options ) {

    ok 1, [~] 'Label.BUILD(', %options.perl, '), ', self.is-valid;

    # we must check if native object is set by other parent class BUILDers
    if self.is-valid { }

    # only then we can process our own options. a child class can defined a
    # new() submethod to inject the Label option which will then checked here
    # to process the other options.
    elsif self.^name eq 'Label' or %options<Label> {

      if ? %options<text> {
        my N-GObject $no = gtk_label_new(%options<text>);
        self.set-native-object($no);
      }
    }
# TODO check for unknown options
# TODO check for no options as a default

#`{{ Cannot do this, because options are taken away from next child
    elsif %options.keys.elems {
      die X::Gnome.new(
        :message('Unsupported options for ' ~ self.^name ~
                 ': ' ~ %options.keys.join(', ')
                )
      );
    }
}}

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkLabel');
  }

  #-----------------------------------------------------------------------------
  method _fallback ( $native-sub is copy --> Callable ) {

    my Callable $s;

    try { $s = &::("gtk_label_$native-sub"); };
    try { $s = &::("gtk_$native-sub"); } unless ?$s;
    try { $s = &::($native-sub); } if !$s and $native-sub ~~ m/^ 'gtk_' /;

    self._set-class-name-of-sub('GtkLabel') if ?$s;
    $s = callsame unless ?$s;

    $s
  }

  #-----------------------------------------------------------------------------
  # this must go into direct children of TopLevelClassSupport
  method native-object-ref ( N-GObject $no is copy --> N-GObject ) {
    if !g_object_is_floating($no) and self.is-valid {
      ok 1, "ref +++ $no";
      $no = g_object_ref($no);
    }

    $no
  }

  #-----------------------------------------------------------------------------
  # this must go into direct children of TopLevelClassSupport
  method native-object-unref ( N-GObject $no ) {
    unless g_object_is_floating($no) {
      ok 1, "ref --- $no";
      g_object_unref($no);
    }
  }
}

#-------------------------------------------------------------------------------
# make a child class. ReversedLabel is a user definable class example
class ReversedLabel is Label {

  # this method can help injecting an option before BUILDs are called.
  multi method new ( |c ) {

    ok 1, [~] 'ReversedLabel.new(', c.perl, ')';
    self.bless( |c, :Label);
  }

  #-----------------------------------------------------------------------------
  # first the BUILD from TopLevelClassSupport where %options<native-object>
  # is tested, then the BUILD from Label where %options<text> is processed.
  submethod BUILD ( *%options ) {

    ok 1, [~] 'ReversedLabel.BUILD(', %options.perl, '), ', self.is-valid;
#note "Build reversed label: ", %options.perl;
    # native object already defined
    #return if self.is-valid;

    # we must check if native object is set by other parent class BUILDers
    if self.is-valid {
      self.set-text(self.get-text.split('').reverse.join);
    }

    # only then we can process our own options
    elsif self.^name eq 'ReversedLabel' or %options<ReversedLabel> {
      if ? %options<rtext> {
        my Str $t = %options<rtext>.split('').reverse.join;
        self.set-native-object(gtk_label_new($t));
      }
    }
  }
}



#-------------------------------------------------------------------------------
# make a child class. ReversedLabel is a user definable class example
class ReversedLabel2 is ReversedLabel {

  # this method can help injecting an option before BUILDs are called.
  multi method new ( |c ) {

    ok 1, [~] 'ReversedLabel2.new(', c.perl, ')';
    self.bless( |c, :Label, :ReversedLabel);
  }

  #-----------------------------------------------------------------------------
  # first the BUILD from TopLevelClassSupport where %options<native-object>
  # is tested, then the BUILD from Label where %options<text> is processed.
  submethod BUILD ( *%options ) {

    ok 1, [~] 'ReversedLabel2.BUILD(', %options.perl, '), ', self.is-valid;
#note "Build reversed label 2: ", %options.perl;
    # native object already defined
    #return if self.is-valid;

    # we must check if native object is set by other parent class BUILDers
    if self.is-valid {
      self.set-text(self.get-text.split('').reverse.join ~ ' 2');
    }

    # only then we can process our own options
    elsif self.^name eq 'ReversedLabel2' or %options<ReversedLabel2> {
      if ? %options<rtext2> {
        my Str $t = %options<rtext2>.split('').reverse.join ~ ' 2';
        self.set-native-object(gtk_label_new($t));
      }
    }
  }
}


#-------------------------------------------------------------------------------
my Int $label-gtype;
subtest 'Label tests', {

  my Label $l1 .= new(:text<test-text>);
  my N-GObject $no = $l1._get-native-object;
  ok $no.defined, 'Label ._get-native-object()';
  my Label $l1a .= new(:native-object($no));
  is $l1.get-text, 'test-text', 'Label .new(:native-object) .get-text()';


  is $l1.get-class-name, 'GtkLabel', 'Label .get-class-name()';
  $label-gtype = $l1.get-class-gtype;
#note "ic l1: $label-gtype, ref count: ",
#    g_type_get_instance_count($label-gtype), ', floating: ',
#    g_object_is_floating($l1._get-native-object);

#note "l1: ", $l1.perl;
  is $l1.get-text, 'test-text', 'Label .new(:text) .get-text()';

#prove6 does not see this correctly!!!
#  dies-ok(
#    { $l2 .= new( :native-object($l1), :text<notext>); },
#    'combination with :native-object and other options are not allowed'
#  );

  my Label $l2;
  $l2 .= new(:native-object($l1));
#note 'ic l2: ', $l2.get-class-gtype, ', ref count: ',
#    g_type_get_instance_count($l2.get-class-gtype), ', floating: ',
#    g_object_is_floating($l2._get-native-object);
#note "l2: ", $l2.perl;
  is $l2.get-text, 'test-text', 'Label .new(:native-object) .get-text()';

  $no = $l1._get-native-object;
  isa-ok $no, N-GObject, '._get-native-object()';
  $l2 .= new( :native-object($no));
  is $l2.get-text, 'test-text', 'Label .new(:native-object) .get-text()';
  $l2.clear-object;
#note 'ic after clear: ', $l2.get-class-gtype, ', ',
#       g_type_get_instance_count($l2.get-class-gtype);
  nok $l2.is-valid, '.is-valid()';
}

subtest 'ReversedLabel tests', {
  my ReversedLabel $l3 .= new(:text<some>);
  is $l3.get-class-name, 'GtkLabel', 'ReversedLabel .get-class-name()';
  is $l3.get-class-gtype, $label-gtype, 'gtype of ReversedLabel ~~ Label';
  is $l3.get-text, 'emos', 'ReversedLabel .new(:text) .get-text()';

  $l3 .= new( :rtext<flup>, :text<thus>);
  is $l3.get-text, 'suht',
     'ReversedLabel .new( :text, :rtext<flup>) .get-text(), :rtext ignored';

  $l3 .= new( :rtext<flup>);
  is $l3.get-text, 'pulf', 'ReversedLabel .new(:rtext) .get-text()';
}

subtest 'ReversedLabel2 tests', {
  my ReversedLabel2 $l4 .= new(:text<some>);
  is $l4.get-class-name, 'GtkLabel', 'ReversedLabel2 .get-class-name()';
  is $l4.get-class-gtype, $label-gtype, 'gtype of ReversedLabel2 ~~ Label';
  is $l4.get-text, 'some 2',
     'ReversedLabel2 .new(:text) .get-text() reversed twice';

  $l4 .= new( :rtext<flup>, :text<thus>);
  is $l4.get-text, 'thus 2',
     'ReversedLabel2 .new( :text, :rtext<flup>) .get-text(), :rtext ignored reversed twice';

  $l4 .= new( :rtext<flup>);
  is $l4.get-text, 'flup 2',
     'ReversedLabel2 .new(:rtext) .get-text() reversed twice';
}

subtest 'Reference tests', {
  my Label $l1 .= new(:text<test-text>);
  is $l1.get-class-name, 'GtkLabel', 'Label .get-class-name()';
  $label-gtype = $l1.get-class-gtype;
  is g_type_get_instance_count($label-gtype), 0, 'refcount 0';
  ok g_object_is_floating($l1._get-native-object), 'object floats';

  my N-GObject $w = gtk_window_new(0);
  my $no = $l1._get-native-object;
  gtk_container_add( $w, $no);
#TODO is still 0, why?
#  is g_type_get_instance_count($label-gtype), 1, 'refcount 1';
  nok g_object_is_floating($no), 'object doesn\'t float';
#  $l1.native-clear-object($no);
}





#-------------------------------------------------------------------------------
# must set GOBJECT_DEBUG environment variable to include 'instance-count'
sub g_type_get_instance_count ( int32 $type --> int32 )
  is native(&gobject-lib)
  { * }

sub g_object_ref ( N-GObject $object --> N-GObject )
  is native(&gobject-lib)
  { * }

sub g_object_unref ( N-GObject $object )
  is native(&gobject-lib)
  { * }

sub g_object_is_floating ( N-GObject $object )
  returns int32
  is native(&gobject-lib)
  { * }

#`{{
#sub g_clear_object ( CArray[CArray[N-GObject]] $object_ptr )
#  is native(&gobject-lib)
#  { * }

#sub g_clear_object ( CArray[N-GObject] $object_ptr )
#  is native(&gobject-lib)
#  { * }

sub g_clear_object ( Pointer $object_ptr )
  is native(&gobject-lib)
  { * }
}}

sub gtk_window_new ( int32 $type )
  returns N-GObject
  is native(&gtk-lib)
  { * }

sub gtk_container_add ( N-GObject $container, N-GObject $widget )
  is native(&gtk-lib)
  { * }

#-------------------------------------------------------------------------------
done-testing;
