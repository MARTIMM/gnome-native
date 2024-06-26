## Release notes
* 2024-04-04 0.22.0
  * Add `:api<1>` to all class names. Use statements loading the gnome libs have also the api<1> added. Api 1 is also added the 'META6.json' as well as to the dependencies of other gnome modules.

* 2023-08-22 0.21.1
  * Made a separate api<2>. Newer modules are moved there.

* 2023-08-15 0.21.0
  * Modules added to support api<2> `Gnome::*` releases.

* 2023-06-09 0.20.0
  * Generation of library entries modified
  * Add a change in FALLBACK to cope with later modules from gnome-source-skim-tool. A check is made for existence of method `_fallback-v2()`.

* 2022-10-13 0.19.18
  * File extensions renamed

* 2022-08-30 0.19.17
  * Add gunichar type
  * Bug; Building types were inhibited

* 2022-08-03 0.19.16
  * Add more checks when clearing an object

* 2022-08-03 0.19.15
  * Bugfixes in setting $!is-valid

* 2022-06-23 0.19.14
  * Subtle change in widget object counting

* 2022-03-18 0.19.13
  * Add library search for version 4 gtk/gdk.

* 2022-03-18 0.19.12
  * Call nativecast on return value.

* 2022-03-09 0.19.11
  * Add some more debug messages in **N-GObject**.
  * More precise conversion in `N-GObject()` method.

* 2022-03-02 0.19.10
  * Bugfix in `CALL-ME()`.

* 2022-02-10 0.19.9
  * Simplifications and bugfixes

* 2022-02-10 0.19.8
  * Add a few `CALL-ME()` routines to **Gnome::N::N-GObject** too for conversions/coercions.
  ```
  my Gnome::Gtk3::Window $w .= new;
  $w.set-title('N-GObject coercion');
  my N-GObject() $no = $w;

  # method CALL-ME() is used here. There are 3 ways to use it.
  say $no(Gnome::Gtk3::Window).get-title;     # N-GObject coercion
  say $no('Gnome::Gtk3::Window').get-title;   # N-GObject coercion
  say $no().get-title;                        # N-GObject coercion
  ```
  In the last example, it is obvious that you must know what type the native object represents and that the method `.get-title()` can be found there.

* 2022-02-10 0.19.7
  * Add coercion/conversion routines `COERCE()` and `N-GObject()` to **Gnome::N::TopLevelClassSupport**. It is possible to coerce to and from the native object to the Raku object like so;
  ```
  my Gnome::Gdk3::Event $event = …;

  # method COERCE() is used here
  my Gnome::Gdk3::Device() $device = $event.get-device;

  # or
  my Gnome::Gdk3::Device(N-GObject) $device = $event.get-device;
  ```
  ```
  my Gnome::Gtk3::Window $w .= new;

  # method N-GObject() is used here
  my N-GObject() $no = $w;

  # or
  my N-GObject $no = $w.N-GObject;
  ```

* 2022-01-26 0.19.6
  * Modified the `_wrap-native-type()` in TopLevelClassSupport a bit more

* 2022-01-16 0.19.5
  * Add type cairo_bool_type because it is based on int which can be 32- or 64 bits.

* 2022-01-07 0.19.4
  * **TopLevelClassSupport** routine `_wrap-native-type()` argument type for `$no` is changed from `N-GObject` to `Any:D` because it can be other than `N-GObect`.

* 2021-12-30 0.19.3
  * Add an enum for values of gboolean which are `true` and `false` (lowercase) mapping to 1 and 0 resp.

* 2021-12-12 0.19.2
  * Need to test for cairo objects when in test mode. Cairo does not inherit from GObject and does not know about glib type system.

* 2021-12-12 0.19.1
  * Renamed a few methods to show they are internal.
  * Added pod doc

* 2021-12-10 0.19.0
  * Moved code from Object to TopLevelClassSupport.
  * Added code for testing purposes.

* 2021-09-20 0.18.16
  * `_wrap-native-type-from-no()` can have undefined native objects.

* 2021-09-20 0.18.15
  * Need to extend method `_wrap-native-type-from-no()` to cope with user classes which inherit from widget classes. The type of the class can be given as a named argument `:child-type()`.

* 2021-08-02 0.18.14
  * Bugfix in internal method `_wrap-native-type-from-no()`.

