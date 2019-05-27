![gtk logo][logo]

# Gnome::N - Native Object and Perl6 - Gnome Interfacing

[![License](http://martimm.github.io/label/License-label.svg)](http://www.perlfoundation.org/artistic_license_2_0)

# Description

This package holds the native object description as well as the interface description to connect to the Gnome libraries. This set modules will never act on their own. They will be used by other packages such as Gnome::Gtk and the like.

## Note
This package is refactored from GTK::V3 at version 0.13.1

## Release notes
* [Release notes][changes]

# Installation of Gnome::N

`zef install Gnome::N`


# Author

Name: **Marcel Timmerman**
Github account name: **MARTIMM**

# Issues

There are always some problems! If you find one please help by filing an issue at [my github project](https://github.com/MARTIMM/perl6-gnome-native/issues).

# Attribution

* The inventors of Perl6 of course and the writers of the documentation which help me out every time again and again.
* The builders of all the Gnome libraries and the documentation.
* Other helpful modules for their insight and use.

[//]: # (---- [refs] ----------------------------------------------------------)
[changes]: https://github.com/MARTIMM/perl6-gnome-native/blob/master/CHANGES.md
[logo]: https://github.com/MARTIMM/perl6-gnome-native/blob/master/doc/images/gtk-logo-100.png




[gtkaboutdialog]: https://developer.gnome.org/gtk3/stable/GtkAboutDialog.html
[gtkbin]: https://developer.gnome.org/gtk3/stable/GtkBin.html
[gtkbuilder]: https://developer.gnome.org/gtk3/stable/GtkBuilder.html
[gtkbutton]: https://developer.gnome.org/gtk3/stable/GtkButton.html
[gtkcheckbutton]: https://developer.gnome.org/gtk3/stable/GtkCheckButton.html
[GtkComboBox]: https://developer.gnome.org/gtk3/stable/GtkComboBox.html
[GtkComboBoxText]: https://developer.gnome.org/gtk3/stable/GtkComboBoxText.html#gtk-combo-box-text-append
[gtkcontainer]: https://developer.gnome.org/gtk3/stable/GtkContainer.html
[gtkcssprovider]: https://developer.gnome.org/gtk3/stable/GtkCssProvider.html
[gtkdialog]: https://developer.gnome.org/gtk3/stable/GtkDialog.html
[gtkentry]: https://developer.gnome.org/gtk3/stable/GtkEntry.html
[GtkFileChooser]: https://developer.gnome.org/gtk3/stable/GtkFileChooser.html
[GtkFileChooserDialog]: https://developer.gnome.org/gtk3/stable/GtkFileChooserDialog.html
[GtkFileFilter]: https://developer.gnome.org/gtk3/stable/GtkFileFilter.html
[gtkgrid]: https://developer.gnome.org/gtk3/stable/GtkGrid.html
[gtkimage]: https://developer.gnome.org/gtk3/stable/GtkImage.html
[gtkimagemenuitem]: https://developer.gnome.org/gtk3/stable/GtkImageMenuItem.html
[gtklabel]: https://developer.gnome.org/gtk3/stable/GtkLabel.html
[GtkLevelBar]: https://developer.gnome.org/gtk3/stable/GtkLevelBar.html
[gtklistbox]: https://developer.gnome.org/gtk3/stable/GtkListBox.html
[gtkmain]: https://developer.gnome.org/gtk3/stable/GtkMain.html
[gtkmenuitem]: https://developer.gnome.org/gtk3/stable/GtkMenuItem.html
[GtkOrientable]: https://developer.gnome.org/gtk3/stable/gtk3-Orientable.html
[GtkPaned]: https://developer.gnome.org/gtk3/stable/GtkPaned.html
[gtkradiobutton]: https://developer.gnome.org/gtk3/stable/GtkRadioButton.html
[GtkRange]: https://developer.gnome.org/gtk3/stable/GtkRange.html
[GtkStyleContext]: https://developer.gnome.org/gtk3/stable/GtkStyleContext.html
[GtkScale]: https://developer.gnome.org/gtk3/stable/GtkScale.html
[gtktextbuffer]: https://developer.gnome.org/gtk3/stable/GtkTextBuffer.html
[gtktexttagtable]: https://developer.gnome.org/gtk3/stable/GtkTextTagTable.html
[gtktextview]: https://developer.gnome.org/gtk3/stable/GtkTextView.html
[gtktogglebutton]: https://developer.gnome.org/gtk3/stable/GtkToggleButton.html
[gtkwidget]: https://developer.gnome.org/gtk3/stable/GtkWidget.html
[gtkwindow]: https://developer.gnome.org/gtk3/stable/GtkWindow.html

[GdkDisplay]: https://developer.gnome.org/gdk3/stable/GdkDisplay.html
[GdkScreen]: https://developer.gnome.org/gdk3/stable/GdkScreen.html
[GdkWindow]: https://developer.gnome.org/gdk3/stable/gdk3-Windows.html

[gerror]: https://developer.gnome.org/glib/stable/glib-Error-Reporting.html
[GFile]: https://developer.gnome.org/gio/stable/GFile.html
[GInitiallyUnowned]: https://developer.gnome.org/gtk3/stable/ch02.html
[GInterface]: https://developer.gnome.org/gobject/stable/GTypeModule.html
[glist]: https://developer.gnome.org/glib/stable/glib-Doubly-Linked-Lists.html
[gmain]: https://developer.gnome.org/glib/stable/glib-The-Main-Event-Loop.html
[GObject]: https://developer.gnome.org/gobject/stable/gobject-The-Base-Object-Type.html
[GSignal]: https://developer.gnome.org/gobject/stable/gobject-Signals.html
[gslist]: https://developer.gnome.org/glib/stable/glib-Singly-Linked-Lists.html
[GType1]: https://developer.gnome.org/gobject/stable/gobject-Type-Information.html
[GType2]: https://developer.gnome.org/glib/stable/glib-Basic-Types.html
[GValue1]: https://developer.gnome.org/gobject/stable/gobject-Generic-values.html
[GValue2]: https://developer.gnome.org/gobject/stable/gobject-Standard-Parameter-and-Value-Types.html


[GdkEventTypes]: https://developer.gnome.org/gdk3/stable/gdk3-Event-Structures.html


[//]: # (https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GObject.pdf)
[//]: # (Pod documentation rendered with)
[//]: # (pod-render.pl6 --pdf --g=MARTIMM/gtk-v3 lib)

[GTK::V3::Gdk::GdkEventTypes html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GdkEventTypes.html
[GTK::V3::Gdk::GdkEventTypes pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GdkEventTypes.pdf
[GTK::V3::Glib::GObject html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GObject.html
[GTK::V3::Glib::GObject pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GObject.pdf
[GTK::V3::Glib::GSignal html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GSignal.html
[GTK::V3::Glib::GSignal pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GSignal.pdf
[GTK::V3::Gtk::GtkAboutDialog html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkAboutDialog.html
[GTK::V3::Gtk::GtkAboutDialog pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkAboutDialog.pdf
[GTK::V3::Gtk::GtkBin html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkBin.html
[GTK::V3::Gtk::GtkBin pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkBin.pdf
[GTK::V3::Gtk::GtkBuilder html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkBuilder.html
[GTK::V3::Gtk::GtkBuilder pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkBuilder.pdf
[GTK::V3::Gtk::GtkButton html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkButton.html
[GTK::V3::Gtk::GtkButton pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkButton.pdf
[GTK::V3::Gtk::GtkCheckButton html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkCheckButton.html
[GTK::V3::Gtk::GtkCheckButton pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkCheckButton.pdf
[GTK::V3::Gtk::GtkComboBox html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkComboBox.html
[GTK::V3::Gtk::GtkComboBox pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkComboBox.pdf
[GTK::V3::Gtk::GtkComboBoxText html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkComboBoxText.html
[GTK::V3::Gtk::GtkComboBoxText pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkComboBoxText.pdf
[GTK::V3::Gtk::GtkDialog html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkDialog.html
[GTK::V3::Gtk::GtkDialog pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkDialog.pdf
[GTK::V3::Gtk::GtkFileChooserDialog html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkFileChooserDialog.html
[GTK::V3::Gtk::GtkFileChooserDialog pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkFileChooserDialog.pdf
[GTK::V3::Gtk::GtkLevelBar pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkLevelBar.pdf
[GTK::V3::Gtk::GtkMain html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkMain.html
[GTK::V3::Gtk::GtkMain pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkMain.pdf
[GTK::V3::Gtk::GtkOrientable pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkOrientable.pdf
[GTK::V3::Gtk::GtkToggleButton html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkToggleButton.html
[GTK::V3::Gtk::GtkToggleButton pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkToggleButton.pdf
[GTK::V3::Gtk::GtkWidget html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkWidget.html
[GTK::V3::Gtk::GtkWidget pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkWidget.pdf
[GTK::V3::Gtk::GtkWindow html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkWindow.html
[GTK::V3::Gtk::GtkWindow pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkWindow.pdf
[GTK::V3::Gtk::GtkPaned html]: https://nbviewer.jupyter.org/github/MARTIM/gtk-v3/blob/master/doc/GtkPaned.html
[GTK::V3::Gtk::GtkPaned pdf]: https://nbviewer.jupyter.org/github/MARTIM/gtk-v3/blob/master/doc/GtkPaned.pdf
[GTK::V3::Gtk::GtkRange pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkRange.pdf
[GTK::V3::Gtk::GtkScale html]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkScale.html
[GTK::V3::Gtk::GtkScale pdf]: https://nbviewer.jupyter.org/github/MARTIMM/gtk-v3/blob/master/doc/GtkScale.pdf
