![Gtk+ Raku logo][logo]

# Gnome::N - Native Raku Interface to Gnome 

![L][license-svg]

[license-svg]: http://martimm.github.io/label/License-label.svg
[licence-lnk]: http://www.perlfoundation.org/artistic_license_2_0

# Description

This package holds the native object description as well as the interface description to connect to the Gnome libraries. This set of modules will never act on their own. They will be used by other packages such as `Gnome::Gtk3` and the like.

Note that all modules are now in `:api<1>`. This is done to prevent clashes with future distributions having the same class names only differing in this api string. So, add this string to your import statements and dependency modules of these classes in META6.json. Furthermore add this api string also when installing with zef.

Example;
```
use Gnome::Gtk3::Main:api<1>;
use Gnome::Gtk3::Window:api<1>;
use Gnome::Gtk3::Grid:api<1>;
use Gnome::Gtk3::Button:api<1>;

my Gnome::Gtk3::Main $m .= new;
… etcetera …
```

## Documentation
<!-- * [ 🔗 Website](https://martimm.github.io/gnome-gtk3/content-docs/reference-native.html)
-->
* [ 🔗 License document][licence-lnk]
* [ 🔗 Release notes][changes]
* [ 🔗 Issues](https://github.com/MARTIMM/gnome-gtk3/issues)

# Installation
Do not install this package on its own. Instead install `Gnome::Gtk3:api<1>`.

`zef install 'Gnome::Gtk3:api<1>'`


# Author

Name: **Marcel Timmerman**
Github account name: **MARTIMM**


# Issues

There are always some problems! If you find one, please help by filing an issue at [my Gnome::Gtk3 github project][issues].


# Attribution

* The developers of Raku of course and the writers of the documentation which helped me out every time again and again.
* The builders of all the Gnome libraries and its documentation.
* Other helpful modules for their insight and use.

[//]: # (---- [refs] ----------------------------------------------------------)
[changes]: https://github.com/MARTIMM/gnome-native/blob/master/CHANGES.md
[logo]: https://martimm.github.io/gnome-gtk3/content-docs/images/gtk-raku.png
[issues]: https://github.com/MARTIMM/gnome-gtk3/issues



[//]: # (https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GObject.pdf)
[//]: # (Pod documentation rendered with)
[//]: # (pod-render.pl6 --pdf --g=MARTIMM/gtk-v3 lib)