* 2021-05-04 0.18.13
  * Removed deprecated code.
  * Issue #22; Modified installation script in `Build.pm6` to prevent doubly generated sub names in `NativeLib.pm6`.

* 2021-04-30 0.18.12
  * Changed API of _wrap-native-type-from-no a bit.

* 2021-04-12 0.18.11
  * Add routines `_wrap-native-type` and `_wrap-native-type-from-no` to TopLevelClassSupport for internal use. Also an info method is added `_get_no_type_info` to investigate a native object's type.

* 2021-04-09 0.18.10
  * Add a routine `_set_invalid` to TopLevelClassSupport for internal use.

* 2021-03-05 0.18.9
  * Remove reading of __TIMESIZE in C. It doesn't exist on Windows.

* 2021-02-13 0.18.8
  * Change Build.pm6 to search for ldconfig in other directories outide PATH.

* 2021-02-01 0.18.7
  * Removed native variant classes

* 2020-12-20 0.18.6
  * Add time_t to list of types in **Gnome::N::GlibToRakuTypes** module.

* 2020-12-20 0.18.5
  * Add `:sub-class` option and remove `:cast` of helper function `_f()` in TopLevelClassSupport

* 2020-12-13 0.18.4
  * Add test file to see how types are mapped.

* 2020-12-12 0.18.3
  * Module NativeLib is completely rewritten after some tests on Appveyor. Library names are matching now for windows using MSYS2 and Mingw. Other window environments asume the naming conventions used by Raku. No tests are done yet for MacOS.

* 2020-12-09 0.18.2
  * Add a method to do parameter type coersion and native object casting. This method is to be used to investigate direct methods of calling opposed to native sub searching done with FALLBACK().

* 2020-11-28 0.18.1
  * Add gpointer type to GlibToRakuTypes.
  * Add GEnum type to GlibToRakuTypes. Enum types in C are always integers and a literal integer in C is always an `int`. When a type like e.g. GtkDirectionType is used in the focus handler of the **Gnome::Gtk3::Widget** class, this type `GEnum` can be used.
  * Add GFlag type.

* 2020-11-28 0.18.0
  * A module called **Gnome::N::GlibToRakuTypes**, is generated during installation of the package. It is a module to be able to use the glib types in the native subs.

    In a definition of a native subroutine, the types can then be left as is, for example a routine from the gobject library;
    ```
    guint g_type_depth (GType type);
    ```
    Can then be defined like

    ```
    use Gnome::N::GlibToRakuTypes:api<1>;

    sub g_type_depth ( GType $type --> guint )
      is native(&gobject-lib)
      { * }
    ```
    It's a bit late in the development of the Gnome packages but is still necessary to implement. The benefits are quite huge;
    * One location where definitions are set. When there is a misinterpretation of a type it is easy to repair.
    * The module is generated using a C program which prints the MAX_\* and MIN_\* sizes from the `limits.h` file. This is important because the int sizes may vary from one machine to the other and maybe also the float and double may vary, who knows. The Build.pm6 module is called by zef to generate the GlibToRakuTypes.pm6 file using the printed values from the C program.

* 2020-10-14 0.17.13
  * Moved Gtk initialization higher up in hierargy. It is moved into **Gnome::GObject::Object**.

* 2020-09-23 0.17.12
  * After Gtk init, Argument list in `@*ARGS` are rebuild because Gtk could have taken some out, E.g. --display etc.

* 2020-08-04 0.17.11
  * Better test on (deprecated) widget option in TopLevelSupportClass
  * Bugfixed in stringify in X.

* 2020-06-21 0.17.10
  * Bugfixed; imported native objects where not reference incremented. Only the Raku objects were.

* 2020-06-21 0.17.9
  * Bugfixed; when arrays are used, arguments get flatten in method`convert-to-natives()`. Use the unflatten slurpy positional argument `**@params`.

* 2020-06-20 0.17.8
  * Modified `convert-to-natives()` in TopLevelClassSupport that it checks for destination argument type. When it detects num32 or num64 all source values are coerced using `.Num()`. This means that next examples are now valid: 10, 1/2, 1e2, '2.3' (these are Int, Rat, Num and Str resp).

