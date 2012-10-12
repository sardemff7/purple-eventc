AC_PREREQ([2.65])
AC_INIT([purple-eventc],[0.1],[],[])

AC_CONFIG_HEADERS([src/config.h])
AC_CONFIG_SRCDIR([src/])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_AUX_DIR([.aux])

AM_INIT_AUTOMAKE([1.11 subdir-objects dist-xz no-dist-gzip tar-ustar foreign])

AM_SILENT_RULES([yes])

AC_PROG_CC
AM_PROG_CC_C_O
AM_PROG_VALAC([0.12])
AC_DISABLE_STATIC
LT_INIT
PKG_PROG_PKG_CONFIG

GETTEXT_PACKAGE=$PACKAGE_NAME
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [Gettext Package])
IT_PROG_INTLTOOL([0.40.0])

AC_PROG_INSTALL


AM_CFLAGS="-Wall -Wextra -Wno-unused-parameter"
AM_LDFLAGS=""
AM_VALAFLAGS=""

#
# Check for glib-2.0
#
PKG_CHECK_MODULES(GLIB, glib-2.0)
GLIB_VALAFLAGS="--pkg glib-2.0"
AC_SUBST(GLIB_VALAFLAGS)
#
# Check for gio-2.0
#
PKG_CHECK_MODULES(GIO, gio-2.0)
GIO_VALAFLAGS="--pkg gio-2.0"
AC_SUBST(GIO_VALAFLAGS)

#
# Check for libeventc
#
PKG_CHECK_MODULES(EVENTD, [libeventd-event libeventc])
EVENTD_VALAFLAGS="--pkg libeventd-event --pkg libeventc"
AC_SUBST(EVENTD_VALAFLAGS)

#
# Check for libpurple
#
AC_ARG_WITH(purple-plugindir, AS_HELP_STRING([--with-purple-plugindir=DIR], [Directory for libpurple plugin]), [], with_purple_plugindir=yes)
case "$with_purple_plugindir" in
    no|"") AC_MSG_ERROR([*** You must define purple-plugindir]) ;;
    yes) plugindir="`$PKG_CONFIG --variable=plugindir purple`" ;;
    *) plugindir="$with_purple_plugindir" ;;
esac
PKG_CHECK_MODULES(PURPLE, purple >= 2.6.0)
PURPLE_VALAFLAGS="--pkg purple-custom"
AC_SUBST(PURPLE_VALAFLAGS)
AC_SUBST(plugindir)

#
# Check for purple-events
#
PKG_CHECK_MODULES(PURPLE_EVENTS, [purple-events])
PURPLE_EVENTS_VALAFLAGS="--pkg purple-events"
AC_SUBST(PURPLE_EVENTS_VALAFLAGS)


AC_ARG_ENABLE(debug, AS_HELP_STRING([--enable-debug], [Enable debug]), [], enable_debug=no)
if test x$enable_debug = xyes; then
    AC_DEFINE([DEBUG], [1], [Activate debug mode])
    AM_VALAFLAGS="${AM_VALAFLAGS} --debug"
fi
AC_SUBST(AM_CFLAGS)
AC_SUBST(AM_LDFLAGS)
AC_SUBST(AM_VALAFLAGS)

AC_SUBST(shrext_cmds)

AC_CONFIG_FILES([
    Makefile
    po/Makefile.in
])
AC_OUTPUT