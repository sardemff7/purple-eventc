AM_DISTCHECK_CONFIGURE_FLAGS = \
	--with-purple-plugindir="$$dc_install_base/$(plugindir)"

ACLOCAL_AMFLAGS = -I m4 ${ACLOCAL_FLAGS}
AM_MAKEFLAGS = --no-print-directory

SUBDIRS = po

plugin_LTLIBRARIES =

AM_CFLAGS += \
	-D LOCALEDIR=\"$(localedir)\" \
	--include config.h

AM_VALAFLAGS += \
	--vapidir $(srcdir)/vapi/ \
	--pkg config


plugin_LTLIBRARIES += \
	eventc.la

eventc_la_VALASOURCES = \
	src/ui.vala \
	src/utils.vala \
	src/callbacks.vala \
	src/eventc.vala

eventc_la_SOURCES = \
	src/config.h \
	$(eventc_la_VALASOURCES) \
	src/plugin.c

eventc_la_VALAFLAGS = \
	$(AM_VALAFLAGS) \
	$(PURPLE_EVENTS_VALAFLAGS) \
	$(PURPLE_VALAFLAGS) \
	$(EVENTD_VALAFLAGS) \
	$(GIO_VALAFLAGS) \
	$(GLIB_VALAFLAGS)

eventc_la_CFLAGS = \
	$(AM_CFLAGS) \
	$(PURPLE_EVENTS_CFLAGS) \
	$(PURPLE_CFLAGS) \
	$(EVENTD_CFLAGS) \
	$(GIO_CFLAGS) \
	$(GLIB_CFLAGS)

eventc_la_LDFLAGS = \
	$(AM_LDFLAGS) \
	-avoid-version -module \
	-export-symbols-regex 'purple_init_(eventc_)?plugin'

eventc_la_LIBADD = \
	$(PURPLE_EVENTS_LIBS) \
	$(PURPLE_LIBS) \
	$(EVENTD_LIBS) \
	$(GIO_LIBS) \
	$(GLIB_LIBS)


#
# Hooks
#

install-data-hook: la-files-install-hook
uninstall-hook: la-files-uninstall-hook

# *.la files cleanup
la-files-install-hook:
	cd $(DESTDIR)$(plugindir) && \
		rm $(plugin_LTLIBRARIES)

# Remove shared object files at uninstall since
# we remove *.la files at install
la-files-uninstall-hook:
	cd $(DESTDIR)$(plugindir) && \
		rm $(plugin_LTLIBRARIES:.la=$(shrext_cmds))
	-rmdir $(DESTDIR)$(plugindir)
