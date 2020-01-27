## Release notes
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
