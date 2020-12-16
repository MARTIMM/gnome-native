![Gtk+ Raku logo][logo]
<!--
[![Build Status](https://travis-ci.org/MARTIMM/gnome-native.svg?branch=master)](https://travis-ci.org/MARTIMM/gnome-native) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/MARTIMM/gnome-native?branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending&svg=true)](https://ci.appveyor.com/project/MARTIMM/gnome-native/branch/master) [![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)
-->
# Gnome::N - Native Object and Raku - Gnome Interfacing

![T][travis-svg] ![A][appveyor-svg] ![L][license-svg]

[travis-svg]: https://travis-ci.org/MARTIMM/gnome-native.svg?branch=master
[travis-run]: https://travis-ci.org/MARTIMM/gnome-native

[appveyor-svg]: https://ci.appveyor.com/api/projects/status/github/MARTIMM/gnome-native?branch=master&passingText=Windows%20-%20OK&failingText=Windows%20-%20FAIL&pendingText=Windows%20-%20pending&svg=true
[appveyor-run]: https://ci.appveyor.com/project/MARTIMM/gnome-native/branch/master

[license-svg]: http://martimm.github.io/label/License-label.svg
[licence-lnk]: http://www.perlfoundation.org/artistic_license_2_0

# Description

This package holds the native object description as well as the interface description to connect to the Gnome libraries. This set of modules will never act on their own. They will be used by other packages such as `Gnome::Gtk3` and the like.

## Documentation
* [ 🔗 Website](https://martimm.github.io/gnome-gtk3/content-docs/reference-native.html)
* [ 🔗 Travis-ci run on master branch][travis-run]
* [ 🔗 Appveyor run on master branch][appveyor-run]
* [ 🔗 License document][licence-lnk]
* [ 🔗 Release notes][changes]

# Installation
Do not install this package on its own. Instead install `Gnome::Gtk3`.

`zef install Gnome::Gtk3`


# Author

Name: **Marcel Timmerman**
Github account name: **MARTIMM**

# Issues

There are always some problems! If you find one please help by filing an issue at [my Gnome::Gtk3 github project][issues].

# Attribution

* The inventors of Raku, formerly known as Perl 6, of course and the writers of the documentation which helped me out every time again and again.
* The builders of all the Gnome libraries and the documentation.
* Other helpful modules for their insight and use.

[//]: # (---- [refs] ----------------------------------------------------------)
[changes]: https://github.com/MARTIMM/gnome-native/blob/master/CHANGES.md
[logo]: https://martimm.github.io/gnome-gtk3/content-docs/images/gtk-raku.png
[issues]: https://github.com/MARTIMM/gnome-gtk3/issues



[//]: # (https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GObject.pdf)
[//]: # (Pod documentation rendered with)
[//]: # (pod-render.pl6 --pdf --g=MARTIMM/gtk-v3 lib)
