
#-------------------------------------------------------------------------------
# This module is generated at installation time.
# Please do not change any of the contents of this module.
#-------------------------------------------------------------------------------

use v6;
use NativeCall;

unit package Gnome::N::GlibToRakuTypes:auth<github:MARTIMM>:ver<0.3.0>;

#-------------------------------------------------------------------------------
constant \GEnum           is export = int32;
constant \GFlag           is export = uint32;
constant \GQuark          is export = uint32;
constant \GType           is export = uint64;
constant \cairo_bool_t    is export = int32;
constant \char-ppptr      is export = CArray[CArray[Str]];
constant \char-pptr       is export = CArray[Str];
constant \gboolean        is export = int32;
constant \gchar           is export = int8;
constant \gchar-ppptr     is export = CArray[CArray[Str]];
constant \gchar-pptr      is export = CArray[Str];
constant \gchar-ptr       is export = Str;
constant \gdouble         is export = num64;
constant \gfloat          is export = num32;
constant \gint            is export = int32;
constant \gint-ptr        is export = CArray[int32];
constant \gint16          is export = int16;
constant \gint32          is export = int32;
constant \gint64          is export = int64;
constant \gint8           is export = int8;
constant \glong           is export = int64;
constant \gpointer        is export = Pointer;
constant \gshort          is export = int16;
constant \gsize           is export = uint64;
constant \gssize          is export = int64;
constant \guchar          is export = uint8;
constant \guint           is export = uint32;
constant \guint16         is export = uint16;
constant \guint32         is export = uint32;
constant \guint64         is export = uint64;
constant \guint8          is export = uint8;
constant \gulong          is export = uint64;
constant \gushort         is export = uint16;
constant \int-ptr         is export = CArray[int32];
constant \time_t          is export = int64;
constant \void-ptr        is export = Pointer[void];

#-------------------------------------------------------------------------------
enum gboolean-values is export <false true>;