* 2020-05-24 0.17.7
  * Removed a test from TopLevelClassSupport which prevented other options to be used when `:$native-object` option was found. This test is not good anymore and it had to be relaxed a bit. Example: User inherits a class, must define a `new()` with an extra named argument to `bless()` to say that its parent can handle options to create a native object. This test goes bad when such a class wants to import a native object using the `:native-object` option.

* 2020-05-15 0.17.6
  * Improve debug output from `test-call()` and `stringify()` in **X**.

* 2020-04-27 0.17.5
  * Bugfixes and some improved debug output

* 2020-04-15 0.17.4
  * Bugfixes

* 2020-04-05 0.17.3
  * Removed a level of exception catching.

* 2020-04-02 0.17.2
  * **TopLevelSupportClass** had bugs; In several places, the idea to cleanup the native object stored in the class, was wrong. It is perfectly possible that the native object is still in use while the Raku object is garbage collected. So it follows that the user must clean the native object when it is safe to do it. Examples are that a widget can be destroyed, a native Value object can be disposed of when done with it etcetera.

* 2020-03-19 0.17.1
  * **TopLevelSupportClass** made independend from native classes
  * Can remove many native classes again because of independency of **TopLevelSupportClass**. The Variant types stay until they might be moved to Glib.
  * Moved some deprecated code from **Gnome::GObject::Object** to **TopLevelClassSupport**.
  * Test if self was defined before initializing. Run cleanup before continuing.

* 2020-03-16 0.17.0
  * Added classes to define gnome structures. The class N-GObject was already there for a long time. The modules added are; N-GError, N-GList, GOptionContext, N-GObject, N-GSList, N-GVariant, N-GVariantBuilder, N-GVariantIter, N-GVariantType. Placing the definitions here at the top of the dependencies will make it more easy to prevent circular dependencies. The downside is that sometimes two modules must be included e.g. N-GError from here and Error from Glib.

* 2020-03-15 0.16.0
  * Developed a top level support class to be used by all Gnome classes living at the top of the foodchain. Example classes which will use this class are **Gnome::GObject::Object**, **Gnome::Glib::Error**, etc. The changes should be invisible to the user.

* 2020-03-06 0.15.8
  * Nicer look of debug messages

* 2020-03-05 0.15.7
  * Move code from FALLBACK in Gnome::GObject::Object to X
  * Add N-GVariant module to provide access to several modules like N-GObject

* 2020-02-29 0.15.6
  * Always show crash errors, not only when debug is turned on.

* 2020-02-22 0.15.5
  * Gio libs setup in NativeLib.

* 2020-01-26 0.15.4
  * Changed `test-call()` in X to return the returned type from the tested call. It defaulted to **Any** when an undefined value was returned, even when it was typed. E.g. an error was thrown when an undefined value from a failed search was returned in the following statement
  ```
  my N-GList $sloc = $list.g_list_find_custom( ... );
  ```

* 2020-01-18 0.15.3
  * Bugfix in deprecate; sub should be unanimous

* 2020-01-15 0.15.2
  * Pango libs setup in NativeLib.
  * Add a method `deprecate()` to show a deprecation message at the exit of the application. It has some more argument to display more information than the trait DEPRECATED does.

* 2020-01-10 0.15.1.1:
  * Repo renaming. Perl6 to Raku.

* 2019-12-09 0.15.1
  * bugfix

* 2019-12-09 0.15.0
  * Modified NativeLib to support the gdk-pixbuf-lib
  * Experiments to split up the NativeLib into separate units to accommodate the several packages and to find out how things must be done on windows.

* 2019-11-04 0.14.1
  * Decided to not support gio yet and reversed the changes

* 2019-11-04 0.14.0
  * Modified NativeLib to export the sub lib-gio and provide link to unix lib

* 2019-10-12 0.13.8
  * Bugfixes, repair 'improvements'

* 2019-10-07 0.13.7
  * Small improvements

* 2019-08-22 0.13.6
  * Small improvements

* 2019-07-19 0.13.5
  * Change debug function. Was placed in exception block but it should not be there. Also it accepts more options like :off.
  * Some debug output lines improved.
  * Added test for debug setting.

* 2019-05-28 0.13.4
  * Bugfixes

* 2019-05-28 0.13.3
  * Updating docs

* 2019-05-28 0.13.2
  * Bugfixes

* 2019-05-27 0.13.1
  * Refactored from project GTK::V3 at version 0.13.1
